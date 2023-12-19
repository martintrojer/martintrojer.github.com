---
categories:
- clojure
date: "2012-07-07T00:00:00Z"
description: ""
tags:
- clojure
- core.logic
title: N Queens with core.logic, take 1
---
{% include JB/setup %}

I've been "hammock-reading" the excellent <a href="http://mitpress.mit.edu/catalog/item/default.asp?ttype=2&amp;tid=10663">Reasoned Schemer</a> book the last couple of months, on my quest trying to develop a gut feel for when logic programming, as defined by miniKanren/core.logic, is applicable.

My first attempt is to apply it to a problem where (as it turns out) miniKanren isn't a good fit, <a href="http://en.wikipedia.org/wiki/Eight_queens_puzzle">n-queens</a>. What you really need for this, in logical programming world, for this problem is something called contraint logic programming (CLP) which is implemented (for example) in <a href="http://www.schemeworkshop.org/2011/papers/Alvis2011.pdf">cKanren</a>. The good people over at core.logic are working on integrating CLP and cKanren in core.logic <a href="https://github.com/clojure/core.logic/">in version 0.8</a>, so I intend to revisit this problem as that work progresses.

Let's have a crack at this problem anyway shall we? I've previously posted a [functional implementation on n-queens](/clojure/2012/03/25/enumerate-n-queens-solutions/) in Clojure, and it's both nice to read and fast. What would this look like using core.logic?

Here's the core function (in Clojure) which determines if 2 queens are threatening each other.
<script src="https://gist.github.com/3065962.js?file=safe.clj"> </script>
The main problem in core.logic is the subtraction operator, which cannot be applied to fresh variables. We need a goal that has all the subtraction algebra "mapped out" as associations, let's call it subo. If we had that, our safeo function could look like this;
<script src="https://gist.github.com/3065962.js?file=safeo.clj"> </script>
With subo (for a (range 2) subtraction) like this;
<script src="https://gist.github.com/3065962.js?file=def-subo.clj"> </script>
Fortunately this isn't too bad, since in the classic case we only need to subtract numbers in (range 8). We can write a macro that generates a subo for any range our heart desires.

Next up the associations for queen pieces. We can brute force this as well by writing safeo associations for each queen piece against each other and finally constraining each queen to a unique row. Typing it out for 4-queens would look something like this;
<script src="https://gist.github.com/3065962.js?file=run-4q.clj"> </script>
Please note that the y variables doesn't have to be fresh since they can only take one value (each queen is determined by an unique y variable).

Here's a complete listing to the whole thing, with an example of a 7-queens run;
<script src="https://gist.github.com/2196964.js?file=nqueens-cl.clj"> </script>
So how does it perform? Well, you guessed it, terribly. My previous [functional Clojure implementation](/clojure/2012/03/25/enumerate-n-queens-solutions/) finds all 4 solutions for 6-queens in ~7ms. The core.logic one above does it in ~6.5 seconds, 3 orders of magnitude, ouch!

It's quite possible that this brute force approach is a very inefficient way of solving n-queens using miniKanren. Maybe building / removing queens from solution lists are a better approach? Also, cKanren in core.logic promises much faster and cleaner solutions. Either way, I'll keep you posted...