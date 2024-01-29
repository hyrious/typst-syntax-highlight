// SYNTAX TEST "Packages/Typst/Typst.sublime-syntax"

// foo
// ^ comment.line.double-dash

/**/
// <- comment.block.empty.typst punctuation.definition.comment.typst

// #24
/* multiline
// comment */
should stop here */
// ^^^^^^^^^^^^^^^^ comment.block.typst
//                 ^ - comment

// #28
/* multiline
/* nested */
comment */
//      ^^ comment.block.typst punctuation.definition.comment.end.typst

= Heading
// <- markup.heading.typst punctuation.definition.heading.begin.typst
// ^ markup.heading.typst - punctuation
 // <- - entity.name.section
//^^^^^^^ entity.name.section.typst
//       ^ meta.whitespace.newline.typst

  - foo
    - bar
    - buzz
//^ markup.list.unnumbered.typst
//  ^ markup.list.unnumbered.bullet.typst punctuation.definition.list_item.typst

foo\ bar
// ^ meta.hard-line-break.typst constant.character.escape.typst

foo *bar* _buzz_
//  ^^^^^ markup.bold.typst
//  ^ punctuation.definition.bold.begin.typst
//      ^ punctuation.definition.bold.end.typst
//        ^^^^^^ markup.italic.typst
//        ^ punctuation.definition.italic.begin.typst
//             ^ punctuation.definition.italic.end.typst

foo _*bar*_ _*buzz* buf_ zzz
//  ^^^^^^^ markup.italic.typst markup.bold.typst
//          ^^^^^^^ markup.italic.typst markup.bold.typst
//                  ^^^^ markup.italic.typst - markup.bold.typst

foo _bar_buzz_ buf
//  ^^^^^^^^^^ markup.italic.typst
//      ^ - punctuation.definition.italic

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

 #1
//^ meta.number.integer.decimal.typst constant.numeric.value.typst

 #0xff
//^^^^ meta.number.integer.hexadecimal.typst
//^^ constant.numeric.base.typst
//  ^^ constant.numeric.value.typst

 #0o10
//^^^^ meta.number.integer.octal.typst
//^^ constant.numeric.base.typst
//  ^^ constant.numeric.value.typst

 #0b1001
//^^^^^^ meta.number.integer.binary.typst
//^^ constant.numeric.base.typst
//  ^^^^ constant.numeric.value.typst

 #3.14
//^^^^ meta.number.float.decimal.typst constant.numeric.value.typst
// ^ punctuation.separator.decimal.typst

 #1e4
//^^^ meta.number.float.decimal.typst constant.numeric.value.typst

#rect(width: 72pt)
//           ^^^^ meta.number.integer.decimal.typst
//           ^^ constant.numeric.value.typst
//             ^^ constant.numeric.suffix.typst
//    ^^^^^ variable.parameter.typst
//         ^ punctuation.separator.parameter.typst

#rect(width: 254mm)
//           ^^^^^ meta.number.integer.decimal.typst
//           ^^^ constant.numeric.value.typst
//              ^^ constant.numeric.suffix.typst

#rect(width: 2.54cm)
//           ^^^^^^ meta.number.float.decimal.typst
//           ^^^^ constant.numeric.value.typst
//            ^ punctuation.separator.decimal.typst
//               ^^ constant.numeric.suffix.typst

#rect(width: 1in)
//           ^^^ meta.number.integer.decimal.typst
//           ^ constant.numeric.value.typst
//            ^^ constant.numeric.suffix.typst

#rect(width: 2.5em)
//           ^^^^^ meta.number.float.decimal.typst
//           ^^^ constant.numeric.value.typst
//            ^ punctuation.separator.decimal.typst
//              ^^ constant.numeric.suffix.typst

#rotate(180deg)[Hello there!]
//      ^^^^^^ meta.number.integer.decimal.typst
//      ^^^ constant.numeric.value.typst
//         ^^^ constant.numeric.suffix.typst

#rotate(3.14rad)[Hello there!]
//      ^^^^^^^ meta.number.float.decimal.typst
//      ^^^^ constant.numeric.value.typst
//       ^ punctuation.separator.decimal.typst
//          ^^^ constant.numeric.suffix.typst

#scale(x: 150%)[Scaled apart.]
//        ^^^^ meta.number.integer.decimal.typst
//        ^^^ constant.numeric.value.typst
//           ^ constant.numeric.suffix.typst

Left #h(1fr) Left-ish #h(2fr) Right
//      ^^^ meta.number.integer.decimal.typst
//      ^ constant.numeric.value.typst
//       ^^ constant.numeric.suffix.typst


$ sin pi => 0 $
//^^^^^^^^^^^^^ markup.math.typst
//^^^ support.function.math.typst
//    ^^ support.constant.greek.math.typst
//       ^^ constant.other.typst
//          ^ constant.numeric.value.typst
//            ^ markup.math.typst punctuation.definition.math.end.typst
// <- markup.math.typst punctuation.definition.math.begin.typst - markup.math markup.math

$ ( $
//   ^ - markup.math
$ frac(1, 2 $
//           ^ - markup.math

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
//^^^^^^^^^^^^^^^^ meta.expression.typst
//^ punctuation.definition.expression.typst
// ^^^ keyword.declaration.typst
//         ^ keyword.operator.typst
//           ^^^^^ string.quoted.double.typst
//           ^ punctuation.definition.string.begin.typst
//               ^ punctuation.definition.string.end.typst

#set heading(numbering: "I.")
//          ^^^^^^^^^^^^^^^^^ meta.function-call.arguments.typst
//           ^^^^^^^^^ variable.parameter.typst
//                    ^ punctuation.separator.parameter.typst
#lorem(30)
//    ^^^^ meta.function-call.arguments.typst

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

// #8
This text is properly syntaxed <<<

#h(1cm) foo ```js console.log(1) ```js console.log(2)
//          ^^^ punctuation.definition.raw.code-fence.begin.typst
//               ^^^^^^^^^^^^^^^^ markup.raw.block.javascript.typst source.js
//                               ^^^ punctuation.definition.raw.code-fence.end.typst

Evil purple now occurs <<<

// #16
  <label>
//^^^^^^^ storage.modifier.label.typst
//^ punctuation.definition.label.begin.typst
// ^^^^^ entity.name.label.typst
//      ^ punctuation.definition.label.end.typst

  @label
//^^^^^^ constant.other.reference.typst
//^ punctuation.definition.reference.typst
// ^^^^^ - punctuation 

$ F_n = round(1 / sqrt(5) phi.alt^n) $
//^ variable.other.math.typst
//  ^ variable.other.math.typst
//      ^^^^^ support.function.math.typst
//                        ^^^ support.constant.greek.math.typst

$ foo x $
//^^^ support.function.math.typst
//    ^ variable.other.math.typst

  #let name = "Typst"
//^^^^^^^^^^^^^^^^^^^ meta.expression.typst
//^ punctuation.definition.expression.typst
// ^^^ keyword.declaration.typst
This is #name's documentation.
//      ^^^^^ constant.other.symbol.typst
//      ^ punctuation.definition.variable.typst

  #include "bar.typ" as baz
//^ punctuation.definition.expression.typst
// ^^^^^^^ keyword.import.typst
//                   ^^ keyword.control.import.as.typst

// #17
#table(
  columns: (1fr, auto),
  [1],[stm32f10x_adc.c],
  //            ^ - punctuation.definition.italic
  [2],[stm32f10x_dma.c],
)

// #19
This is _emph_, This is not emph!
//      ^^^^^^ markup.italic.typst
//            ^ - markup.italic

This is *emph*, This is not emph!
//      ^^^^^^ markup.bold.typst
//            ^ - markup.bold

// #21
$#[Y] != #[X]$
//            ^ - markup.math

=== Sub section B

// #23
#counter(page).update(1).bar
//            ^ punctuation.accessor
//             ^^^^^^ support.function.typst
//                      ^ - support.function

// #27
#let f = {
  let a = 5
  [*bold* _italic_]
// ^^^^^^ markup.bold.typst
//        ^^^^^^^^ markup.italic.typst
}

// #29
#let f = (
  a-b, a- b, a -b
// ^ - keyword.operator.typst
//      ^ - keyword.operator.typst
//             ^ keyword.operator.typst
)

// #32
#{
  let show-one() = []
  let show-two = [asdf]
  //  ^^^^ - keyword.declaration.typst
  let three-show = [jkl]
  //        ^^^^ - keyword.declaration.typst
  let order = [#show-one()]
  let mhm = "?"
//^^^ keyword.declaration.typst
//          ^^^ string.quoted.double.typst
  mhm
}
// - meta.expression.typst
