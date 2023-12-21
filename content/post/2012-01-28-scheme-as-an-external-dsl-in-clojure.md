---
categories:
- clojure
date: "2012-01-28T00:00:00Z"
description: ""
tags:
- clojure
- f#
- lisp
- sicp
title: Scheme as an external DSL in Clojure
---

This is a follow-up post to my previous ["Scheme in Clojure" post](/clojure/2011/11/29/scheme-as-an-embedded-dsl-in-clojure/).

This time we implement a Scheme interpreter as an external DSL. This means that we consider the DSL as completely foreign to the host language, so we need to write our own parser (or reader as it's called in Clojure) and interpreter. I have to admit that this is a bit of an academic exercise because the internal DSL version I wrote about previously is both smaller (less code) and faster (as fast as any other Clojure code). However, this can serve as an example of how to write parsers in Clojure and it also highlights how elegant and succinct such a parser/interpreter can be. And of course, it's pretty darn fun :-)

All source code is available on <a href="https://github.com/martintrojer/scheme-clojure">github</a>.

### Parsing
The reader is made up of two parts; a tokenizer and a parser.

The <a href="https://github.com/martintrojer/scheme-clojure/blob/master/external/src/mtscheme/parser.clj#L5">tokenizer</a> reads a string and produces a list of tokens. I use a "tagged list" as described by Abelson / Sussman in <a href="http://mitpress.mit.edu/sicp/">SICP</a> to distinguish between the types of tokens. This is a flexible technique for dynamic languages where we can't express <a href="https://github.com/martintrojer/scheme-fsharp/blob/master/parser.fs#L14">token types like we can in a typed language like F#</a>. Here is an example;

```clojure
(tokenize "(foo)")
  --> [[:open] [:symbol "foo"] [:close]]
(tokenize "\"foo\"")
  --> [[:string "foo"]]
(tokenize "12")
  --> [[:symbol "12"]]
```

Next up is the <a href="https://github.com/martintrojer/scheme-clojure/blob/master/external/src/mtscheme/parser.clj#L54">parser</a> which takes the list of tokens as input and produces a list of expressions (or combinations as they are called in SICP). Please note that the parse functions in this example first calls tokenize on the provided string.


```clojure
(parse-all "foo bar")
  --> [:foo :bar]
(parse "12")
  --> 12.0
(parse "(+ 1 a)")
  --> [:+ 1.0 :a]
```

One big benefit of parsing a "simple" language like a Lisp is how clean and simple the parser becomes. The whole thing is about 50 lines of code, and very elegantly expressed in Clojure (if you ask me :-).

Both the parser and interpreter relies heavily on Clojure's "destructing" feature to pick elements out of strings, lists etc. This is loosely related to pattern matching found in other languages (or in Clojure via <a href="https://github.com/clojure/core.match">core.match</a> for instance). In my <a href="http://martinsprogrammingblog.blogspot.com/2011/11/scheming-in-f.html">F# implementation</a> of the Scheme interpreter, it's indeed this destructing feature of it's pattern matching I rely most on. Here is an example of extracting the head and tail (which happens to be the operator and it's arguments!) of a combination returned by the parser;

```clojure
(let [[fst & rst] (parse "(+ 1 1)")]
 [fst rst])
  --> [:+ (1.0 1.0)]
```

### Eval-ing
Now that we have our list of expressions we can evaluate it (or run it). I use the mutually recursive eval/apply as described in SICP. Everytime I write this I am amazed by how simple yet powerful this is, here it is in all it's glory;

```clojure
(defn _eval [exp env]
  (cond
   ; self-evaluating?
   (or (number? exp) (string? exp) (fn? exp)) [exp env]

   ; var reference to be looked up in env
   (keyword? exp) [(lookup exp env) env]

   ; parsed combinations (function calls)
   (vector? exp) (let [[fst & rst] exp
                       [r e] (_eval fst env)]
                   (cond
                    ; built-in function calls
                    (fn? r) (_apply r rst e)
                    ; user defined function/lambda calls
                    (list? r) (let [[args body] r
                                    n (zipmap args (map #(get-evval % e) rst))
                                    new-env (cons n e)]
                                (_eval body new-env))  ; eval the first form only
                    :else [exp env]))
   :else (throw (Exception. (format "invalid interpreter state %s %s" (str exp) (str env))))))

(defn _apply [f args env]
  (f args env))
```

One trick I use is to store all built-in functions (as closures) in an environment map. So when we evaluate a combination like \[:+ 1 1\] the head of that vector (:+) is looked up in the environment and a fn is returned and punted over to apply.&nbsp;User defined functions are represented by lists in the environment and become a separate cond-case in the code above.

In the interpreter then environment is a stack of maps, with <a href="https://github.com/martintrojer/scheme-clojure/blob/master/external/src/mtscheme/interpreter.clj#L226">"roots" at the bottom</a> containing all the built-in functions. When evaluating a let statement for instance, the locals are added to a new environment map at the top of the stack, in this way bindings can be overloaded in the local context. This is also how the arguments to functional calls are bound (and how recursion can terminate).

The bulk of the interpreter code is the implementations of the built-in functions, but then again none of them are especially large. All in all the interpreter clocks in at about 200 lines, giving us an entire solution (parser, interpreter and all) in about 300 lines!

### Conclusion
Even though we wrote an entire tokenizer/parser/evaluator it ended up a small and readable. It's quite a bit smaller than the F# implementation, mainly because of the lack of any type declarations. How fast is it though? The embedded DSL implementation runs (fact 10) about 1.5 times faster than the external one. The F# version runs roughly as fast as the Clojure embedded one although is doing much more work (running interpreted).

```clojure
$ java -jar mtscheme-0.0.1-SNAPSHOT-standalone.jar
mtscheme 0.1
nil
=> (define (foreach f l) (if (not (null? l)) (begin (f (car l)) (foreach f (cdr l)))))
nil
=> (foreach display (list 1 2 3))
1.0
2.0
3.0
nil
=>
```
