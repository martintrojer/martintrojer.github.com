---
layout: post
title: "Flexible multi consumer/producer pipelines"
description: ""
category: clojure
tags: [clojure]
---
{% include JB/setup %}

TL;DR [Pipejine](https://github.com/martintrojer/pipejine) - a lightweight Clojure library for multi-threaded producer/consumer pipelines supporting arbitrary DAG topologies.

Recently a [colleague](https://twitter.com/jonpither) and I faced a problem where we needed to optimize the total running time of a complicated calculation. This calculation involved several asynchronous steps getting data from other systems (like elasticsearch and other home-grown services) and a bit of number crunching and tallying up the results at the end. Here is and simplified example of the system.

<p align="center"><img src="/assets/images/pipejine/pipe.png"></p>

Some work items can come "out of order" and some had to hit different systems before "coming back" and be part of the remaining calculation.

In order to improve performance, the communication with some of these services needed to batched. The total amount of data to flow through the steps far exceeded the heap size of a single VM, so we had to be careful to partition up the data and only keep parts of it in memory at any time. Different steps required different amount of resources (memory / threads etc) - so we needed to balance the entire system.

The different steps had different failure characteristics, and it's important that the entire calculation didn't lock up when a part behaved badly, and try to come out of a bad situation as good as possible. Since the whole calculation is very multi threaded, we had to have a way of determining when the whole calculation was done and we could pass on the final result. This "done signal" also have to be consistent in error situations.

Because of the complexity of the many steps, it was important to track the status of the whole system, to pick out potential problems and bottlenecks. Finally, we wanted many different of these calculations to be run in parallel (independent of each-other) and be able to cancel single ones (within reasonable time frames).

Phew, that's quite a lot. How can you describe something like this (in Clojure) without pulling your hair out and go totally mad? Well, this looks like a pipeline problem does it not? There are a few Hadoop-y / Storm-y solutions out there, but all this had to run inside a single VM, and the problem wasn't really "big data" enough to justify hadoop -- we didn't want to use a thermo nuclear bomb to open a match-box. We also wanted our pipeline to handle our quirky little requirements (like batching) transparently from the producer/consumer functions.

I've put what we come up with on [github](https://github.com/martintrojer/pipejine/) and I'm happy to say that it managed to solve the problems described above very neatly and still be very small and nimble. It's basically some helper functions over Java's powerful concurrent queues. And as it turns out, by using these primitives we manged to write a simple and flexible solution.

So if you find yourself with a similar "not big enough for hadoop" problem, please feel free give pipejine a spin!
