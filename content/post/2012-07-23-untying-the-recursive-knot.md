---
categories:
- clojure
date: "2012-07-23T00:00:00Z"
description: ""
tags:
- clojure
title: Untying the Recursive Knot
---

Here I present a couple of examples of the functional design pattern "untying the recursive knot." I've found this useful on several occasions, for instance, when breaking apart mutually recursive functions. This material was inspired by Jon Harrop's excellent [Visual F# for Technical Computing](http://www.ffconsultancy.com/products/fsharp_for_technical_computing/).

First, let's look at a simple factorial implementation using direct recursion:
```clojure
(defn fact [n]
  (if (= n 0) 1
      (* n (fact (dec n)))))
```

We can break the direct recursive dependency by replacing the recursive calls with calls to a function argument:
```clojure
(defn fact' [fact n]
  (if (= n 0) 1
      (* n (fact (dec n)))))
```

We have now broken the recursive knot! The functionality can be recovered by tying the recursive knot using the following Y combinator:

```clojure
(defn y [f & xs]
  (apply f (partial y f) xs))
```

For example:
```clojure
(y fact' 10)
;; 3628800
```

This has given us extra power, we may for instance inject new functionality into every invocation without touching the original definition:

```clojure
(y (fn [f n]
     (println "fact" n)
     (fact' f n))
   5)
;; fact 5
;; fact 4
;; fact 3
;; fact 2
;; fact 1
;; fact 0
;; 120
```

Now for a more practical example when we have mutually recursive functions:

```clojure
(declare odd)

(defn even [es os [e & xs]]
  (if e
    (odd (conj es e) os xs)
    [es os]))

(defn odd [es os [o & xs]]
  (if o
    (even es (conj os o) xs)
    [es os]))

(even [] [] (range 7))
;; [[0 2 4 6] [1 3 5]]
```

We can break these functions apart using the same strategy as with fact' above:

```clojure
(defn even' [odd es os [e & t]]
  (if e
    (odd (conj es e) os t)
    [es os]))

(defn odd' [even es os [o & t]]
  (if o
    (even es (conj os o) t)
    [es os]))
```

Please note that the (declare ...) form is no longer required. The functions are now entirely independent and could live in different namespaces.

Using the same y combinator above, we can get back to the original functionality:

```clojure
(y (fn [f & args] (apply even' (partial odd' f) args)) [] [] (range 7))
;; [[0 2 4 6] [1 3 5]]
```

A handy pattern to add to your functional toolbox.
