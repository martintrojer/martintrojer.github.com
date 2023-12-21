---
categories:
- clojure
date: "2012-08-28T00:00:00Z"
description: ""
tags:
- clojure
- datalog
- datomic
title: Some more Datalog
---

I've [written about datalog](/clojure/2012/07/17/replicating-datomicdatalog-queries-with-corelogic-take-2/) and [Datomic](http://www.datomic.com) a bit recently. To conclude here's another post comparing execution speed with the contrib.datalog library, by Jeffrey Straszheim. Clojure1.4 ready source can be found [here](https://github.com/martintrojer/datalog).

The example I'm using in my benchmark is a simple join between two relations, in datomic/datalog it would look like this;
```clojure
(q '[:find ?first ?height
     :in $a $b
     :where [$a ?last ?first ?email] [$b ?email ?height]]
   [["Doe" "John" "jdoe@example.com"]
    ["Doe" "Jane" "jane@example.com"]]
   [["jane@example.com" 73]
    ["jdoe@example.com" 71]])
;; #<HashSet [["Jane" 73], ["John" 71]]>
```

In contrib.datalog the same query requires a bit more ceremony, you can write it like this;
```clojure
(def db-base (make-database
                 (relation :last-first-email [:last :first :email])
                 (relation :email-height [:email :height])))

(def db
  (add-tuples db-base
              [:last-first-email :last "Doe" :first "John" :email "jdoe@example.com"]
              [:last-first-email :last "Doe" :first "Jane" :email "jane@example.com"]
              [:email-height :email "jane@example.com" :height 73]
              [:email-height :email "jdoe@example.com" :height 71]))

(def rules (rules-set
            (<- (:first-height :first ?f :height ?h)
                (:last-first-email :last ?l :first ?f :email ?e)
                (:email-height :email ?e :height ?h))))

(def wp (build-work-plan
         rules
         (?- :first-height :first ?f :height ?h)))

(run-work-plan wp db {})
;; ({:height 73, :first "Jane"} {:height 71, :first "John"})
```

In my previous posts I described a number of different way to use core.logic, unify+clojure.set/join to replicate the same query. How does the execution times compare? I use the same benchmark as in the previous post (the same query, with 5000 joins between the 2 'tables').

Datomic/datalog is fastest by far needing ~11ms to complete. Second fastest is the unify + clojure.set/join solution [described here](/clojure/2012/07/16/replicating-datomicdatalog-queries-with-corelogic/) about an order of magnitude slower at ~150ms. The core.logic defrel/fact and contrib.datalog is about equal in speed at ~320ms, ie. 2x slower than unify+join and ~30x slower than datomic/datalog.

### Conclusion
My recent datalog posts focused on querying in-memoy data structures (like log rings etc). This is not exactly what Datomic was designed to do, still it's query engine performs really well. An added bonus is that it's low on ceremony. The recently announced Datomic free edition eradicates some of my initial fear of using it in my projects. The main drawback is that Datomic is closed sourced, even the free edition. Another detail that's annoying is that even if you're just after the datalog/query machinery -- by adding datomic-free, you pull in all of datomics 27 jar dependencies weighing in at 19Mb. That's quite a heavy tax on your uberjar. <br/><br/>There are certainly alternatives, like core.logic and contrib.datalog. But the order of magnitude worse execution time can be hard to live with if your datasets are big. By using datomic/datalog queries you also have the flexibility to move into disk-based databases if your datasets explodes. More on this in upcoming blog posts.

For completeness, here's the join-test function I used for the contrib.datalog benchmark;

```clojure
(defn join-test3 [xs ys]
  (let [db-base (make-database
                 (relation :last-first-email [:last :first :email])
                 (index :last-first-email :email)
                 (relation :email-height [:email :height])
                 (index :email-height :email))
        rules (rules-set
               (<- (:first-height :first ?f :height ?h)
                   (:last-first-email :last ?l :first ?f :email ?e)
                   (:email-height :email ?e :height ?h)))
        workplan (build-work-plan
                  rules
                  (?- :first-height :first ?f :height ?h))
        db (time (->> xs
                      (map (fn [[l f e]]
                             [:last-first-email :last l :first f :email e]))
                      (apply add-tuples db-base)))
        db (time  (->> ys
                       (map (fn [[e h]] [:email-height :email e :height h]))
                       (apply add-tuples db)))]
    (run-work-plan workplan db {})))
```
