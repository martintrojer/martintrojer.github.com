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

I've been "hammock-reading" the excellent [Reasoned Schemer](http://mitpress.mit.edu/catalog/item/default.asp?ttype=2&tid=10663) book these last couple of months, on my quest to develop a gut feel for when logic programming, as defined by miniKanren/core.logic, is applicable.

My first attempt is to apply it to a problem where (as it turns out) miniKanren isn't a good fit: [n-queens](http://en.wikipedia.org/wiki/Eight_queens_puzzle). What you really need for this problem in the logical programming world is something called constraint logic programming (CLP), which is implemented (for example) in [cKanren](http://www.schemeworkshop.org/2011/papers/Alvis2011.pdf). The good people at core.logic are working on integrating CLP and cKanren in core.logic [in version 0.8](https://github.com/clojure/core.logic/), so I intend to revisit this problem as that work progresses.

Let's have a crack at this problem anyway, shall we? I've previously posted a [functional implementation of n-queens]({{< ref "2012-03-25-enumerate-n-queens-solutions.md" >}}) in Clojure, and it's both nice to read and fast. What would this look like using core.logic?

Here's the core function (in Clojure) which determines if two queens are threatening each other:

```clojure
(defn safe? [[x1 y1] [x2 y2]]
  (and
   (not= x1 x2)
   (not= y1 y2)
   (not= (- x2 x1) (- y2 y1))
   (not= (- x1 y2) (- x2 y1))))
```

The main problem in core.logic is the subtraction operator, which cannot be applied to fresh variables. We need a goal that has all the subtraction algebra "mapped out" as associations, let's call it subo. If we had that, our safeo function could look like this;

```clojure
(defn safeo
  "Are 2 queens threatening each other?"
  [[x1 y1] [x2 y2]]
  (fresh [d1 d2 d3 d4]
         (subo x2 x1 d1)
         (subo y2 y1 d2)
         (subo x1 y2 d3)
         (subo x2 y1 d4)
         (!= x1 x2)
         (!= y1 y2)
         (!= d1 d2)
         (!= d3 d4)))
```

With subo (for a (range 2) subtraction) like this;

```clojure
(def subo
  (fn ([x y r]
        (conde
          [(== x 0) (== y 0) (== r 0)]
          [(== x 0) (== y 1) (== r -1)]
          [(== x 1) (== y 0) (== r 1)]
          [(== x 1) (== y 1) (== r 0)]))))
```

Fortunately this isn't too bad, since in the classic case we only need to subtract numbers in (range 8). We can write a macro that generates a subo for any range our heart desires.

Next up the associations for queen pieces. We can brute force this as well by writing safeo associations for each queen piece against each other and finally constraining each queen to a unique row. Typing it out for 4-queens would look something like this;

```clojure
(run* [r]
      (fresh [x1 x2 x3 x4]
             (safeo [x1 0] [x2 1])
             (safeo [x1 0] [x3 2])
             (safeo [x1 0] [x4 3])
             (safeo [x2 1] [x3 2])
             (safeo [x2 1] [x4 3])
             (safeo [x3 2] [x4 3])
             (== r [[x1 0] [x2 1] [x3 2] [x4 3]]))))
```

Please note that the y variables doesn't have to be fresh since they can only take one value (each queen is determined by an unique y variable).

Here's a complete listing to the whole thing, with an example of a 7-queens run;

```clojure
(ns nqueens-cl
  (:refer-clojure :exclude [==])
  (:use [clojure.core.logic]))

(defmacro def-subo
  "Generate subtraction algebra"
  [name n]
  (let [xn 'x, yn 'y, rn 'r
        gen-association (fn [x y]
                          `[(== ~xn ~x) (== ~yn ~y) (== ~rn ~(- x y))])
        gen-row (fn [x]
                  (->> (range n)
                       (map #(gen-association x %))
                       concat))
        gen-all (fn []
                  (->> (range n)
                       (map #(gen-row %))
                       (apply concat)))]
    `(defn ~name [~xn ~yn ~rn]
       (conde
         ~@(gen-all)))))

(declare subo)

(defn safeo
  "Are 2 queens threatening each other?"
  [[x1 y1] [x2 y2]]
  (fresh [d1 d2 d3 d4]
         (subo x2 x1 d1)
         (subo y2 y1 d2)
         (subo x1 y2 d3)
         (subo x2 y1 d4)
         (!= x1 x2)
         (!= y1 y2)
         (!= d1 d2)
         (!= d3 d4)))

(defmacro queens-run
  "Search for all N queens solutions"
  [n]
  (let [xnames (->> (range n) (map (fn [_] (gensym "x"))) (into []))
        gen-safes (fn []
                    (->> (range (dec n))
                         (map (fn [x] [x (range (inc x) n)]))
                         (map (fn [[s ts]]
                                (map (fn [t] `(safeo [~(nth xnames s) ~s]
                                                    [~(nth xnames t) ~t])) ts)))
                         (apply concat)))
          ]
    `(run* [r#]
           (fresh [~@(map #(nth xnames %) (range n))]
                  ~@(gen-safes)
                  (== r# [~@(map (fn [x] [(nth xnames x) x])
                                 (range n))])))))

(def-subo subo 7)
(time (count (queens-run 7)))
```

So how does it perform? Well, you guessed it: terribly. My previous [functional Clojure implementation]({{< ref "2012-03-25-enumerate-n-queens-solutions.md" >}}) finds all four solutions for 6-queens in ~7ms. The core.logic one above does it in ~6.5 seconds, three orders of magnitude slower. Ouch!

It's quite possible that this brute-force approach is a very inefficient way of solving n-queens using miniKanren. Maybe building/removing queens from solution lists would be a better approach? Also, cKanren in core.logic promises much faster and cleaner solutions. Either way, I'll keep you posted...
