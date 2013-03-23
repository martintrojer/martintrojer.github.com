---
layout: post
title: "Some more Datalog"
description: ""
category: clojure
tags: [clojure, datalog, datomic]
---
{% include JB/setup %}

I've [written about datalog](/clojure/2012/07/17/replicating-datomicdatalog-queries-with-corelogic-take-2/) and <a href="http://www.datomic.com">Datomic</a> a bit recently. To conclude here's another post comparing execution speed with the contrib.datalog library, by Jeffrey Straszheim. Clojure1.4 ready source can be found <a href="https://github.com/martintrojer/datalog">here</a>.

The example I'm using in my benchmark is a simple join between two relations, in datomic/datalog it would look like this; <script src="https://gist.github.com/3486837.js?file=query-datomic.clj"> </script>
In contrib.datalog the same query requires a bit more ceremony, you can write it like this; <script src="https://gist.github.com/3486837.js?file=query-datalog.clj"> </script> In my previous posts I described a number of different way to use core.logic, unify+clojure.set/join to replicate the same query. How does the execution times compare? I use the same benchmark as in the previous post (the same query, with 5000 joins between the 2 'tables').

Datomic/datalog is fastest by far needing ~11ms to complete. Second fastest is the unify + clojure.set/join solution [described here](/clojure/2012/07/16/replicating-datomicdatalog-queries-with-corelogic/) about an order of magnitude slower at ~150ms. The core.logic defrel/fact and contrib.datalog is about equal in speed at ~320ms, ie. 2x slower than unify+join and ~30x slower than datomic/datalog.

### Conclusion
My recent datalog posts focused on querying in-memoy data structures (like log rings etc). This is not exactly what Datomic was designed to do, still it's query engine performs really well. An added bonus is that it's low on ceremony. The recently announced Datomic free edition eradicates some of my initial fear of using it in my projects. The main drawback is that Datomic is closed sourced, even the free edition. Another detail that's annoying is that even if you're just after the datalog/query machinery -- by adding datomic-free, you pull in all of datomics 27 jar dependencies weighing in at 19Mb. That's quite a heavy tax on your uberjar. <br/><br/>There are certainly alternatives, like core.logic and contrib.datalog. But the order of magnitude worse execution time can be hard to live with if your datasets are big. By using datomic/datalog queries you also have the flexibility to move into disk-based databases if your datasets explodes. More on this in upcoming blog posts.

For completeness, here's the join-test function I used for the contrib.datalog benchmark; <script src="https://gist.github.com/3486837.js?file=datalog-jointest.clj"> </script>
