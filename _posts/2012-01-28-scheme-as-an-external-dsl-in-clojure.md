---
layout: post
title: "Scheme as an external DSL in Clojure"
description: ""
category: clojure
tags: [clojure, f#, lisp, sicp]
---
{% include JB/setup %}

This is a follow-up post to my previous ["Scheme in Clojure" post](/clojure/2011/11/29/scheme-as-an-embedded-dsl-in-clojure/).

This time we implement a Scheme interpreter as an external DSL. This means that we consider the DSL as completely foreign to the host language, so we need to write our own parser (or reader as it's called in Clojure) and interpreter. I have to admit that this is a bit of an academic exercise because the internal DSL version I wrote about previously is both smaller (less code) and faster (as fast as any other Clojure code). However, this can serve as an example of how to write parsers in Clojure and it also highlights how elegant and succinct such a parser/interpreter can be. And of course, it's pretty darn fun :-)

All source code is available on <a href="https://github.com/martintrojer/scheme-clojure">github</a>.

### Parsing
The reader is made up of two parts; a tokenizer and a parser.

The <a href="https://github.com/martintrojer/scheme-clojure/blob/master/external/src/mtscheme/parser.clj#L5">tokenizer</a> reads a string and produces a list of tokens. I use a "tagged list" as described by Abelson / Sussman in <a href="http://mitpress.mit.edu/sicp/">SICP</a> to distinguish between the types of tokens. This is a flexible technique for dynamic languages where we can't express <a href="https://github.com/martintrojer/scheme-fsharp/blob/master/parser.fs#L14">token types like we can in a typed language like F#</a>. Here is an example;
<script src="https://gist.github.com/1694263.js?file=token-example.clj"> </script>
Next up is the <a href="https://github.com/martintrojer/scheme-clojure/blob/master/external/src/mtscheme/parser.clj#L54">parser</a> which takes the list of tokens as input and produces a list of expressions (or combinations as they are called in SICP). Please note that the parse functions in this example first calls tokenize on the provided string.
<script src="https://gist.github.com/1694263.js?file=parsing-example.clj"> </script>
One big benefit of parsing a "simple" language like a Lisp is how clean and simple the parser becomes. The whole thing is about 50 lines of code, and very elegantly expressed in Clojure (if you ask me :-).

Both the parser and interpreter relies heavily on Clojure's "destructing" feature to pick elements out of strings, lists etc. This is loosely related to pattern matching found in other languages (or in Clojure via <a href="https://github.com/clojure/core.match">core.match</a> for instance). In my <a href="http://martinsprogrammingblog.blogspot.com/2011/11/scheming-in-f.html">F# implementation</a> of the Scheme interpreter, it's indeed this destructing feature of it's pattern matching I rely most on. Here is an example of extracting the head and tail (which happens to be the operator and it's arguments!) of a combination returned by the parser; <script src="https://gist.github.com/1694263.js?file=destruct.clj"> </script>

### Eval-ing
Now that we have our list of expressions we can evaluate it (or run it). I use the mutually recursive eval/apply as described in SICP. Everytime I write this I am amazed by how simple yet powerful this is, here it is in all it's glory;
<script src="https://gist.github.com/1694263.js?file=eval-apply.clj"> </script>
One trick I use is to store all built-in functions (as closures) in an environment map. So when we evaluate a combination like \[:+ 1 1\] the head of that vector (:+) is looked up in the environment and a fn is returned and punted over to apply.&nbsp;User defined functions are represented by lists in the environment and become a separate cond-case in the code above.

In the interpreter then environment is a stack of maps, with <a href="https://github.com/martintrojer/scheme-clojure/blob/master/external/src/mtscheme/interpreter.clj#L226">"roots" at the bottom</a> containing all the built-in functions. When evaluating a let statement for instance, the locals are added to a new environment map at the top of the stack, in this way bindings can be overloaded in the local context. This is also how the arguments to functional calls are bound (and how recursion can terminate).

The bulk of the interpreter code is the implementations of the built-in functions, but then again none of them are especially large. All in all the interpreter clocks in at about 200 lines, giving us an entire solution (parser, interpreter and all) in about 300 lines!

### Conclusion
Even though we wrote an entire tokenizer/parser/evaluator it ended up a small and readable. It's quite a bit smaller than the F# implementation, mainly because of the lack of any type declarations. How fast is it though? The embedded DSL implementation runs (fact 10) about 1.5 times faster than the external one. The F# version runs roughly as fast as the Clojure embedded one although is doing much more work (running interpreted).
<script src="https://gist.github.com/1694263.js?file=repl-example.clj"> </script>
