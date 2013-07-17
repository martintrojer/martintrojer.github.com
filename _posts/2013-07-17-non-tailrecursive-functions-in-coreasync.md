---
layout: post
title: "Non tail-recursive functions in core.async go blocks"
description: ""
category: clojure
tags: [clojure, core.async, go]
---
{% include JB/setup %}

I've been using various [Go](http://go-lang.org/) examples / tutorials to take a deeper look into [core.async](https://github.com/clojure/core.async). The [CSP](http://en.wikipedia.org/wiki/Communicating_sequential_processes) pattern is a very interesting and powerful, it's good move for Clojure to "throw in" with Go and push this style of programming.

core.sync works at s-expression level, where some other JVM solutions ([Kilim](http://www.malhar.net/sriram/kilim/), [Pulsar](https://github.com/puniverse/pulsar)) do the same on byte code level. The main benefit of doing these transforms on s-expression level is that they are applicable to ClojureScript, where CSP can be a very neat way out of callback hell. [David has written about this](http://swannodette.github.io/2013/07/12/communicating-sequential-processes/).

### The go macro

Now, one limitation of the go macro is that it can't "look into" other functions / closures. This difference stands out quite clearly when reading Go code where you can put "go" in-front of function calls.
<script src="https://gist.github.com/martintrojer/6019215.js?file=put-defn.clj"> </script>
This causes the `Assert failed: >! used not in (go ...) block` error. In this case it's easily fixed, simply move the `(go ...)` embrace into the `put-all!` function or inline the body of the function.

<script src="https://gist.github.com/martintrojer/6019215.js?file=put-inline.clj"> </script>
Please note that inlining an anonymous function does not work (fails with the error as above)

<script src="https://gist.github.com/martintrojer/6019215.js?file=put-fn.clj"> </script>
However, if the function you're inlining is tail recursive, you can use the approach above by using the `loop/recur` form (which the go macro can translate).

<script src="https://gist.github.com/martintrojer/6019215.js?file=put-loop.clj"> </script>
I.e. it's possible to simulate putting go around a function call by inlining it's body -- if it's tail recursive (or not recursive at all).

### Non-tail recursive functions

Now for a more [involved example](http://tour.golang.org/#68), we want to walk a binary search tree and put the values on a channel. When all results have been put on the channel we want to close it.

Here's a simple version of the walker (using the thread blocking `>!!` call).
<script src="https://gist.github.com/martintrojer/6019215.js?file=non-go-walker.clj"> </script>

Then we can use the `same` function to see if 2 trees are identical;
<script src="https://gist.github.com/martintrojer/6019215.js?file=thread-same.clj"> </script>

How do we convert this to use go blocks? We ideally want to have the entire `walker` function done by one go process, so that we can close the channel when the that function returns. Embracing the body of that function with `(go ..)` gives us the problem that the channel immediately closes before we get a chance to put anything on it.

<script src="https://gist.github.com/martintrojer/6019215.js?file=bad-go-walker.clj"> </script>

Also, we'll get a new go process for every node in the tree (every recursive call), so not all processing is done in "one place".

Ok, let's try to inline the body of the walker function so we can call `close!` when it's done.

<script src="https://gist.github.com/martintrojer/6019215.js?file=inlined-walker.clj"> </script>

Hm, this won't work because of the restriction of the go macro described above. If the walker function would have been __tail recursive__, we could have used the `loop/recur` form where the `((fn ..))` is and this approach would work, but not in this case.

Let's give up the idea of using one go process per tree and see if we can't use some kind of synchronisation to not call `close!` too early.

<script src="https://gist.github.com/martintrojer/6019215.js?file=better-go-walker.clj"> </script>

Here we put the `walker` and `close!` calls in another go block and then we wait for the call to walker to "finish" before moving on to close the channel. What it means for the "walker to finish" is that the go block for the top node of the tree terminates (since every node in the tree will have it's own go block).

This looks promising, but the results in the channel can be in any order (since there are no order guarantees in the scheduling of go processes) -- this also means that some of the values might be missing since the "top" go process can be scheduled before a child one.

We need a little bit more synchronisation to arrive at a working solution.

<script src="https://gist.github.com/martintrojer/6019215.js?file=go-walker.clj"> </script>

Now all the nodes will be processed (by different go processes) but in the correct order.

The complete solution can be found [here](https://github.com/martintrojer/go-tutorials-core-async/tree/master/src/go_tutorials_core_async/tut5.clj), note that the `(thread ...)` embrace in the `same` function has been removed.

### Postscript

[Some more Go tutorials converted to core.async](https://github.com/martintrojer/go-tutorials-core-async/tree/master/src/go_tutorials_core_async)

A final word of advice, when converting Go examples to core.async remember no to do `Thread/sleep` in your go blocks! In go, the sleep function is integrated in the go routine scheduling, this is not the case in core.async. See [here](http://martintrojer.github.io/clojure/2013/07/07/coreasync-and-blocking-io/) for a deeper explanation why.
