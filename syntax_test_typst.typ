// SYNTAX TEST "Packages/Typst/Typst.sublime-syntax"

// foo
// ^ comment.line.double-dash

/**/
// <- comment.block.empty.typst punctuation.definition.comment.typst

= Heading
// <- markup.heading.typst punctuation.definition.heading.begin.typst
// ^ markup.heading.typst - punctuation

  - foo
    - bar
    - buzz
//^ markup.list.unnumbered.typst
//  ^ markup.list.unnumbered.bullet.typst punctuation.definition.list_item.typst

foo\ bar
// ^ meta.hard-line-break.typst constant.character.escape.typst

foo*bar*_buzz_
// ^ markup.bold.typst punctuation.definition.bold.begin.typst
//  ^^^^ markup.bold.typst
//     ^ markup.bold.typst punctuation.definition.bold.end.typst
//      ^ markup.italic.typst punctuation.definition.italic.begin.typst
//       ^^^^^ markup.italic.typst
//           ^ punctuation.definition.italic.end.typst

foo_*bar*_buzz
// ^^^^^^^ markup.italic.typst
// ^ punctuation.definition.italic.begin.typst
//  ^^^^^ markup.bold.typst
//  ^ punctuation.definition.bold.begin.typst
//      ^ punctuation.definition.bold.end.typst
//       ^ punctuation.definition.italic.end.typst

```js
//^ punctuation.definition.raw.code-fence.begin.typst
// ^^ constant.other.language-name.typst
console.log(1)
```
//^ punctuation.definition.raw.code-fence.end.typst

`raw`
// <- markup.raw.inline.typst punctuation.definition.raw.begin.typst
//^^^ markup.raw.inline.typst
//  ^ punctuation.definition.raw.end.typst

link: https://example.org?a=%20b
//    ^^^^^^^^^^^^^^^^^^^^^^^^^^ markup.underline.link.typst

$ sin pi => 0 $
//^^^^^^^^^^^^^ markup.math.typst
//^^^ support.function.math.typst
//    ^^ keyword.other.greek.math.typst
//       ^^ constant.other.typst
//          ^ constant.numeric.typst
//            ^ markup.math.typst punctuation.definition.math.end.typst
// <- markup.math.typst markup.math.typst punctuation.definition.math.begin.typst
