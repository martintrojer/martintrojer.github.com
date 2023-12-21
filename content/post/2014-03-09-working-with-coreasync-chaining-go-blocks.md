---
categories:
- clojure
date: "2014-03-09T00:00:00Z"
description: ""
tags:
- clojure
- core.async
- go
title: 'Working with core.async: Chaining go blocks'
---

One particularly annoying difference between the core.async and [Go](http://golang.org) is that you can't wrap function calls with the `go` macro. This is due to implementation details of core.async, which can only see the body 'inside' the macro and not the functions it may call. This is obviously not a problem if the called function doesn't interact with any channels, but if it does when you might be in trouble. I've touched on this subject in a [previous post](http://martintrojer.github.io/clojure/2013/07/17/non-tailrecursive-functions-in-coreasync/).

<!--more-->

Anyway, let me explain what I mean.

Let's say we have a complicated `get-result` function that hits some external services (waits for the result) and then feeds the input to a big calculation function multiple times. All examples below simplified for brevity.

```clojure
(defn calculation []
  ;; Big complicated calculation
  (rand-int 1000))

(defn get-result []
  (async/go
    ;; wait for some stuff
    (reduce + (repeatedly 1000 calculation))))

(time (async/<!! (get-result)))
;; "Elapsed time: 1.034 msecs"
```

This is all fine and well, but lets say the calculation function also needs to wait on some data, so it needs to become a go-routine as well. This means that we no longer have a return value but a channel with the result. Lets use some FP to get all the data out.

```clojure
(defn calculation-go []
  (async/go
    ;; wait for some stuff
    (rand-int 1000)))

(defn get-result-go []
  (async/go
    (->>
     (repeatedly 10 calculation-go)
     (map async/<!)
     (reduce +))))

(async/<!! (get-result-go))
;; => nil
```

Nope, you can't to that, `Assert failed: <! used not in (go ...) block`. It's also 'returns' nil, [explained in this post](http://martintrojer.github.io/clojure/2014/03/09/working-with-coreasync-exceptions-in-go-blocks/). Let's try another way;

```clojure
(defn calculation-go2 [ch]
  (async/go
    ;; wait for some stuff
    (>! ch (rand-int 1000))))

(defn get-result-go2 []
  (let [ch (async/chan)
        count 1000]
    (dotimes [_ count]
        (calculation-go2 ch))
    (async/go-loop [res 0 cnt count]
      (if (or (nil? res) (zero? cnt))
        res
        (recur (+ res (<! ch)) (dec cnt))))))

(time (async/<!! (get-result-go2)))
;; "Elapsed time: 102.503 msecs"
```

Oh dear, 2 orders of magnitude and that warm fuzzy FP feeling is gone.

Since a go block returns a channel (with the result), you now have to deal with taking that value out of the channel. If you have long 'go-call-chains' of go blocks, you're going to spend lots of time in and out of channels. In this case we have lock congestion amongst all the `calculation-go2` blocks and that single channel.

The nil returning snippet above can be written in a similar fashion using some of core.async's helpers functions (thanks to Ben Ashford for pointing this out);

```clojure
(defn get-result-go-better []
  (->>
   (repeatedly 1000 calculation-go)
   (async/merge)
   (async/reduce + 0)))

(time (async/<!! (get-result-go-better)))
;; "Elapsed time: 178.654 msecs"
```

Unfortunately this performs even worse than the written out go-loop, but it is much nicer.

## How is this any better in Go?

Here's a rough equivalent of the 2 scenarios in Go.

```go
func calculation() int {
	return rand.Intn(1000)
}

func getResult(c chan int) {
	sum := 0
	for i := 0; i < 1000; i++ {
		sum += calculation()
	}
	c <- sum
}
// Elapsed time: 196.309us

func calculation2(c chan int) {
	// wait for some stuff
	c <- rand.Intn(1000)
}

func getResult2(c chan int) {
	tmpc := make(chan int)
	sum := 0
	for i := 0; i < 1000; i++ {
		go calculation2(tmpc)
	}
	for i := 0; i < 1000; i++ {
		sum += <-tmpc
	}
	c <- sum
}
// Elapsed time: 4.421806ms
```

The key difference is that the caller put the function in a go block, and then any subsequent function are free to operate on any channel *without* itself being wrapped in `go`.

Also it performs better `getResult2` is an order of magnitude slower than `getResult`.

## The blessings and curses of macros

If we have to wrap every function in a go block and if chaining go blocks is so slow, can we just inline that function in our outer go block somehow? Yes we can, we can turn that function into a macro.

```clojure
(defmacro calculation-go-macro []
  `(do
    ;; wait for some stuff using async/channels
     (rand-int 1000)))

(defn get-result-go-macro []
  (async/go
    ;; wait for some stuff
    (reduce +
            (loop [res [] cnt 1000]
              (if (zero? cnt)
                res
                (recur (conj res (calculation-go-macro)) (dec cnt)))))))

(time (async/<!! (get-result-go-macro)))
;; "Elapsed time: 2.452 msecs"
```

Problem solved right? Well, not really. Instead of composable functions (well kind of since they return channels) we now have a special kind of macros that must be called from within a go block. In the snippet above we can't use the lovely `(reduce ... (repeatedly calculation-go-macro))` form since we can't use macros that way. However, the macro itself can use `<!`, `>!` etc freely without the `go` wrapper and we solved the perf problem.

If you're interested in how some Go examples convert to core.async check out [this repo](https://github.com/martintrojer/go-tutorials-core-async).
