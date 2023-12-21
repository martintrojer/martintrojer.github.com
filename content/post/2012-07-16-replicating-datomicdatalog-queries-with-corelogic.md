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

I've been toying with <a href="http://datomic.com/">Datomic </a>recently, and I particularly like the power of it's query language (~<a href="http://en.wikipedia.org/wiki/Datalog">Datalog</a>). Mr <a href="https://twitter.com/stuarthalloway">Halloway</a> showed a couple of months ago how the query engine is generic enough to be run on standard Clojure collections, <a href="https://gist.github.com/2645453">gist here</a>. Here is an example from that page of a simple join;

```clojure
(q '[:find ?first ?height
     :in [[?last ?first ?email]] [[?email ?height]]]
   [["Doe" "John" "jdoe@example.com"]
    ["Doe" "Jane" "jane@example.com"]]
   [["jane@example.com" 73]
    ["jdoe@example.com" 71]])
;; #<HashSet [["Jane" 73], ["John" 71]]>
```

A question you might ask yourself is how can I use <a href="https://github.com/clojure/core.logic">core.logic</a> to do the same kind of queries? It turns out that it's pretty straight forward, and also very fast. Core.logic provides some convenient helper functions for <a href="https://github.com/clojure/core.logic#unification">unification</a>, that we are going to use. Here's an example of how to get a binding map for some logical variables over a collection;

```clojure
(binding-map '(?first ?last) ["John" "Doe"])
;; {?last "Doe", ?first "John"}
```

Let's write a little helper function that maps binding-map over all elements of a seq (of tuples) (I'm using binding-map* so I only need to prep the rule once)

```clojure
(defn query [rule xs]
  (let [prule (prep rule)]
    (map #(binding-map* prule (prep %)) xs)))

(query '(?answer) (repeatedly 5 #(vector 42)))
;; ({?answer 42} {?answer 42} {?answer 42} {?answer 42} {?answer 42})
```

We can use clojure.set/join to perform the natural join of 2 sets of binding maps like so;

```clojure
(defn join-test [xs ys]
  (let [rx (query '(?last ?first ?email) xs)
        ry (query '(?email ?height) ys)
        r (clojure.set/join rx ry)]
    (map (juxt '?first '?height) r)))
```

Note that I also pick out just the first/height lvars here, this corresponds to the :find clause in the datomic query. That's it really, not as generic (and data driven) as the datomic query, but working;

```clojure
(join-test
 [["Doe" "John" "jdoe@example.com"]
  ["Doe" "Jane" "jane@example.com"]]
 [["jane@example.com" 73]
  ["jdoe@example.com" 71]])
;; (["John" 71] ["Jane" 73])
```

Here's the kicker, for this join query the datomic.api/q's time complexity estimates to O(n2) (actually 22n2-50n) where as the time complexity for core.logic/unify + clojure.set/join solution is O(n) (10n). That means that for a run over a modest dataset of size 5000 the **difference is 50x**!

_Edit_: The Datomic query used in the benchmark is not optimal as it turns out. In the example below you'll see a more optimal version that's infact ~18x faster than the core.logic + clojure.set/join solution.

```clojure
(defn bench [n f]
  (let [rand-str #(str (java.util.UUID/randomUUID))
        emails (repeatedly n rand-str)
        name-email (reduce (fn [res em]
                             (conj res (vector (rand-str) (rand-str) em)))
                           [] emails)
        email-height (reduce (fn [res em]
                               (conj res (vector em (rand-int 100))))
                             [] emails)]
    (time (count (f name-email email-height)))))


(bench 5000 (partial q '[:find ?first ?height
                         :in [[?last ?first ?email]] [[?email ?height]]]))
;; "Elapsed time: 14757.248824 msecs"
;; 5000

(bench 5000 join-test)
;; "Elapsed time: 185.604 msecs"
;; 5000

;; Optimised Datomic query
(bench 5000 (partial q '[:find ?first ?height
                         :in $a $b
                         :where [$a ?last ?first ?email] [$b ?email ?height]]))
;; "Elapsed time: 10.869 msecs"
;; 5000
```

Obviously this little example doesn't convey the true power of either datomic/datalog or core.logic/unifier. Be careful writing your Datomic queries, the running time can be vastly different!

<a href="https://gist.github.com/3122375">Here some more of the datomic queries converted in a similar fashion.</a>
