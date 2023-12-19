---
categories:
- clojure
date: "2013-07-07T00:00:00Z"
description: ""
tags:
- clojure
- core.async
- go
title: core.async and Blocking IO
---

Some time ago I wrote about [Asynchronous workflows in Clojure](http://martintrojer.github.io/clojure/2011/12/22/asynchronous-workflows-in-clojure/). With the recent release and excitement of [core.async](https://github.com/clojure/core.async), I though it a good time to revisit that post.

While there are already some good example and comparison-with-[go](http://golang.org) posts out there, I'd like to focus on an area often misunderstood, namely async frameworks and blocking APIs (most commonly blocking IO). It's important to understand the implications of blocking IO and it's effects on 'async code', in this case core.async.

Here's a little diagram visualizing thread activity when using blocking IO calls;

{{< figure src="/assets/images/asyncclj/oneperconnection.png" >}}

As you can see the threads mostly wait. What we are trying to achieve is to get more work out of each thread. In order to do this we want other work to be scheduled on the thread "while they wait". Thus getting more work done with fewer threads.

{{< figure src="/assets/images/asyncclj/asyncthreads.png" >}}

When we have a long-running API call, we want to "park the thread", schedule some unrelated work and resume later when the result is available.

This will break the 1 job = 1 thread knot, thus this thread parking will allow us to scale the number of jobs way beyond any thread limit on the platform (usually around 1000 on the JVM).

## core.async

core.async gives (blocking) channels and a new (unbounded) thread pool when using 'thread'. This (in effect) is just some sugar over using java threads (or clojure futures) and BlockingQueues from java.util.concurrent. The main feature is [go blocks](http://clojure.com/blog/2013/06/28/clojure-core-async-channels.html) in which threads can be parked and resumed on the (potentially) blocking calls dealing with core.async's channels.

The go blocks are run on a fix sized thread pool (2+number of cores) -- this is plenty for asynchronous workflows where we spend almost all our time waiting for callbacks and pushing / popping data on channels.

__However__ if you are using go blocks and blocking IO calls you're in trouble. You will in fact often get worse performance than using threads (in the normal case) since you will quickly hog all the threads in the go block thread pool and block out any other work!

## Http client example

To get a bit more concrete let's see what happens when we try to issue some HTTP GET request using core.async. Let's start with the naive solution, using blocking IO via [clj-http](https://github.com/dakrone/clj-http).

{{< gist martintrojer 5943467 blocking.clj >}}

Here we're trying to fetch 90 code snippets (in parallel) using go blocks (and blocking IO). This took a long time, and that's because the go block threads are "hogged" by the long running IO operations. The situation can be improved by switching the go blocks to normal threads.

{{< gist martintrojer 5943467 blocking-thread.clj >}}

This is quicker, but we're back to one thread per connection; exactly what we wanted to avoid. How can we approve the situation? We need a non-blocking API in order to use the go blocks properly.

### http-kit

Clojure has a very nice library for asynchronous http clients (and servers) called [http-kit](http://http-kit.org/). With http-kit we can use callbacks to signal when the request is finished, this plays very well with core.async channels.

{{< gist martintrojer 5943467 nonblocking-kit.clj >}}

As you can see this performs like the threaded version above (which is all we can ask for in this case). However, this solution scales to way more requests than the threaded version.

The pattern of putting the result of callback function onto a channel, and thus decoupling the useful logic from the plumbing, is preferable over putting the "handling logic" inside said callback.

### Netty

Another option is [Netty](http://netty.io), which also gives us a callback based API. Here's some helper functions;

{{< gist martintrojer 5943467 netty.clj >}}

Now we can use go blocks and channels for the results.

{{< gist martintrojer 5943467 nonblocking.clj >}}

Note that Netty isn't an ideal core.async example, since Netty comes with it's own thread pools and only one channel is used (for the results). A better example would make heavier use of go blocks (for both of the long running operations of a http request; the connection and the request).

## Summary

Here's the main take-away; if your code is using blocking APIs, no async framework can avoid your code hogging threads.

core.async isn't some magic that make problems with blocking IO disappear. While the go blocks and it's thread parking is very useful, they have to be used with care. Since the go block thread pool is quite small, it's easy to block all the threads and thus stopping all 'go processing'.

Never `Thread/sleep` in a go block, use `(<! (timeout *msec*))`!
