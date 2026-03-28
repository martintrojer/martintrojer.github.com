---
categories:
- clojure
date: "2012-02-21T00:00:00Z"
description: ""
tags:
- clojure
title: ASCII Mandelbrot Set
---

<!--more-->

```clojure
(defn c+ [[re1 im1] [re2 im2]] [(+ re1 re2) (+ im1 im2)])
(defn c* [[re1 im1] [re2 im2]]
  [(- (* re1 re2) (* im1 im2)) (+ (* re1 im2) (* im1 re2))])
(defn c2 [c] (c* c c))
(defn |c| [[re im]] (Math/sqrt (+ (* re re) (* im im))))

(defn get-mandel-set [im-range re-range max-iter]
  (for [im im-range
        re re-range
        :let [c [re im]]]
    (loop [z [0 0], cnt -1]
      (let [z (c+ (c2 z) c)
            cnt (inc cnt)]
        (if-not (and (< (|c| z) 4) (< cnt max-iter))
          cnt
          (recur z cnt))))))

(defn print-mandel [sz data]
  (let [cs ["." "," "\"" "-" ":" "/" "(" "*" "|" "$" "#" "@" "%" "~"]]
    (loop [ds data]
      (when-not (empty? ds)
        (let [cs (map #(nth cs (dec %)) (take sz ds))]
          (doseq [c cs] (print c))
          (println "")
          (recur (drop sz ds)))))))

(->>
 (get-mandel-set (range -1.2 1.2 0.05) (range -2 1 0.04) 14)
 (print-mandel 75))
```

Credit to [Frink](http://futureboy.us/frinkdocs/) for inspiration.
