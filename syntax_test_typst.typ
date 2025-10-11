// SYNTAX TEST "Packages/Typst/Typst.sublime-syntax"

// foo
// ^ comment.line.double-dash

/**/
// <- comment.block.empty.typst punctuation.definition.comment.typst

// #41
// Nested "//" doesn't count as line comment.
/* // */
//      ^ - comment

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

$ x_1, x^1, x_1.23, x^1.23 $
//  ^ meta.number.integer.decimal.typst constant.numeric.value.typst
//       ^ meta.number.integer.decimal.typst constant.numeric.value.typst
//            ^^^^ meta.number.float.decimal.typst constant.numeric.value.typst
//                    ^^^^ meta.number.float.decimal.typst constant.numeric.value.typst

#rect(width: 72pt)
//   ^^^^^^^^^^^^^ meta.function-call.arguments.typst
//   ^ punctuation.section.group.begin.typst
//    ^^^^^ variable.parameter.typst
//         ^ punctuation.separator.parameter.typst
//           ^^^^ meta.number.integer.decimal.typst
//           ^^ constant.numeric.value.typst
//             ^^ constant.numeric.suffix.typst
//               ^ punctuation.section.group.end.typst
//                ^ - meta.function-call.arguments

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
//^^^ support.constant.math.operator.typst
//    ^^ support.constant.sym.greek.typst
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
//   ^^^^^^^ - meta.function-call.arguments
//          ^^^^^^^^^^^^^^^^^ meta.function-call.arguments.typst
//          ^ punctuation.section.group.begin.typst
//           ^^^^^^^^^ variable.parameter.typst
//                    ^ punctuation.separator.parameter.typst
//                          ^ punctuation.section.group.end.typst
//                           ^ - meta.function-call.arguments

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

  @
//^ punctuation.definition.reference.typst

$ F_n = round(1 / sqrt(5) phi.alt^n) $
//^ variable.other.math.typst
// ^ keyword.operator.math.typst
//  ^ variable.other.math.typst
//    ^ constant.other.typst
//      ^^^^^ support.function.math.typst
//           ^ punctuation.section.group.begin.typst
//            ^ meta.number.integer.decimal.typst constant.numeric.value.typst
//              ^ keyword.operator.math.typst
//                ^^^^ support.function.math.typst
//                    ^ punctuation.section.group.begin.typst
//                     ^ meta.number.integer.decimal.typst constant.numeric.value.typst
//                      ^ punctuation.section.group.end.typst
//                        ^^^ support.constant.sym.greek.typst
//                           ^ punctuation.accessor.dot.typst
//                            ^^^ support.constant.sym.modifier.typst
//                               ^ keyword.operator.math.typst
//                                ^ variable.other.math.typst
//                                 ^ punctuation.section.group.end.typst

$ tilde(phi.alt) $
//^^^^^ support.function.math.typst - meta.function-call.arguments
//     ^ punctuation.section.group.begin.typst
//      ^^^ support.constant.sym.greek.typst
//         ^ punctuation.accessor.dot.typst
//          ^^^ support.constant.sym.modifier.typst
//             ^ punctuation.section.group.end.typst

$ tilde (phi.alt) $
//^^^^^ support.constant.sym.typst
//      ^ constant.character.parenthesis.typst
//       ^^^ support.constant.sym.greek.typst
//          ^ punctuation.accessor.dot.typst
//           ^^^ support.constant.sym.modifier.typst
//              ^ constant.character.parenthesis.typst

$ phi.alt_i $
//^^^ support.constant.sym.greek.typst
//   ^ punctuation.accessor.dot.typst
//    ^^^ support.constant.sym.modifier.typst
//       ^ keyword.operator.math.typst
//        ^ variable.other.math.typst

$ tilde. $
//^^^^^ support.constant.sym.typst
//     ^ punctuation.accessor.dot.typst

$ tilde.eq. $
//^^^^^ support.constant.sym.typst
//     ^ punctuation.accessor.dot.typst
//      ^^ support.constant.sym.modifier.typst
//        ^ punctuation.accessor.dot.typst

$ tilde.eq.not $
//^^^^^ support.constant.sym.typst
//     ^ punctuation.accessor.dot.typst
//      ^^ support.constant.sym.modifier.typst
//        ^ punctuation.accessor.dot.typst
//         ^^^ support.constant.sym.modifier.typst

$ tilde.not.eq $
//^^^^^ support.constant.sym.typst
//     ^ punctuation.accessor.dot.typst
//      ^^^ support.constant.sym.modifier.typst
//         ^ punctuation.accessor.dot.typst
//          ^^ support.constant.sym.modifier.typst

$ tilde.foo $
//      ^^^ - support

$ 2pi $
//^ constant.numeric.value.typst
// ^^ support.constant.sym.greek.typst

$ frac(x, y) $
//^^^^ support.function.math.typst
//    ^ punctuation.section.group.begin.typst
//     ^ variable.other.math.typst
//      ^ punctuation.separator.comma.typst
//        ^ variable.other.math.typst
//         ^ punctuation.section.group.end.typst

$ frac $
//^^^^ support.function.math.typst

$ foo(x) $
//^^^ variable.function.math.typst
//   ^ punctuation.section.group.begin.typst
//    ^ variable.other.math.typst
//     ^ punctuation.section.group.end.typst

$ foo (x) $
//^^^ variable.function.math.typst
//    ^ constant.character.parenthesis.typst
//     ^ variable.other.math.typst
//      ^ constant.character.parenthesis.typst

$ foo x $
//^^^ variable.function.math.typst
//    ^ variable.other.math.typst

$ foo1 $
//^^^^ variable.function.math.typst - constant.numeric

$ f(x) $
//^ variable.other.math.typst
// ^ constant.character.parenthesis.typst
//  ^ variable.other.math.typst
//   ^ constant.character.parenthesis.typst

$ phi(x) $
//^^^ support.constant.sym.greek.typst
//   ^ constant.character.parenthesis.typst
//    ^ variable.other.math.typst
//     ^ constant.character.parenthesis.typst

$ sum_(i=1)^(N-1) x_i $
//    ^ punctuation.section.group.begin.typst
//      ^ constant.other.typst - keyword.operator
//        ^ punctuation.section.group.end.typst
//          ^ punctuation.section.group.begin.typst
//              ^ punctuation.section.group.end.typst

$ mat(1, 2; 3, 4; delim: "[") $
//   ^^^^^^^^^^^^^^^^^^^^^^^^ meta.function-call.arguments.typst
//                ^^^^^ variable.parameter.typst
//                     ^ punctuation.separator.key-value.typst
//                           ^ - meta.function-call.arguments

$ mat(1, ..., n; 1, ..., n) $
//       ^^^ constant.other.typst - keyword.operator.range

$ ) $
//^ constant.character.parenthesis.typst

$ bold(u): Omega -> RR^d, quad p: Omega -> RR $
//       ^ punctuation.separator.colon.typst
//                      ^ punctuation.separator.comma.typst
//                        ^^^^ support.constant.math.typst

  #sym.phi.alt
//^ punctuation.definition.expression.typst
// ^^^ support.module.sym.typst
//    ^ punctuation.accessor.dot.typst
//     ^^^ support.constant.sym.greek.typst
//        ^ punctuation.accessor.dot.typst
//         ^^^ support.constant.sym.modifier.typst

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
//            ^ punctuation.accessor.dot.typst
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
// ^ - meta.expression.typst

// #34
   / as.df jkl: asdf
// ^ markup.terms.typst punctuation.definition.term.typst
//   ^^^^^^^^^ markup.terms.typst entity.name.enum.typst
   // foo: bar
//    ^^^ - markup.terms.typst
   /* foo: bar */
//    ^^^ - markup.terms.typst

// #38
   / asdf\: asdf: asdf
// ^ markup.terms.typst punctuation.definition.term.typst
//       ^^ constant.character.escape.typst
//              ^ markup.terms.typst punctuation.separator.key-value.typst
   / asdf#emph[asdf]: asdf
// ^ markup.terms.typst punctuation.definition.term.typst
//       ^^^^^^^^^^^ meta.expression.typst
//                  ^ markup.terms.typst punctuation.separator.key-value.typst
   / #(a + b): buzz
//           ^ markup.terms.typst punctuation.separator.key-value.typst
//             ^^^^ - markup.terms.typst

// #39
asdf / asdf:
//   ^ - markup.terms.typst
   /asdf:
// ^ - markup.terms.typst

// #35
// https://laurmaedje.github.io/posts/types-and-context/
#set text(fill: context text.fill.darken(20%))
//              ^^^^^^^ keyword.declaration
   #context test(text.lang, "de")
//  ^^^^^^^ keyword.declaration
   #context {
//  ^^^^^^^ keyword.declaration
     test(type(rect.stroke), stroke)
     test(rect.stroke.paint, red)
   }

// #36
#let in-asdf = a in b
//   ^^ - keyword
#let and-asdf = a and b
//   ^^^ - keyword
#let not-asdf = not a
//   ^^^ - keyword
#let or-asdf = a or b
//   ^^ - keyword
#let in-asdf()
//   ^^ - keyword
#let and-asdf()
//   ^^^ - keyword

// #40
#"a,b;c".split(regex("\p{Greek}"))
//                    ^^^^^^^^^ string.regexp.typst
#show regex("[,;]{2}"): set text(red)
//           ^^^^^^^ string.regexp.typst
#regex(`\d+\.\d+(\.\d+)?`.text)
//      ^^^^^^^^^^^^^^^^ markup.raw.inline.typst string.regexp.typst

// #42
#let f() = {
  let a = ```rs
  fn main() -> Result<()> {}
  ```.text
//^^^ punctuation.definition.raw.code-fence.end.typst
//   ^ - raw.code-fence
  [Code: #a]
//       ^^ meta.expression.typst
}
// ^ - raw.code-fence, meta.expression.typst

// #43
#let x = f("hello", 1)
#let x = f("\"", 1)
#let x = f("she said \"cool\"", 1)
#let x = f("\\", 1)
#let x = f("\\\"", 1)
#let x = f("\\\\", 1)
//                   ^ - string
#let x = f("\\\\\\", 1)
#let x = f("\"\"", 1)
#let x = f("
  multi line \"string\"
  ending in slash \
", 1)\
//    ^ constant.character.escape.typst

// #48

```//```
// ^^ markup.raw.block.typst
//   ^ - comment
asdf
// ^ - comment

  `//asdf`
//^^^^^^^^ markup.raw.inline.typst
asdf
// ^ - comment

```js // comment```
//               ^ - comment
asdf
// ^ - comment

// #50
  #table(
    columns: 2,
    [A], [B],
    [C], [
      - item1
      - item2
    ]
//  ^ punctuation.section.group.end
  )
//^ punctuation.section.group.end
