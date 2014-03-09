---
layout: post
title: "Working with core.async: Exceptions in go blocks"
description: ""
category: clojure
tags: [clojure, core.async]
---
{% include JB/setup %}

Dealing with exceptions in go blocks/threads is different from normal clojure core. This gotcha is very common when moving your 'normal' code into core.async go blocks -- all your exceptions are gone! Since the body of a go block is run on a thread pool, it's not much we can do with an exception, thus core.async will just eat them and close the channel. That's what happened in the snippet above that returned `nil`. The `nil` result is because the channel we read from is closed.

I find myself wanting to know the cause of problem at the consumer side of a channel. That means the go block needs to catch the exception, put it (the exception) on the channel before it dies. [David Nolen has written about this pattern](http://swannodette.github.io/2013/08/31/asynchronous-error-handling/), and I've been using the proposed `<?` quite happily.

<script src="https://gist.github.com/martintrojer/9436582.js?file=throw-err.clj"> </script>

If you're interested is how some Go examples convert to core.async check out [this repo](https://github.com/martintrojer/go-tutorials-core-async).
