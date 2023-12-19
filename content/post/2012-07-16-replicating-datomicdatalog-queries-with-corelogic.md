---
categories:
- clojure
date: "2012-07-16T00:00:00Z"
description: ""
tags:
- clojure
- core.logic
- datomic
title: Replicating Datomic/Datalog queries with core.logic
---
{% include JB/setup %}

I've been toying with <a href="http://datomic.com/">Datomic </a>recently, and I particularly like the power of it's query language (~<a href="http://en.wikipedia.org/wiki/Datalog">Datalog</a>). Mr <a href="https://twitter.com/stuarthalloway">Halloway</a> showed a couple of months ago how the query engine is generic enough to be run on standard Clojure collections, <a href="https://gist.github.com/2645453">gist here</a>. Here is an example from that page of a simple join;
<script src="https://gist.github.com/3122185.js?file=datomic-join.clj"> </script>
A question you might ask yourself is how can I use <a href="https://github.com/clojure/core.logic">core.logic</a> to do the same kind of queries? It turns out that it's pretty straight forward, and also very fast. Core.logic provides some convenient helper functions for <a href="https://github.com/clojure/core.logic#unification">unification</a>, that we are going to use. Here's an example of how to get a binding map for some logical variables over a collection;
<script src="https://gist.github.com/3122185.js?file=binding-map.clj"> </script>
Let's write a little helper function that maps binding-map over all elements of a seq (of tuples) (I'm using binding-map* so I only need to prep the rule once)
<script src="https://gist.github.com/3122185.js?file=query.clj"> </script>
We can use clojure.set/join to perform the natural join of 2 sets of binding maps like so;
<script src="https://gist.github.com/3122185.js?file=join-test.clj"> </script>
Note that I also pick out just the first/height lvars here, this corresponds to the :find clause in the datomic query. That's it really, not as generic (and data driven) as the datomic query, but working;  <script src="https://gist.github.com/3122185.js?file=run-join-test.clj"> </script>
Here's the kicker, for this join query the datomic.api/q's time complexity estimates to O(n2) (actually 22n2-50n) where as the time complexity for core.logic/unify + clojure.set/join solution is O(n) (10n). That means that for a run over a modest dataset of size 5000 the **difference is 50x**!

_Edit_: The Datomic query used in the benchmark is not optimal as it turns out. In the example below you'll see a more optimal version that's infact ~18x faster than the core.logic + clojure.set/join solution.
<script src="https://gist.github.com/3122185.js?file=bench.clj"> </script>
Obviously this little example doesn't convey the true power of either datomic/datalog or core.logic/unifier. Be careful writing your Datomic queries, the running time can be vastly different!

<a href="https://gist.github.com/3122375">Here some more of the datomic queries converted in a similar fashion.</a>