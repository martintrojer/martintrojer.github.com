---
categories:
- clojure
date: "2012-07-17T00:00:00Z"
description: ""
tags:
- clojure
- datomic
- core.logic
title: Replicating Datomic/Datalog queries with core.logic, take 2
---
{% include JB/setup %}

This is a follow-up to my [previous post](/clojure//2012/07/16/replicating-datomicdatalog-queries-with-corelogic/) on datalog-equivalent queries in core.logic.

Here I present an alternate way to do the unification and join inside core.logic (without having to use clojure.set/join). It uses the the relationships / facts API in core logic, <a href="https://github.com/clojure/core.logic/wiki/Features">described here</a>. First let's consider this datomic query;<script src="https://gist.github.com/3122185.js?file=datomic-join.clj"> </script>
In core.logic we start by defining the relationships between our 2 datasets; <script src="https://gist.github.com/3123920.js?file=defrels.clj"> </script> This mirrors the layout of the data above. The actual datapoints are defined as facts, and once we have those we can do a core.logic run* using goals with the same name as our defrels; <script src="https://gist.github.com/3123920.js?file=facts-and-run.clj"> </script> The join is accomplished by using the same lvar (email) is both defrel goals.

Now consider a slightly more complicated query; <script src="https://gist.github.com/3123920.js?file=query-2dbs.clj"> </script> Applying the same technique (with some more defrels) we get; <script src="https://gist.github.com/3123920.js?file=2dbs-defrels.clj"> </script> Hmm, this looks suspiciously like a victim-of-a-macro(tm), maybe something like this; <script src="https://gist.github.com/3123920.js?file=defquery.clj"> </script> The two examples above can now be written like so; <script src="https://gist.github.com/3123920.js?file=defmacro-queries.clj"> </script> An important point here is that we have separated the definition of the relationships, definition (loading) of the facts, and the actual running of the query.

So how does this perform for larger datasets compared to the unification / clojure.set/join described in the previous post? If we look at the time for running the query it's ~33% faster and about 12x slower than the optimal datomic/datalog query.
<script src="https://gist.github.com/3123920.js?file=join-test2.clj"> </script>
<a href="https://gist.github.com/3150994">Follow this link for some more datalog-y queries in core.logic</a>.