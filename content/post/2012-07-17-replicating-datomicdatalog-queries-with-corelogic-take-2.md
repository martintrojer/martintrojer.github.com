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
This is a follow-up to my [previous post]({{< ref "2012-07-16-replicating-datomicdatalog-queries-with-corelogic.md" >}}) on datalog-equivalent queries in core.logic.

Here I present an alternate way to do the unification and join inside core.logic (without having to use clojure.set/join). It uses the the relationships / facts API in core logic, [described here](https://github.com/clojure/core.logic/wiki/Features). First let's consider this datomic query;

```clojure
(q '[:find ?first ?height
     :in [[?last ?first ?email]] [[?email ?height]]]
   [["Doe" "John" "jdoe@example.com"]
    ["Doe" "Jane" "jane@example.com"]]
   [["jane@example.com" 73]
    ["jdoe@example.com" 71]])
;; #<HashSet [["Jane" 73], ["John" 71]]>
```

In core.logic we start by defining the relationships between our 2 datasets;

```clojure
(defrel last-first-email p1 p2 p3)
(defrel email-height p1 p2)
```

This mirrors the layout of the data above. The actual datapoints are defined as facts, and once we have those we can do a core.logic run* using goals with the same name as our defrels;

```clojure
(fact last-first-email "Doe" "John" "jdoe@example.com")
(fact last-first-email "Doe" "Jane" "jane@example.com")
(fact email-height "jane@example.com" 73)
(fact email-height "jdoe@example.com" 71)
(run* [q]
      (fresh [fst email height]
             (last-first-email (lvar) fst email)
             (email-height email height)
             (== q [fst height])))
;; (["Jane" 73] ["John" 71])
```

The join is accomplished by using the same lvar (email) is both defrel goals.

Now consider a slightly more complicated query;

```clojure
;; simple in-memory join, two database bindings
(q '[:find ?first ?height
     :in $db1 $db2
     :where [$db1 ?e1 :firstName ?first]
            [$db1 ?e1 :email ?email]
            [$db2 ?e2 :email ?email]
            [$db2 ?e2 :height ?height]]
   [[1 :firstName "John"]
    [1 :email  "jdoe@example.com"]
    [2 :firstName "Jane"]
    [2 :email "jane@example.com"]]
   [[100 :email "jane@example.com"]
    [100 :height 73]
    [101 :email "jdoe@example.com"]
    [101 :height 71]])
;; #<HashSet [["Jane" 73], ["John" 71]]>
```


Applying the same technique (with some more defrels) we get;

```clojure
(do
  (defrel id-first p1 p2)
  (defrel id-email p1 p2)
  (defrel id2-email p1 p2)
  (defrel id2-height p1 p2)
  (fact id-first 1 "John")
  (fact id-email 1 "jdoe@example.com")
  (fact id-first 2 "Jane")
  (fact id-email 2 "jane@example.com")
  (fact id2-email 100 "jane@example.com")
  (fact id2-height 100 73)
  (fact id2-email 101 "jdoe@example.com")
  (fact id2-height 101 71)
  (run* [q]
        (fresh [id id2 fst email height]
               (id-first id fst)
               (id-email id email)
               (id2-email id2 email)
               (id2-height id2 height)
               (== q [fst height]))))
;; (["John" 71] ["Jane" 73])
```

Hmm, this looks suspiciously like a victim-of-a-macro(tm), maybe something like this;

```clojure
(defmacro defquery [relname find rels]
  (let [idx-syms (->> (repeatedly gensym) (map #(with-meta % {:index :t})))
        relname (fn [r] (symbol (str relname "-" (->> r (map name) (interpose "-") (reduce str)))))
        lvars (fn [r] (->> r (map name) (map symbol)))
        defrels (for [r rels] `(defrel ~(relname r) ~@(take (count r) idx-syms)))
        joins (for [r rels] `(~(relname r) ~@(lvars r)))]
    `(do
       ~@defrels
       (defn ~(relname [:run]) []
         (run* [q#]
               (fresh [~@(set (mapcat lvars rels))]
                      ~@joins
                      (== q# [~@(lvars find)])))))))
```

The two examples above can now be written like so;

```clojure
(do
  (defquery join [:first :height] [[:last :first :email] [:email :height]])
  (fact join-last-first-email "Doe" "John" "jdoe@example.com")
  (fact join-last-first-email "Doe" "Jane" "jane@example.com")
  (fact join-email-height "jane@example.com" 73)
  (fact join-email-height "jdoe@example.com" 71)
  (join-run))
;; (["Jane" 73] ["John" 71])

(do
  (defquery join2 [:firstName :height] [[:e1 :firstName] [:e1 :email] [:e2 :email] [:e2 :height]])
  (fact join2-e1-firstName 1 "John")
  (fact join2-e1-email 1 "jdoe@example.com")
  (fact join2-e1-firstName 2 "Jane")
  (fact join2-e1-email 2 "jane@example.com")
  (fact join2-e2-email 100 "jane@example.com")
  (fact join2-e2-height 100 73)
  (fact join2-e2-email 101 "jdoe@example.com")
  (fact join2-e2-height 101 71)
  (join2-run))
;; (["John" 71] ["Jane" 73])
```


An important point here is that we have separated the definition of the relationships, definition (loading) of the facts, and the actual running of the query.

So how does this perform for larger datasets compared to the unification / clojure.set/join described in the previous post? If we look at the time for running the query it's ~33% faster and about 12x slower than the optimal datomic/datalog query.
```clojure
(defn join-test2 [xs ys]
  ;; setup the relations
  (defquery join [:first :height] [[:last :first :email] [:email :height]])
  ;; load the facts
  (time
   (do
     (doseq [x xs] (apply fact join-last-first-email x))
     (doseq [y ys] (apply fact join-email-height y))))
  ;; run the query
  (time
   (join-run)))

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

(bench 5000 join-test2)
;; "Elapsed time: 287.275 msecs"       (loading the data)
;; "Elapsed time: 127.188 msecs"       (running the query)
;; "Elapsed time: 415.466 msecs"       (total)
;; 5000

;; ===================================================
;; Results from previous post

(bench 5000 (partial q '[:find ?first ?height
                         :in [[?last ?first ?email]] [[?email ?height]]]))
;; "Elapsed time: 14757.248824 msecs"
;; 5000

(bench 5000 (partial q '[:find ?first ?height
                         :in $a $b
                         :where [$a ?last ?first ?email] [$b ?email ?height]]))
;; "Elapsed time: 10.869 msecs"
;; 5000

(bench 5000 join-test)
;; "Elapsed time: 185.604 msecs"
;; 5000
```

[Follow this link for some more datalog-y queries in core.logic](https://gist.github.com/3150994).
