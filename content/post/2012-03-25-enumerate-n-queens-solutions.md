---
categories:
- clojure
date: "2012-03-25T00:00:00Z"
description: ""
tags:
- clojure
title: Enumerate N Queens solutions
---

<!--more-->


```clojure
(defn safe? [[x1 y1] [x2 y2]]
  (and
   (not= x1 x2)
   (not= y1 y2)
   (not= (- x2 x1) (- y2 y1))
   (not= (- x1 y2) (- x2 y1))))

(defn get-possible [n y qs]
  (for [x (range n)
        :let [p [x y]]
        :when (every? #(safe? p %) qs)]
    p))

(defn search [n]
  (let [res (atom [])]
    ((fn sloop [y qs]
       (if (= y n) (swap! res conj qs)
           (doseq [p (get-possible n y qs)]
             (sloop (inc y) (conj qs p)))))
     0 [])
    @res))

(for [i (range 1 10)]
   (count (search i)))
;; (1 0 0 2 10 4 40 92 352)
```
