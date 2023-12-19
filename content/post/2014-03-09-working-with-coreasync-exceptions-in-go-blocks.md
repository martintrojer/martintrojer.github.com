---
categories:
- clojure
date: "2014-03-09T00:00:00Z"
description: ""
tags:
- clojure
- core.async
title: 'Working with core.async: Exceptions in go blocks'
---

Dealing with exceptions in go blocks/threads is different from normal clojure core. This gotcha is very common when moving your code into core.async go blocks -- all your exceptions are gone! Since the body of a go block is run on a thread pool, it's not much we can do with an exception, thus core.async will just eat them and close the channel. That's what happened in the second snippet [in this post](http://martintrojer.github.io/clojure/2014/03/09/working-with-coreasync-chaining-go-blocks/). The `nil` result is because the channel we read from is closed.

<!--more-->

I find myself wanting to know the cause of problem at the consumer side of a channel. That means the go block needs to catch the exception, put it (the exception) on the channel before it dies. [David Nolen has written about this pattern](http://swannodette.github.io/2013/08/31/asynchronous-error-handling/), and I've been using the proposed `<?` quite happily.

```clojure
(defn throw-err [e]
  (when (instance? Throwable e) (throw e))
  e)

(defmacro <? [ch]
  `(throw-err (async/<! ~ch)))

(defn get-data [s]
  (async/go (try
              (client/get (str "http://some.query?q=s") {:throw-exceptions true})
              ;; catch and put exception on the channel
              (catch Exception e
                e))))

(async/go (try
            (let [data      (<? (get-data "clojure"))
                  more-data (<? (get-data "core.async")]
              ;; process all data
              )
            ;; Handle exceptions for all '<? calls'
            (catch Exception e
              (log/error "error getting data"))))
```

If you're interested in how some Go examples convert to core.async check out [this repo](https://github.com/martintrojer/go-tutorials-core-async).
