---
layout: post
title: "Working with core.async: Blocking calls"
description: ""
category: clojure
tags: [clojure, core.async]
---
{% include JB/setup %}

You can't do anything even remotely blocking inside go-blocks. This is because all the core.async go blocks share a single thread pool, with a very limited number of threads (go blocks are supposed to be CPU bound). So if you have hundreds / thousands of go blocks running conurrently just having a few (a handful really) block -- *all* go blocks will stop! For a more in-depth explanation see [this previous post](http://martintrojer.github.io/clojure/2013/07/07/coreasync-and-blocking-io/).

<!--more-->

But what is blocking anyway? If an API you are using claims to be non-blocking, is it really? Unfortunately this isn't black and white, some functions are more non-blocking than others. They can also become 'more blocking' by accident. One good example of this is when using the async APIs of any client that writes to sockets. When the network stack of the system is very stressed, these calls start slowly drifting towards more blocking -- with very bad effects in the core.async go thread pool.

The only way to be sure is to measure / profile the functions you call inside your go blocks, under different circumstances; different loads of internal and external systems. Here's a neat little trick I used to clearly mark the functions I suspect with meta data, and then instrument and profile while the system is running.

<script src="https://gist.github.com/martintrojer/9436582.js?file=blocking.clj"> </script>

If you're interested in how some Go examples convert to core.async check out [this repo](https://github.com/martintrojer/go-tutorials-core-async).
