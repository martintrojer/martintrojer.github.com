---
layout: post
title: "Untying the Recursive Knot"
description: ""
category:
tags: [clojure]
---
{% include JB/setup %}

Here I present a couple of examples of the functional design pattern "untying the recursive knot". I've found this useful in a couple of occasions, for instance when breaking apart mutually recursive functions. Material inspired by Jon Harrop's excellent <a href="http://www.ffconsultancy.com/products/fsharp_for_technical_computing/">Visual F# to Technical Computing</a>.

First, let's look at a simple factorial implementation using direct recursion;
<script src="https://gist.github.com/3163126.js?file=fact.clj"> </script> We can break the direct recursive dependency by replacing the recursive calls with calls to a function argument;
<script src="https://gist.github.com/3163126.js?file=fact'.clj"> </script> We have now broken the recursive knot! The functionality can be recovered by tying the recursive knot using the following y combinator; <script src="https://gist.github.com/3163126.js?file=y-comb.clj"> </script>For example;<script src="https://gist.github.com/3163126.js?file=y-fact.clj"> </script>This has given us extra power, we may for instance inject new functionality into every invocation without touching the original definition;<script src="https://gist.github.com/3163126.js?file=y-fact-extra.clj"> </script>Now for a more practical example when we have mutually recursive functions; <script src="https://gist.github.com/3163126.js?file=odd-even.clj"> </script> We can break these functions apart using the same strategy as with fact' above;<script src="https://gist.github.com/3163126.js?file=odd'-even'.clj"> </script> Please note that the (declare ...) form is no longer required. The functions are now entirely independent and could live in different namespaces.

Using the same y combinator above, we can get back to the original functionalty;<script src="https://gist.github.com/3163126.js?file=odd-even-y.clj"> </script>A handy pattern to add to your functional toolbox.