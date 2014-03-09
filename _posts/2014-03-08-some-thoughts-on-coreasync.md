---
layout: post
title: "Some thoughts on core.async"
description: ""
category: clojure
tags: [clojure, core.async, go]
---
{% include JB/setup %}

## Summary

I'm a big fan of core.async, it really helps to cleanup the code and does perform well. If you are really stressing your system the problem with blocking calls needs to be carefully considered. Perhaps it's a bit unfair to compare it too strictly against Go, which have a compiler and runtime build from the ground up around [CSP](http://en.wikipedia.org/wiki/Communicating_sequential_processes). For instance, blocking calls just isn't a thing in Go. It's channels 'all the way down'.

Speaking of Go, one other weapon it packs in deadlock / [data-race](http://golang.org/doc/articles/race_detector.html) detection. This is very handy indeed and something that should be worked on in core.async.

While is core.async's go macro is impressive and very powerful, the pragmatist in me would prefer to have core.async incorporated into the clojure compiler to overcome some of the issues described here. Maybe the [clojure](https://github.com/clojure/tools.analyzer)-[in](https://github.com/clojure/tools.analyzer.jvm)-[clojure](https://github.com/clojure/tools.emitter.jvm) project can make this happen?
