---
layout: post
title: "Scheming in F#"
description: ""
category:
tags: [f#, sicp]
---
{% include JB/setup %}

Given the fact that I worship at the <a href="http://mitpress.mit.edu/sicp/">SICP</a> altar, it should come as no surprise that I follow the recipe outlined in chapter 4 of said book; implementing a <a href="http://en.wikipedia.org/wiki/Scheme_(programming_language)">Scheme</a> interpreter in every language I am trying to learn. Over the years it has turned out to be a very useful exercise, since the problem is just "big enough" for to force me to drill into what the language have to offer.

I'll post the source of the interpreters on <a href="https://github.com/martintrojer/">github</a> in this and future posts and highlight some of my findings in more detail in the posts. I am not going to write and explain too much about the languages themselves, there are plenty of books and tutorials for that purpose, just highlights :)

F# is part of the <a href="http://en.wikipedia.org/wiki/ML_(programming_language)">ML</a> family and largely compatible with OCaml. It's one of the new hybrid functional / OO languages (like Scala, Clojure etc) that the kids are raving about these days. This means it can expose and interact with .NET libraries and objets code seamlessly. It also have a whole host of other functionality like active patterns, asynchronous workflows and (soon) type providers that I will get back to in future posts.

Let's start with discriminated unions which is a very powerful way of concisely describing (in this case) the syntax of the language;
<script src="https://gist.github.com/1695088.js?file=types.fs"> </script>

This is means what it reads, "a scheme expression is either empty or a list of expressions or a list of listtypes or ...". It really can't be any clearer than that now can it?

ML's pattern matching is just fantastic when writing parsers, well any code really. This is how the evaluator of Expressions look like;
<script src="https://gist.github.com/1695088.js?file=eval-apply.fs"> </script>

This is the famous recursive eval/appy loop as described in SICP. Of all the languages I've written this in, nothing is as concise and readable as ML. The main match statement is basically a switch, but there are a few subtleties here. For instance the Combination matches have a nested pattern separating the empty (\[\]) case and list (head::tail) case.

The interactive Read-Eval-Print-Loop (REPL) also deserves a shout out, this is using the F# pipe operator that passes the result of a function to the (last) parameter of another.
<script src="https://gist.github.com/1695088.js?file=repl.fs"> </script>
So that try/catch is basically saying;
1. read a line from the console
2. >convert it to a list
3. parse that list
4. take the head (first element) of the list (this is the expression)
5. evaluate it
6. call itself recursively

Please note that the new environment map is passed as parameter in the loop, meaning it can be immutable!

All the code can be found <a href="https://github.com/martintrojer/scheme-fsharp">here</a>, there are few bugs (see failing tests) that I might fix later, or maybe you are up for it! :)
<script src="https://gist.github.com/1695088.js?file=repl-example"> </script>