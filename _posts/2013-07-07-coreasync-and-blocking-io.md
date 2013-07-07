---
layout: post
title: "core.async and Blocking IO"
description: ""
category: clojure
tags: [clojure]
---
{% include JB/setup %}

Some time ago I wrote about [Asynchronous workflows in Clojure](http://martintrojer.github.io/clojure/2011/12/22/asynchronous-workflows-in-clojure/). With the recent release and excitement of [core.async](https://github.com/clojure/core.async), I though it a good time to revisit that post.

While there are already some good example and comparison-with-[go](http://golang.org) posts out there, I'd like to focus on an area often misunderstood, namely async frameworks and blocking APIs (most commonly blocking IO). It's important to understand the implications of blocking IO and it's effects on 'async code', in this case core.async.

Here's a little diagram visualizing thread activity when using blocking IO calls;
<p align="center"><img src="/assets/images/asyncclj/oneperconnection.png"></p>

As you can see the threads mostly wait. What we are trying to achieve is to get more work out of each thread. In order to do this we want other work to be scheduled on the thread "while they wait". Thus getting more work done with fewer threads.
<p align="center"><img src="/assets/images/asyncclj/asyncthreads.png"></p>

When have a long-running API call, we want to "park the thread", schedule some unrelated work and resume later when the result is available.

This will break the 1 job = 1 thread knot, thus this thread parking will allow us to scale the number of jobs way beyond any thread limit on the platform (usually around 1000 on the JVM).

## core.async

core.async gives (blocking) channels and a new (unbounded) thread pool with using 'thread'. This (in effect) is just some sugar over using java threads (or clojure futures) and BlockingQueues from java.util.concurrent. The main feature is [go blocks](http://clojure.com/blog/2013/06/28/clojure-core-async-channels.html) in which threads can be parked and resumed on the (potentially) blocking calls dealing with core.async's channels.

The go blocks are run on a fix sized thread pool (2+number of cores) -- this is plenty for asynchronous workflows where we spend almost all our time waiting for callbacks and pushing / popping data on channels.

__However__ if you are using go blocks and blocking IO calls you're in trouble. You will in fact often get worse performance than using threads (in the normal case) since you will quickly hog all the threads in the go block thread pool and block out any other work!

## Http client example

To get a bit more concrete let's see what happens when we try to issue some HTTP GET request using core.async. Let's start with the naive solution, using blocking IO.

<script src="https://gist.github.com/martintrojer/5943467.js?file=blocking.clj"> </script>

Here's we trying to fetch 90 code snippets (in parallel) using go blocks (and blocking IO). This took a long time, and that's because the go block threads are "hogged" by the long running IO operations. The situation can be improved by switching the go blocks to normal threads.

<script src="https://gist.github.com/martintrojer/5943467.js?file=blocking-thread.clj"> </script>

This is quicker, but we're back to one thread per connection; exactly what we wanted to avoid. How can we approve the situation? We need a non-blocking API in order to use the go blocks properly. On the JVM we can use [Netty](http://netty.io), which gives us a callback based API. Here's some helper functions;

<script src="https://gist.github.com/martintrojer/5943467.js?file=netty.clj"> </script>

Now we can use go blocks and channels for the results.

<script src="https://gist.github.com/martintrojer/5943467.js?file=nonblocking.clj"> </script>

As you can see this performs like the threaded version above (which is all we can ask for). However, this solution scales to way more requests that the threaded version. And it's very convenient to use the size of the channel to control the number of outstanding requests.

Note, the use of Netty as an example isn't an ideal core.async use case, since Netty comes with it's own thread pools and only one channel is used (for the results). A better example would make heavier use of go blocks (for both of the long running operations; the connection and the request).

## Summary

Here's the main take-away; if your code is using blocking APIs, no async framework can avoid your code hogging threads.

core.async isn't some magic that make problems with blocking IO disappear. While the go blocks and it's thread parking is very useful, they have to be used with care. Since the go block thread pool is quite small, it's easy to block all the threads and thus stopping all 'go processing'.
