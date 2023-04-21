// SYNTAX TEST "Packages/Typst/Typst.sublime-syntax"

// foo
// ^ comment.line.double-dash

/**/
// <- comment.block.empty.typ punctuation.definition.comment.typ

= Heading
// <- markup.heading.typ punctuation.definition.heading.begin.typ
// ^ markup.heading.typ - punctuation

  - foo
    - bar
    - buzz
//^ markup.list.unnumbered.typ
//  ^ markup.list.unnumbered.bullet.typ punctuation.definition.list_item.typ

foo\ bar
// ^ meta.hard-line-break.typ constant.character.escape.typ

foo*bar*_buzz_
// ^ markup.bold.typ punctuation.definition.bold.begin.typ
//  ^^^^ markup.bold.typ
//     ^ markup.bold.typ punctuation.definition.bold.end.typ
//      ^ markup.italic.typ punctuation.definition.italic.begin.typ
//       ^^^^^ markup.italic.typ
//           ^ punctuation.definition.italic.end.typ

foo_*bar*_buzz
// ^^^^^^^ markup.italic.typ
// ^ punctuation.definition.italic.begin.typ
//  ^^^^^ markup.bold.typ
//  ^ punctuation.definition.bold.begin.typ
//      ^ punctuation.definition.bold.end.typ
//       ^ punctuation.definition.italic.end.typ

```js
//^ punctuation.definition.raw.code-fence.begin.typ
// ^^ constant.other.language-name.typ
console.log(1)
```
//^ punctuation.definition.raw.code-fence.end.typ

`raw`
// <- markup.raw.inline.typ punctuation.definition.raw.begin.typ
//^^^ markup.raw.inline.typ
//  ^ punctuation.definition.raw.end.typ

link: https://example.org?a=%20b
//    ^^^^^^^^^^^^^^^^^^^^^^^^^^ markup.underline.link.typ

$ sin pi => 0 $
//^^^^^^^^^^^^^ markup.math.typ
//^^^ support.function.math.typ
//    ^^ keyword.other.greek.math.typ
//       ^^ constant.other.typ
//          ^ constant.numeric.math.typ
//            ^ markup.math.typ punctuation.definition.math.end.typ
// <- markup.math.typ markup.math.typ punctuation.definition.math.begin.typ
