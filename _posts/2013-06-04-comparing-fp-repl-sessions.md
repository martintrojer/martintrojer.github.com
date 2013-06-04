---
layout: post
title: "Comparing FP REPL Sessions"
description: ""
category: fsharp
tags: [scala, clojure, f#]
---
{% include JB/setup %}

Functional programming is great; higher-order functions, closures, immutable data-structures, lazy sequences etc.

Most languages comes with a REPL (or 'interactive' prompt), where you can play with these features at your leisure. Dynamically typed languages are a bit more convenient in the REPL, but not by as much as you might think. Also, F# type providers closes the gap even further.

Here's a typical, hit-a-JSON-endpoint-and-look-at-the-data session in Clojure;
<script src="https://gist.github.com/martintrojer/5704143.js?file=session.clj"> </script>
Nice, clean and very powerful, virtually zero ceremony. Doing the same in Scala, is just a little bit more awkward;
<script src="https://gist.github.com/martintrojer/5704143.js?file=session.scala"> </script>
Similar to Clojure but a bit more ceremony and type annotations.

Now, can we get closer to the ease of dynamic languages while staying strongly typed? What if the types sprinkled evenly in the Scala example could be inferred? Enter F# type providers;
<script src="https://gist.github.com/martintrojer/5704143.js?file=session.fs"> </script>

There you have it; the simplicity and succinctness of a dynamic language plus type safety with inferred types. Please note that the correct types are inferred in the final result.
