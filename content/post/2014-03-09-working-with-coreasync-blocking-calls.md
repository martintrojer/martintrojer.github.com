---
categories:
- clojure
date: "2014-03-09T00:00:00Z"
description: ""
tags:
- clojure
- core.async
title: 'Working with core.async: Blocking calls'
---
You can't do anything even remotely blocking inside go-blocks. This is because all the core.async go blocks share a single thread pool, with a very limited number of threads (go blocks are supposed to be CPU bound). So if you have hundreds / thousands of go blocks running conurrently just having a few (a handful really) block -- *all* go blocks will stop! For a more in-depth explanation see [this previous post]({{< ref "2013-07-07-coreasync-and-blocking-io.md" >}}).

<!--more-->

But what is blocking anyway? If an API you are using claims to be non-blocking, is it really? Unfortunately this isn't black and white, some functions are more non-blocking than others. They can also become 'more blocking' by accident. One good example of this is when using the async APIs of any client that writes to sockets. When the network stack of the system is very stressed, these calls start slowly drifting towards more blocking -- with very bad effects in the core.async go thread pool.

The only way to be sure is to measure / profile the functions you call inside your go blocks, under different circumstances; different loads of internal and external systems. Here's a neat little trick I used to clearly mark the functions I suspect with meta data, and then instrument and profile while the system is running.

```clojure

;; ------------------------

(defn- log-time [{:keys [ns name line]} f & args]
  (let [start   (System/nanoTime)
        res     (apply f args)
        elapsed (quot (- (System/nanoTime) start) 1000)]
    (log/debug (format "%s/%s:%s %dus" ns name line elapsed))
    res))

(defn enable-timing [var]
  (log/debug "enabling timings" var)
  (robert.hooke/add-hook var (partial log-time (meta var))))

(defn enable-timing-on-blocking-functions []
  (->> (all-ns)
       (mapcat ns-interns)
       (map second)
       (filter #(:blocking (meta %)))
       ;; No dups
       (remove #(:robert.hooke/hook (meta (deref %))))
       (map enable-timing)
       doall))

;; ------------------------

(defn- ^:blocking request-data [s]
  (client/get (str "http://some.query?q=s") {:throw-exceptions true}))

(defn get-data [s]
  (async/go (try
              (request-data s)
              ;; catch and put exception on the channel
              (catch Exception e
                w))))
```

If you're interested in how some Go examples convert to core.async check out [this repo](https://github.com/martintrojer/go-tutorials-core-async).
