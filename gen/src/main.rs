#![warn(unused_crate_dependencies)]

use std::collections::{BTreeMap, BTreeSet, HashMap, HashSet};
use std::fmt::Write as _;

use anyhow::{Context, Result};
use codex::{Def, Module, Symbol};
use serde::{Deserialize, Serialize};
use typst_library::text::RAW_SYNTAXES;

const HEADER: &str = r"
%YAML 1.2
---
scope: syntax.text.typst
version: 2
hidden: true

contexts:
";
const MAIN_CONTEXT: &str = r"
  main:
    - include: fenced-syntaxes-gen
";

const TEMPLATE: &str = r"
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
";

const SKIP_SYNTAX: &[&str] = &["txt"];

const EXTEND_FILE: &str = "extend.json";
const RAW_SYNTAXES_FILE: &str = "../TypstCodeSyntaxes.sublime-syntax";
const MAIN_SYNTAX_FILE: &str = "../Typst.sublime-syntax";
const MATH_SYMBOL_FUNCTIONS_BEGIN: &str = "  # BEGIN GENERATED MATH SYMBOL FUNCTIONS";
const MATH_SYMBOL_FUNCTIONS_END: &str = "  # END GENERATED MATH SYMBOL FUNCTIONS";
const SYMBOLS_BEGIN: &str = "  # BEGIN GENERATED NAMED GENERAL SYMBOLS";
const SYMBOLS_END: &str = "  # END GENERATED NAMED GENERAL SYMBOLS";

fn main() -> Result<()> {
    let raw_syntaxes = generate_raw_syntaxes(false)?;
    std::fs::write(RAW_SYNTAXES_FILE, raw_syntaxes)
        .with_context(|| format!("failed to write {RAW_SYNTAXES_FILE}"))?;

    let symbol_entries = collect_symbol_entries_from_codex();

    let math_symbol_functions = generate_math_symbol_functions(&symbol_entries);
    replace_generated_region(
        MAIN_SYNTAX_FILE,
        MATH_SYMBOL_FUNCTIONS_BEGIN,
        MATH_SYMBOL_FUNCTIONS_END,
        &math_symbol_functions,
    )
    .with_context(|| format!("failed to update {MAIN_SYNTAX_FILE}"))?;

    let symbols = generate_named_general_symbols(&symbol_entries);
    replace_generated_region(MAIN_SYNTAX_FILE, SYMBOLS_BEGIN, SYMBOLS_END, &symbols)
        .with_context(|| format!("failed to update {MAIN_SYNTAX_FILE}"))?;

    Ok(())
}

fn generate_raw_syntaxes(skip_main: bool) -> Result<String> {
    let extends = std::fs::read_to_string(EXTEND_FILE).context("failed to read extend data")?;
    let extends: BTreeMap<String, ExtendMatch> =
        serde_json::from_str(&extends).context("failed to parse extend data")?;
    {
        let res =
            serde_json_pretty::to_string(&extends).context("failed to serialize extend data")?;
        std::fs::write(EXTEND_FILE, res).context("failed to save extend data")?;
    }

    let mut out = String::new();
    out.push_str(HEADER.trim());
    out.push('\n');
    if !skip_main {
        out.push_str(MAIN_CONTEXT.trim_end());
        out.push('\n');
    }

    let mut added_scopes = HashSet::new();
    // todo: check unused
    let mut used_extends = HashSet::new();

    let ext_owners = collect_ext_owners();

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

        let scope = if let Some(name_tag) = name_to_match_pat(name) {
            name_tag
        } else {
            scope_to_tag(&syntax.scope.to_string())
        };
        let scope = if let Some(extend) = extend
            && let Some(rename) = &extend.rename
        {
            if &scope == rename {
                eprintln!("{scope}: unused rename {rename:?}");
            }
            rename.to_owned()
        } else {
            scope
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
        out.push_str(&res);
        out.push('\n');

        added_scopes.insert(scope);
    }

    let extends: HashSet<_> = extends.keys().cloned().collect();
    let unused_extends: Vec<_> = extends.difference(&used_extends).cloned().collect();
    if !unused_extends.is_empty() {
        eprintln!("unused extends: {}", unused_extends.join(", "));
    }

    if !skip_main {
        out.push_str("\n  fenced-syntaxes-gen:\n");
        let mut added_scopes: Vec<_> = added_scopes.iter().collect();
        added_scopes.sort_unstable();
        for scope in added_scopes {
            writeln!(out, "    - include: fenced-{scope}").unwrap();
        }
    }

    Ok(out)
}

fn collect_symbol_entries_from_codex() -> Vec<SymbolEntry> {
    let mut entries = Vec::new();
    let mut prefix = Vec::new();
    collect_symbol_entries(codex::SYM, &mut prefix, &mut entries);
    entries
}

fn collect_ext_owners() -> HashMap<String, Vec<&'static str>> {
    let mut ext_owners: HashMap<String, Vec<&str>> = HashMap::new();
    for syntax in RAW_SYNTAXES.syntaxes().iter().filter(|s| !s.hidden) {
        for ext in &syntax.file_extensions {
            ext_owners
                .entry(ext_to_tag(ext))
                .or_default()
                .push(&syntax.name);
        }
    }
    ext_owners
}

fn generate_math_symbol_functions(entries: &[SymbolEntry]) -> String {
    let mut entries: Vec<_> = entries
        .iter()
        .filter(|entry| {
            entry.parts.len() > 1
                && entry
                    .value
                    .as_deref()
                    .is_some_and(is_callable_math_symbol_value)
        })
        .collect();
    entries.sort_by(|a, b| a.parts.cmp(&b.parts));

    let mut out = String::new();
    out.push_str(MATH_SYMBOL_FUNCTIONS_BEGIN);
    out.push('\n');
    out.push_str("  # Generated from Typst's callable symbol values.\n");
    out.push_str("  math-symbol-functions:\n");

    for entry in entries {
        write_math_symbol_function(&mut out, &entry.parts);
    }

    out.push_str(MATH_SYMBOL_FUNCTIONS_END);
    out.push('\n');
    out
}

fn generate_named_general_symbols(entries: &[SymbolEntry]) -> String {
    let bases: BTreeSet<_> = entries
        .iter()
        .filter(|entry| entry.parts.len() == 1)
        .map(|entry| entry.parts[0].clone())
        .collect();

    let mut modifiers: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    for entry in entries.iter().filter(|entry| entry.parts.len() > 1) {
        modifiers
            .entry(entry.parts[0].clone())
            .or_default()
            .extend(entry.parts[1..].iter().cloned());
    }

    let mut out = String::new();
    out.push_str(SYMBOLS_BEGIN);
    out.push('\n');
    out.push_str(
        "  # Generated from https://github.com/typst/codex/blob/main/src/modules/sym.txt\n",
    );
    out.push_str("  named-general-symbols:\n");

    for (base, modifier_set) in modifiers {
        let mods = modifier_set.into_iter().collect::<Vec<_>>().join("|");

        writeln!(out, "    - match: ({base})(\\.)").unwrap();
        let base_scope = if is_greek_symbol(&base) {
            "support.constant.sym.greek.typst"
        } else {
            "support.constant.sym.typst"
        };
        out.push_str("      captures:\n");
        writeln!(out, "        1: {base_scope}").unwrap();
        out.push_str("        2: punctuation.accessor.dot.typst\n");
        out.push_str("      push:\n");
        writeln!(out, "        - match: ({mods})(?:(\\.)|{{{{break}}}})").unwrap();
        out.push_str("          captures:\n");
        out.push_str("            1: support.constant.sym.modifier.typst\n");
        out.push_str("            2: punctuation.accessor.dot.typst\n");
        out.push_str("        - include: consume-and-pop\n");
    }

    let mut double_struck = Vec::new();
    let mut greek = Vec::new();
    let mut general = Vec::new();
    for base in bases {
        if is_double_struck_symbol(&base) {
            double_struck.push(base);
        } else if is_greek_symbol(&base) {
            greek.push(base);
        } else {
            general.push(base);
        }
    }

    for (symbols, scope) in [
        (double_struck, "support.constant.sym.typst"),
        (greek, "support.constant.sym.greek.typst"),
        (general, "support.constant.sym.typst"),
    ] {
        if symbols.is_empty() {
            continue;
        }
        writeln!(out, "    - match: (?:{}){{{{break}}}}", symbols.join("|")).unwrap();
        writeln!(out, "      scope: {scope}").unwrap();
    }

    out.push_str(SYMBOLS_END);
    out.push('\n');
    out
}

fn collect_symbol_entries(
    module: Module,
    prefix: &mut Vec<String>,
    entries: &mut Vec<SymbolEntry>,
) {
    for (name, binding) in module.iter() {
        if binding.deprecation.is_some() {
            continue;
        }

        prefix.push(name.to_string());

        match binding.def {
            Def::Symbol(symbol) => collect_symbol(symbol, prefix, entries),
            Def::Module(module) => collect_symbol_entries(module, prefix, entries),
        }

        prefix.pop();
    }
}

fn collect_symbol(symbol: Symbol, prefix: &[String], entries: &mut Vec<SymbolEntry>) {
    let mut saw_default = false;
    for (modifiers, value, deprecation) in symbol.variants() {
        if deprecation.is_some() {
            continue;
        }

        if modifiers.is_empty() {
            saw_default = true;
            entries.push(SymbolEntry {
                parts: prefix.to_vec(),
                value: Some(value.to_string()),
            });
        } else {
            let mut variant_parts = prefix.to_vec();
            variant_parts.extend(modifiers.iter().map(str::to_string));
            entries.push(SymbolEntry {
                parts: variant_parts,
                value: Some(value.to_string()),
            });
        }
    }

    if !saw_default && matches!(symbol, Symbol::Multi(_)) {
        entries.push(SymbolEntry {
            parts: prefix.to_vec(),
            value: None,
        });
    }
}

fn replace_generated_region(
    path: &str,
    begin_marker: &str,
    end_marker: &str,
    replacement: &str,
) -> Result<()> {
    let text = std::fs::read_to_string(path)?;
    let begin = text
        .find(begin_marker)
        .with_context(|| format!("missing marker {begin_marker:?}"))?;
    let end = text
        .find(end_marker)
        .with_context(|| format!("missing marker {end_marker:?}"))?;
    let end = text[end..]
        .find('\n')
        .map_or(text.len(), |offset| end + offset + 1);

    let mut out = String::new();
    out.push_str(&text[..begin]);
    out.push_str(replacement);
    out.push_str(&text[end..]);
    std::fs::write(path, out)?;
    Ok(())
}

fn is_double_struck_symbol(symbol: &str) -> bool {
    symbol.len() == 2
        && symbol
            .as_bytes()
            .first()
            .is_some_and(|first| symbol.as_bytes().get(1) == Some(first))
        && symbol.chars().all(|c| c.is_ascii_uppercase())
}

fn is_greek_symbol(symbol: &str) -> bool {
    matches!(
        symbol,
        "Alpha"
            | "Beta"
            | "Chi"
            | "Delta"
            | "Digamma"
            | "Epsilon"
            | "Eta"
            | "Gamma"
            | "Iota"
            | "Kappa"
            | "Lambda"
            | "Mu"
            | "Nu"
            | "Omega"
            | "Omicron"
            | "Phi"
            | "Pi"
            | "Psi"
            | "Rho"
            | "Sigma"
            | "Tau"
            | "Theta"
            | "Upsilon"
            | "Xi"
            | "Zeta"
            | "alpha"
            | "beta"
            | "chi"
            | "delta"
            | "digamma"
            | "epsilon"
            | "eta"
            | "gamma"
            | "iota"
            | "kappa"
            | "lambda"
            | "mu"
            | "nu"
            | "omega"
            | "omicron"
            | "phi"
            | "pi"
            | "psi"
            | "rho"
            | "sigma"
            | "tau"
            | "theta"
            | "upsilon"
            | "xi"
            | "zeta"
    )
}

struct SymbolEntry {
    parts: Vec<String>,
    value: Option<String>,
}

fn write_math_symbol_function(out: &mut String, parts: &[String]) {
    out.push_str("    - match: ");
    for (index, part) in parts.iter().enumerate() {
        if index > 0 {
            out.push_str(r"(\.)");
        }
        write!(out, "({})", escape_regex(part)).unwrap();
    }
    out.push_str(r"(?=\()");
    out.push('\n');
    out.push_str("      captures:\n");

    let mut capture = 1;
    writeln!(out, "        {capture}: support.constant.sym.typst").unwrap();
    for _ in parts.iter().skip(1) {
        capture += 1;
        writeln!(out, "        {capture}: punctuation.accessor.dot.typst").unwrap();
        capture += 1;
        writeln!(
            out,
            "        {capture}: support.constant.sym.modifier.typst"
        )
        .unwrap();
    }

    out.push_str("      push: maybe-math-function-params\n");
}

fn is_callable_math_symbol_value(value: &str) -> bool {
    matches!(
        value,
        // Keep synced with typst-library's math::accent::ACCENTS.
        "`"
            | "´"
            | "^"
            | "ˆ"
            | "~"
            | "∼"
            | "˜"
            | "¯"
            | "-"
            | "–"
            | "‾"
            | "−"
            | "˘"
            | "."
            | "˙"
            | "⋅"
            | "¨"
            | "\u{20db}"
            | "\u{20dc}"
            | "∘"
            | "○"
            | "˝"
            | "ˇ"
            | "←"
            | "→"
            | "⟶"
            | "↔"
            | "↔\u{fe0e}"
            | "⟷"
            | "↼"
            | "⇀"
        // Keep synced with typst-library's math::lr::DELIMS left delimiters.
            | "("
            | "⟮"
            | "⦇"
            | "⦅"
            | "⦓"
            | "⦕"
            | "{"
            | "⦃"
            | "["
            | "⦍"
            | "⦏"
            | "⟦"
            | "⦋"
            | "❲"
            | "⟬"
            | "⦗"
            | "⟅"
            | "⎰"
            | "⎱"
            | "⧘"
            | "⧚"
            | "⟨"
            | "⧼"
            | "⦑"
            | "⦉"
            | "⟪"
            | "⌜"
            | "⌞"
            | "|"
            | "‖"
            | "⦀"
            | "⦙"
            | "⦚"
        // Ceil and floor are handled separately in get_lr_wrapper_func.
            | "⌈"
            | "⌊"
    )
}

fn fill_template(
    key: &str,
    exts: &[String],
    scope: &str,
    default_full_scope: &str,
    extend: Option<&ExtendMatch>,
    comment: &str,
) -> String {
    let full_scope = if let Some(extend) = extend
        && let Some(scope) = &extend.scope
    {
        if default_full_scope == scope {
            eprintln!("{key}: unused scope {scope:?}");
        }
        scope
    } else {
        default_full_scope
    };

    let extend_matches: &[String] = extend.map(|e| e.matches.as_ref()).unwrap_or_default();
    // check unused matches
    {
        let extended: HashSet<_> = extend_matches.iter().collect();
        let existing: HashSet<_> = exts.iter().collect();
        let unused: Vec<_> = extended.intersection(&existing).copied().cloned().collect();
        if !unused.is_empty() {
            eprintln!("{key}: unused extend.matches: {}", unused.join(", "));
        }
    }
    let matches = exts
        .iter()
        .chain(extend_matches.iter())
        .map(|e| ext_to_tag(e))
        .collect::<Vec<_>>()
        .join("|");

    TEMPLATE
        .trim_end()
        .replace("$NAME", key)
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
    let ext = ext.trim_start_matches('.');
    if let Some((first, _)) = ext.split_once('.') {
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
    ext.contains(' ')
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
