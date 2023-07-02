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

// #5
#box()[
  #table( columns:(1fr,auto,auto),
    [#h(1cm) < this causes problems       ],[ as you can see  ],[ in the for below    ],
//  ^ punctuation.section.group.begin.typst
//                                        ^ punctuation.section.group.end.typst
    [#"hello world".split()],
)]
// <- punctuation.section.group.end.typst

for should not be highlighted here

  #let foo = "bar"
//^^^^^^^^^^^^^^^^ markup.other.typst
//^ punctuation.definition.script.begin.typst
// ^^^ storage.type.typst
//         ^ keyword.operator.typst
//           ^^^^^ string.quoted.double.typst
//           ^ punctuation.definition.string.begin.typst
//               ^ punctuation.definition.string.end.typst

// The doc on official readme.
#set page(width: 10cm, height: auto)
#set heading(numbering: "1.")

= Fibonacci sequence
The Fibonacci sequence is defined through the
recurrence relation $F_n = F_(n-1) + F_(n-2)$.
It can also be expressed in _closed form:_

$ F_n = round(1 / sqrt(5) phi.alt^n), quad
  phi.alt = (1 + sqrt(5)) / 2 $

#let count = 8
#let nums = range(1, count + 1)
#let fib(n) = (
  if n <= 2 { 1 }
  else { fib(n - 1) + fib(n - 2) }
)

The first #count numbers of the sequence are:

#align(center, table(
  columns: count,
  ..nums.map(n => $F_#n$),
  ..nums.map(n => str(fib(n))),
))

// #6
#let a-b(a, b) = a + b
//   ^^^ support.function.typst
#let a_b(a, b) = a * b
//   ^^^ support.function.typst
  #a-b(2, 3) #a-b
// ^^^ variable.function.typst
//           ^^^^ constant.other.symbol.typst
  #a_b(2, 3) #a_b
// ^^^ variable.function.typst
//           ^^^^ constant.other.symbol.typst

// #7
+ In list $cal(0)$

  Nested content... $E=m c^2$.
  $ T eq
  cases(
    delim: "{",
    1 & n lt.eq 1,
    2 T lr((log n)) plus 2^(log^ast n) & n gt 1
//        ^ punctuation.section.group.begin.typst
//         ^ constant.character.parenthesis.typst
//               ^ constant.character.parenthesis.typst
//                ^ punctuation.section.group.end.typst
  ) $

  and code

  ```py
  def find(arr: list):
    pass
  ```
