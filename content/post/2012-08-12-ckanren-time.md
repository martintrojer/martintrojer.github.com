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

Mr. David Nolen recently published core.logic 0.8.alpha2, with added cKanren (c for constraints) support. To celebrate this glorious event, I'm writing up some core.logic/cKanren stuff I've been looking at recently.

### Enter the Queens
If you've followed this blog, you've perhaps seen my previous posts on solving N-Queens in core.logic ([part 1]({{< ref "2012-07-16-replicating-datomicdatalog-queries-with-corelogic.md" >}}) and [part 2]({{< ref "2012-07-17-replicating-datomicdatalog-queries-with-corelogic-take-2.md" >}})). How will this look and perform using the new shiny cKanren extensions in core.logic 0.8? Obviously, there are many (new) ways to solve this problem. Here's a core.logic-styled version of the solution described in the [cKanren paper](http://www.schemeworkshop.org/2011/papers/Alvis2011.pdf) (please read paragraph 4.2 for an in-depth explanation):

```clojure
(defn diago [qi qj d rng]
  (fresh [qid qjd]
         (infd qid qjd rng)
         (+fd qi d qid)
         (!=fd qid qj)
         (+fd qj d qjd)
         (!=fd qjd qi)))

(defn diagonalso [n r]
  ((fn dloop [r i s j]
     (cond
       (or (empty? r) (empty? (rest r))) s#
       (empty? s) (dloop (rest r) (inc i) (rest (rest r)) (+ i 2))
       :else (let [qi (first r), qj (first s)]
               (all
                (diago qi qj (- j i) (interval 0 (* 2 n)))
                (dloop r i (rest s) (inc j))))))
   r 0 (rest r) 1))

(defn n-queenso [q n]
  ((fn qloop [i l]
     (if (zero? i)
       (all
        (distinctfd l)
        (diagonalso n l)
        (== q l))
       (fresh [x]
              (infd x (interval 1 n))
              (qloop (dec i) (cons x l)))))
   n '()))

(count
  (run* [q]
        (n-queenso q 8)))
```


distinctfd (with infd) is a really nice addition to core.logic, they really help me personally write logic programs. How does this code perform? It's very similar in speed compared to the (non-fd) core.logic solution described in my [previous posting]({{< ref "2012-07-17-replicating-datomicdatalog-queries-with-corelogic-take-2.md" >}}), not bad, all extra cKanren expressive power without any performance drop!

### Sudoku time
How would you use core.logic to solve sudoku? Let's start by looking at a simple all-Clojure functional solution;
```clojure
(ns sud
  (:require [clojure.set :as s]
            [clojure.pprint :as pp]))

(defn possible
  "Possible values for a given position"
  [[x y] board]
  (let [horizontal (set (board x))
        vertical (reduce (fn [a c] (conj a (c y))) #{} board)
        x' (* (quot x 3) 3)
        y' (* (quot y 3) 3)
        local (reduce (fn [a r]
                        (->> (range y' (+ y' 3))
                             (map #(get-in board [r %]))
                             (into a)))
                      #{} (range x' (+ x' 3)))]
    (s/difference (set (range 1 10)) vertical horizontal local)))

(defn open
  "Get all open positions"
  [board]
  (reduce (fn [a r]
            (->> (second r)
                 (map-indexed vector)
                 (filter #(= 0 (second %)))
                 (map #(vector (first r) (first %)))
                 (into a)))
          [] (map-indexed vector board)))

(defn most-constrained
  "Get open positions and possibles sorted by the least possibles"
  [board]
  (->> board
       open
       (map #(vector % (possible % board)))
       (sort-by (comp count second))))

(defn solved? [board]
  (->> board
       (apply concat)
       (some #{0})
       (not= 0)))

(defn search [n board]
  (let [res (atom [])]
    ((fn sloop [board]
       (when (< (count @res) n)
         (if (solved? board)
           (swap! res conj board)
           (letfn [(try-all [[[o ps]] & t]
                     (when o
                       (doseq [p ps]
                         (sloop (assoc-in board o p))
                         (try-all t))))]
             (try-all (most-constrained board))))))
     board)
    @res))

(def empty-board (vec (repeat 8 (vec (repeat 8 0)))))
(time (pp/pprint (search 5 empty-board)))
```

A few things are worth mentioning. First, this code finds all (potential) solutions of a given board layout. This is a bit strange since a true sudoku board should only have one solution! This does make it a bit more similar to logic programs (which typically looks for many solutions), and gives you some nice perks; you can use this code to check if a given puzzle is indeed a true puzzle. Secondly, in order to terminate faster, this snippet uses a quite common sudoku heuristic called "most constrained". At each level of the backtracking search it will consider the open squares in order, sorted after the least possible numbers (i.e. most constrained first). This helps to "fail fast" and minimise the dead alleys we recursively search.

How would we do this in cKanren? As we'd expect the code comes very close the the definition of the rules; We have 9x9 squares, each square can contain a number from 1-9, the numbers in each row, column and 3x3 sub-square must be unique.

In this example I will use a 4x4 sudoku for simplicity.

```clojure
(declare all-distincto)

(run 1 [q]
     (fresh [a1 a2 a3 a4                 ;; our 4x4 squares...
             b1 b2 b3 b4
             c1 c2 c3 c4
             d1 d2 d3 d4]

            (== q [[a1 a2 a3 a4]         ;; ... laid out like this on our board
                   [b1 b2 b3 b4]
                   [c1 c2 c3 c4]
                   [d1 d2 d3 d4]])

            (infd a1 a2 a3 a4            ;; all squares bound to 1-4 integer domain
                  b1 b2 b3 b4            ;; infd is a cKanren function
                  c1 c2 c3 c4
                  d1 d2 d3 d4
                  (interval 1 4))

            ;; define the rows, columns and sub-squares
            (let [row1 [a1 a2 a3 a4] row2 [b1 b2 b3 b4]
                  row3 [c1 c2 c3 c4] row4 [d1 d2 d3 d4]
                  col1 [a1 b1 c1 d1] col2 [a2 b2 c2 d2]
                  col3 [a3 b3 c3 d3] col4 [a4 b4 c4 d4]
                  sq1 [a1 a2 b1 b2]  sq2 [a3 a4 b3 b4]
                  sq3 [c1 c2 d1 d2]  sq4 [c3 c4 d3 d4]]

              ;; assert that the numbers in all rows, cols, squares are distinct
              (all-distincto [row1 row2 row3 row4
                              col1 col2 col3 col4
                              sq1 sq2 sq3 sq4]))))

(defne all-distincto [l]
  ([()])
  ([[h . t]]
     (distinctfd h)               ;; distrinctfd is a cKanren function
     (all-distincto t)))
```

That's it - exactly how the rules for sudoku were written. Logic programming really is magical!

Writing it this way is good for understanding the solution but not very practical for a real 9x9 board. Fortunately, we can write some more helpers to make this compact. Here's an example from Mr. Nolen himself:

```clojure
(ns sudoku
  (:refer-clojure :exclude [==])
  (:use clojure.core.logic))

(defn get-square [rows x y]
  (for [x (range x (+ x 3))
        y (range y (+ y 3))]
    (get-in rows [x y])))

(defn init [vars hints]
  (if (seq vars)
    (let [hint (first hints)]
      (all
        (if-not (zero? hint)
          (== (first vars) hint)
          succeed)
        (init (next vars) (next hints))))
    succeed))

(defn sudokufd [hints]
  (let [vars (repeatedly 81 lvar)
        rows (->> vars (partition 9) (map vec) (into []))
        cols (apply map vector rows)
        sqs  (for [x (range 0 9 3)
                   y (range 0 9 3)]
               (get-square rows x y))]
    (run 1 [q]
      (== q vars)
      (everyg #(infd % (domain 1 2 3 4 5 6 7 8 9)) vars)
      (init vars hints)
      (everyg distinctfd rows)
      (everyg distinctfd cols)
      (everyg distinctfd sqs))))
```

This solution uses a "pseudo" goal call everyg with is similar to all-distincto in the previous example.

So how fast is this then? How does it stack up against the hand-rolled implementation above? Well, on an empty board (all squares open) the hand-rolled code finds 5 solutions in 400ms, while this code above get's into a (>5min) loop. For for more realistic "hard" boards the core.logic solution is on average 20x faster than the hand rolled code (much less temporary objects I recon). Finally, on really evil boards like this one, discovered by Peter Norvig;

```clojure
(def evil-norvig
    [[0 0 0  0 0 6  0 0 0]
     [0 5 9  0 0 0  0 0 8]
     [2 0 0  0 0 8  0 0 0]

     [0 4 5  0 0 0  0 0 0]
     [0 0 3  0 0 0  0 0 0]
     [0 0 6  0 0 3  0 5 4]

     [0 0 0  3 2 5  0 0 6]
     [0 0 0  0 0 0  0 0 0]
     [0 0 0  0 0 0  0 0 0]])
 ```

the core.logic code terminates in ~6 seconds where as the hand rolled code loops forever (well, I gave up after 20 minutes).

### Conclusion
In most cases where "searching" is involved, I warmly recommend using core.logic. The expressive power makes for easy-to-read code, and the performance cost over hand-rolled code is either not very significant or reversed (i.e., core.logic is faster). The new constraints primitives (cKanren) in core.logic-0.8 are a great addition to an already impressive library.

Some other stuff;

* The excellent [cKanren paper](http://www.schemeworkshop.org/2011/papers/Alvis2011.pdf) is getting a bit obsolete. It's still a very good read, but for the latest innovation check out it's [github page](https://github.com/calvis/cKanren), and ofcourse core.logic.
* If you can't get enough of logic programming, the next step is to dip into the ocean of Prolog, there are plenty of awesome (and practical) books written over many years. Here's a [good list of books](http://dosync.posterous.com/a-logic-programming-reading-list) to get you started
