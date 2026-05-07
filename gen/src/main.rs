#![warn(unused_crate_dependencies)]

use std::collections::{BTreeMap, HashMap, HashSet};

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use typst_library::text::RAW_SYNTAXES;

const HEADER: &str = r#"
%YAML 1.2
---
scope: text.typst
version: 2
hidden: true

contexts:
"#;
const MAIN_CONTEXT: &str = r#"
  main:
    - include: fenced-syntaxes-gen
"#;

const TEMPLATE: &str = r#"
  # $COMMENT
  fenced-$NAME:
    - match: (`{3,})((?i:$MATCH))($\n?|\b)
      captures:
        1: punctuation.definition.raw.code-fence.begin.typst
        2: constant.other.language-name.typst
      embed: scope:$FULL_SCOPE
      embed_scope: markup.raw.block.$SCOPE.typst $FULL_SCOPE
      escape: '(?:^[ \t]*)?(\1)\s*'
      escape_captures:
        1: punctuation.definition.raw.code-fence.end.typst
"#;

const SKIP_SYNTAX: &[&str] = &["txt"];

const EXTEND_FILE: &str = "extend.json";

fn main() -> Result<()> {
    let skip_main = std::env::args().nth(1).is_some_and(|a| a == "--skip-main");

    let extends = std::fs::read_to_string(EXTEND_FILE).context("failed to read extend data")?;
    let extends: BTreeMap<String, ExtendMatch> =
        serde_json::from_str(&extends).context("failed to parse extend data")?;
    {
        let res =
            serde_json_pretty::to_string(&extends).context("failed to serialize extend data")?;
        std::fs::write(EXTEND_FILE, res).context("failed to save extend data")?;
    }

    println!("{}", HEADER.trim());
    if !skip_main {
        println!("{}", MAIN_CONTEXT.trim_end());
    }

    let mut added_scopes = HashSet::new();
    // todo: check unused
    let mut used_extends = HashSet::new();

    let mut ext_owners: HashMap<String, Vec<&str>> = HashMap::new();
    for syntax in RAW_SYNTAXES.syntaxes().iter().filter(|s| !s.hidden) {
        for ext in &syntax.file_extensions {
            ext_owners
                .entry(ext_to_tag(ext))
                .or_default()
                .push(&syntax.name);
        }
    }

    for syntax in RAW_SYNTAXES.syntaxes() {
        if syntax.hidden {
            continue;
        }

        let name = syntax.name.as_str();
        let mut exts: Vec<_> = syntax
            .file_extensions
            .iter()
            .map(|e| ext_to_tag(e))
            .filter(|e| !is_wrong_ext(e))
            .collect();

        if let Some(converted) = name_to_match_pat(name)
            && !ext_owners
                .get(&converted)
                .is_some_and(|owners| owners.iter().any(|owner| *owner != name))
        {
            exts.insert(0, converted);
        }

        exts.retain(|tag| {
            RAW_SYNTAXES
                .find_syntax_by_token(tag)
                .is_some_and(|matched| matched.name == syntax.name)
        });

        if exts.is_empty() {
            continue;
        }

        let comment = format!("{name}: {}", syntax.file_extensions.join(", "));
        let extend_key = exts[0].clone();
        if SKIP_SYNTAX.contains(&extend_key.as_str()) {
            eprintln!("skipping ignored {comment}");
            continue;
        }
        let extend = extends.get(&extend_key);

        let scope = if let Some(extend) = extend
            && let Some(rename) = &extend.rename
        {
            rename.to_owned()
        } else if let Some(name_tag) = name_to_match_pat(name) {
            name_tag
        } else {
            scope_to_tag(&syntax.scope.to_string())
        };

        if added_scopes.contains(&scope) {
            eprintln!("skipping already added {comment}");
            continue;
        }

        let mut exts: Vec<_> = exts
            .into_iter()
            // deduplicate
            .collect::<HashSet<_>>()
            .into_iter()
            .collect();
        exts.sort_unstable();

        if extend.is_some() {
            used_extends.insert(extend_key);
        }
        let full_scope = syntax.scope.to_string();
        let res = fill_template(&scope, &exts, &scope, &full_scope, extend, &comment);
        println!("{res}");

        added_scopes.insert(scope);
    }

    if !skip_main {
        println!("\n  fenced-syntaxes-gen:");
        let mut added_scopes: Vec<_> = added_scopes.iter().collect();
        added_scopes.sort_unstable();
        for scope in added_scopes {
            println!("    - include: fenced-{scope}");
        }
    }

    Ok(())
}

fn fill_template(
    name: &str,
    exts: &[String],
    scope: &str,
    default_full_scope: &str,
    extend: Option<&ExtendMatch>,
    comment: &str,
) -> String {
    let full_scope = if let Some(extend) = extend
        && let Some(scope) = &extend.scope
    {
        scope
    } else {
        default_full_scope
    };

    let extend_matches: &[String] = extend.map(|e| e.matches.as_ref()).unwrap_or_default();
    let matches = exts
        .iter()
        .chain(extend_matches.iter())
        .map(|e| ext_to_tag(e))
        .collect::<Vec<_>>()
        .join("|");

    TEMPLATE
        .trim_end()
        .replace("$NAME", name)
        .replace("$SCOPE", scope)
        .replace("$FULL_SCOPE", full_scope)
        .replace("$MATCH", &escape_regex(&matches))
        .replace("$COMMENT", comment)
}

fn escape_regex(s: &str) -> String {
    let mut res = s.to_string();
    for pat in [".", "+"] {
        res = res.replace(pat, &format!("\\{pat}"));
    }
    res
}

fn ext_to_tag(ext: &str) -> String {
    let ext = ext.trim_start_matches(".");
    if let Some((first, _)) = ext.split_once(".") {
        return first.to_string();
    }
    ext.to_string()
}

fn scope_to_tag(scope: &str) -> String {
    let scope = scope
        .strip_prefix("source.")
        .or_else(|| scope.strip_prefix("text."))
        .unwrap_or(scope);
    let scope = scope.replace("++", "pp");

    let mut out = String::new();
    for ch in scope.chars() {
        match ch {
            '+' => out.push('p'),
            '#' => out.push_str("sharp"),
            '.' | '_' => out.push('-'),
            c if c.is_ascii_alphanumeric() => out.push(c.to_ascii_lowercase()),
            _ => out.push('-'),
        }
    }

    while out.contains("--") {
        out = out.replace("--", "-");
    }
    out.trim_matches('-').to_string()
}

fn name_to_match_pat(name: &str) -> Option<String> {
    fn is_valid_in_ident(c: char) -> bool {
        c.is_ascii_alphabetic() || matches!(c, '-')
    }
    let name = name.to_lowercase();
    if name.chars().all(is_valid_in_ident) {
        Some(name)
    } else {
        None
    }
}

fn is_wrong_ext(ext: &str) -> bool {
    ext.contains(" ")
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(default)]
struct ExtendMatch {
    /// Extra match strings
    #[serde(skip_serializing_if = "Vec::is_empty")]
    matches: Vec<String>,
    /// Override which scope to embed
    #[serde(skip_serializing_if = "Option::is_none")]
    scope: Option<String>,
    /// Rename rule and default scope
    #[serde(skip_serializing_if = "Option::is_none")]
    rename: Option<String>,
}
