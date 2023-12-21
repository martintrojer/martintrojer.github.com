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

```clojure
(defn blocking-get [url]
  (clj-http.client/get url))

(time
   (def data
     (let [c (chan)
           res (atom [])]
       ;; fetch em all
       (doseq [i (range 10 100)]
         (go (>! c (blocking-get (format "http://fssnip.net/%d" i)))))
       ;; gather results
       (doseq [_ (range 10 100)]
         (swap! res conj (<!! c)))
       @res
       )))

;; "Elapsed time: 11123.577 msecs"
```

Here we're trying to fetch 90 code snippets (in parallel) using go blocks (and blocking IO). This took a long time, and that's because the go block threads are "hogged" by the long running IO operations. The situation can be improved by switching the go blocks to normal threads.

```clojure

(time
   (def data-thread
     (let [c (chan)
           res (atom [])]
       ;; fetch em all
       (doseq [i (range 10 100)]
         (thread (>!! c (blocking-get (format "http://fssnip.net/%d" i)))))
       ;; gather results
       (doseq [_ (range 10 100)]
         (swap! res conj (<!! c)))
       @res
       )))

;; "Elapsed time: 6523.782 msecs"
```

This is quicker, but we're back to one thread per connection; exactly what we wanted to avoid. How can we approve the situation? We need a non-blocking API in order to use the go blocks properly.

### http-kit

Clojure has a very nice library for asynchronous http clients (and servers) called [http-kit](http://http-kit.org/). With http-kit we can use callbacks to signal when the request is finished, this plays very well with core.async channels.

```clojure

(defn async-get [url result]
  (org.httpkit.client/get url #(go (>! result %))))

(time
 (def hk-data
   (let [c (chan)
         res (atom [])]
     ;; fetch em all
     (doseq [i (range 10 100)]
       (async-get (format "http://fssnip.net/%d" i) c))
     ;; gather results
     (doseq [_ (range 10 100)]
       (swap! res conj (<!! c)))
     @res
     )))

;; "Elapsed time: 6731.781 msecs"
```

As you can see this performs like the threaded version above (which is all we can ask for in this case). However, this solution scales to way more requests than the threaded version.

The pattern of putting the result of callback function onto a channel, and thus decoupling the useful logic from the plumbing, is preferable over putting the "handling logic" inside said callback.

### Netty

Another option is [Netty](http://netty.io), which also gives us a callback based API. Here's some helper functions;

```clojure
;; handle results from the GET
(defn gen-response-handler [f]
  (reify ChannelUpstreamHandler
    (handleUpstream [_ ctx evt]
      (do
        (swap! ctr inc)
        (when (instance? MessageEvent evt)
          (f (.getMessage evt)))))))

;; handle results from the connection (and issue the GET request)
(defn connection-ok [uri f]
  (let [host (.getHost uri)]
    (reify ChannelFutureListener
      (operationComplete [_ fut]
        (if (.isSuccess fut)
          (let [ch (.getChannel fut)
                pipe (.getPipeline ch)
                req (DefaultHttpRequest.
                      (HttpVersion/HTTP_1_1)
                      (HttpMethod/GET)
                      (.toASCIIString uri))]
            (.setHeader req "Host" host)
            (.setHeader req "Connection" "close")
            (.addLast pipe "codec" (HttpClientCodec.))
            (.addLast pipe "aggregator" (HttpChunkAggregator. 65536))
            (.addLast pipe "handler" f)
            (.write ch req)
            nil))))))

;; Netty uses it's own thread pools
(def bootstrap
  (ClientBootstrap.
   (NioClientSocketChannelFactory.
    (Executors/newCachedThreadPool)
    (Executors/newCachedThreadPool))))
```

Now we can use go blocks and channels for the results.

```clojure
(time
   (def data-netty
     (let [c (chan)
           res (atom [])]
       ;; fetch them all
       (doseq [i (range 10 100)]
         (let [name (format "http://fssnip.net/%d" i)
               uri (java.net.URI. name)
               con-future (.connect bootstrap (java.net.InetSocketAddress. (.getHost uri) 80))]
           (.addListener
            con-future
            (connection-ok uri
                           (gen-response-handler
                            (fn [msg]
                              (go (>! c (.getContent msg)))))))))
       ;; gather results
       (doseq [_ (range 10 100)]
         (swap! res conj (<!! c)))
       @res
       )))

;; "Elapsed time: 6842.132 msecs"
```

Note that Netty isn't an ideal core.async example, since Netty comes with it's own thread pools and only one channel is used (for the results). A better example would make heavier use of go blocks (for both of the long running operations of a http request; the connection and the request).

## Summary

Here's the main take-away; if your code is using blocking APIs, no async framework can avoid your code hogging threads.

core.async isn't some magic that make problems with blocking IO disappear. While the go blocks and it's thread parking is very useful, they have to be used with care. Since the go block thread pool is quite small, it's easy to block all the threads and thus stopping all 'go processing'.

Never `Thread/sleep` in a go block, use `(<! (timeout *msec*))`!
