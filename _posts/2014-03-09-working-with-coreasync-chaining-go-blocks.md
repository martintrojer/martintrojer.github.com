---
layout: post
title: "Working with core.async: Chaining go blocks"
description: ""
category: clojure
tags: [clojure, core.async, go]
---
{% include JB/setup %}

One particularly annoying difference between the core.async and [Go](http://golang.org) is that you can't wrap function calls with the `go` macro. This is due to implementation details of core.async, which can only see the body 'inside' the macro and not the functions it may call. This is obviously not a problem if the called function doesn't interact with any channels, but if it does when you might be in trouble. I've touched on this subject in a [previous post](http://martintrojer.github.io/clojure/2013/07/17/non-tailrecursive-functions-in-coreasync/).

Anyway, let me explain what I mean.

Let's say we have a complicated `get-result` function that hits some external services (waits for the result) and then feeds the input to a big calculation function multiple times. All examples below simplified for brevity.

<script src="https://gist.github.com/martintrojer/9436582.js?file=get-result.clj"> </script>

This is all fine and well, but lets say the calculation function also needs to wait on some data, so it needs to become a go-routine as well. This means that we no longer have a return value but a channel with the result. Lets use some FP to get all the data out.

<script src="https://gist.github.com/martintrojer/9436582.js?file=get-result-go.clj"> </script>

Nope, you can't to that, `Assert failed: <! used not in (go ...) block`. It's also 'returns' nil, [explained in this post](http://martintrojer.github.io/clojure/2014/03/09/working-with-coreasync-exceptions-in-go-blocks/). Let's try another way;

<script src="https://gist.github.com/martintrojer/9436582.js?file=get-result-go2.clj"> </script>

Oh dear, 2 orders of magnitude and that warm fuzzy FP feeling is gone.

Since a go block returns a channel (with the result), you now have to deal with taking that value out of the channel. If you have long 'go-call-chains' of go blocks, you're going to spend lots of time in and out of channels. In this case we have lock congestion amongst all the `calculation-go2` blocks and that single channel.

The nil returning snippet above can be written in a similar fashion using some of core.async's helpers functions (thanks to Ben Ashford for pointing this out);

<script src="https://gist.github.com/martintrojer/9436582.js?file=get-result-go-better.clj"> </script>

Unfortunately this performs even worse than the written out go-loop, but it is much nicer.

## How is this any better in Go?

Here's a rough equivalent of the 2 scenarios in Go.

<script src="https://gist.github.com/martintrojer/9436582.js?file=getResult.go"> </script>

The key difference is that the caller put the function in a go block, and then any subsequent function are free to operate on any channel *without* itself being wrapped in `go`.

Also it performs better `getResult2` is an order of magnitude slower than `getResult`.

## The blessings and curses of macros

If we have to wrap every function in a go block and if chaining go blocks is so slow, can we just inline that function in our outer go block somehow? Yes we can, we can turn that function into a macro.

<script src="https://gist.github.com/martintrojer/9436582.js?file=get-result-go-macro.clj"> </script>

Problem solved right? Well, not really. Instead of composable functions (well kind of since they return channels) we now have a special kind of macros that must be called from within a go block. In the snippet above we can't use the lovely `(reduce ... (repeatedly calculation-go-macro))` form since we can't use macros that way. However, the macro itself can use `<!`, `>!` etc freely without the `go` wrapper and we solved the perf problem.

If you're interested in how some Go examples convert to core.async check out [this repo](https://github.com/martintrojer/go-tutorials-core-async).
