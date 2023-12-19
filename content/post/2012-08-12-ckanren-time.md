---
categories:
- clojure
date: "2012-08-12T00:00:00Z"
description: ""
tags:
- clojure
- core.logic
title: cKanren time!
---
{% include JB/setup %}

Mr David Nolen recently published core.logic 0.8.alpha2, with added cKanren (c for constraints) support. To celebrate this glorious event I'm writing up some core.logic/cKanren stuff I've been looking at recently.

### Enter the Queens
If you've followed this blog, you've perhaps seen my previous posts on solving N-Queens in core.logic ([part1](/clojure/2012/07/16/replicating-datomicdatalog-queries-with-corelogic/) and [part2](/clojure/2012/07/17/replicating-datomicdatalog-queries-with-corelogic-take-2/)). How will this look and perform using the new shiny cKanren extensions in core.logic 0.8? Obviously there are many (new) ways to solve this problem, here's a core.logic-irized version of the solution described in the <a href="http://www.schemeworkshop.org/2011/papers/Alvis2011.pdf">cKanren paper</a> (please read paragraph 4.2 for an in-depth explanation);
<script src="https://gist.github.com/3240455.js?file=queens.clj"> </script>distinctfd (with infd) is a really nice addition to core.logic, they really help me personally write logic programs. How does this code perform? It's very similar in speed compared to the (non-fd) core.logic solution described in my [previous posting](/clojure/2012/07/17/replicating-datomicdatalog-queries-with-corelogic-take-2/), not bad, all extra cKanren expressive power without any performance drop!

### Sudoku time
How would you use core.logic to solve sudoku? Let's start by looking at a simple all-Clojure functional solution; <script src="https://gist.github.com/3229357.js?file=sud.clj"> </script>A few things are worth mentioning. First, this code finds all (potential) solutions of a given board layout. This is a bit strange since a true sudoku board should only have one solution! This does make it a bit more similar to logic programs (which typically looks for many solutions), and gives you some nice perks; you can use this code to check if a given puzzle is indeed a true puzzle. Secondly, in order to terminate faster, this snippet uses a quite common sudoku heuristic called "most constrained". At each level of the backtracking search it will consider the open squares in order, sorted after the least possible numbers (i.e. most constrained first). This helps to "fail fast" and minimise the dead alleys we recursively search.<br />

How would we do this in cKanren? As we'd expect the code comes very close the the definition of the rules; We have 9x9 squares, each square can contain a number from 1-9, the numbers in each row, column and 3x3 sub-square must be unique.

In this example I will use a 4x4 sudoku for simplicity. <script src="https://gist.github.com/3229357.js?file=sud4.clj"> </script>
That's it, exactly how the rules for sudoku was written, logic programming really is magical!

Writing it this way is good for understanding the solution, but not very practical for a real 9x9 board. Fortunately we can write some more helpers to make this compact, here's an example from Mr Nolen himself; <script src="https://gist.github.com/3229683.js?file=sud-cl.clj"> </script> This solution uses a "pseudo" goal call everyg with is similar to all-distincto in the previous example.

So how fast is this then? How does it stack up against the hand-rolled implementation above? Well, on an empty board (all squares open) the hand-rolled code finds 5 solutions in 400ms, while this code above get's into a (>5min) loop. For for more realistic "hard" boards the core.logic solution is on average 20x faster than the hand rolled code (much less temporary objects I recon). Finally, on really evil boards like this one, discovered by Peter Norvig; <script src="https://gist.github.com/3229357.js?file=evil-norvig.clj"> </script>the core.logic code terminates in ~6 seconds where as the hand rolled code loops forever (well, I gave up after 20 minutes).

### Conclusion
In most cases where "searching" is involved, I warmly recommend using core.logic. The expressive power makes for easy to read code, and the performance cost over hand rolled code is either not very significant or reverse (i.e. core.logic is faster). The new constraints primitives (cKanren) in core.logic-0.8 is a great addition to an already impressive library.

Some other stuff;

* The excellent <a href="http://www.schemeworkshop.org/2011/papers/Alvis2011.pdf">cKanren paper</a> is getting a bit obsolete. It's still a very good read, but for the latest innovation check out it's <a href="https://github.com/calvis/cKanren">github page</a>, and ofcourse core.logic.
* If you can't get enough of logic programming, the next step is to dip into the ocean of Prolog, there are plenty of awesome (and practical) books written over many years. Here's a <a href="http://dosync.posterous.com/a-logic-programming-reading-list">good list of books</a> to get you started
