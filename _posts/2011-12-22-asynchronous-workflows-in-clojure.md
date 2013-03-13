---
layout: post
title: "Asynchronous workflows in Clojure"
description: ""
category:
tags: [.net, clojure, f#, jvm]
---
{% include JB/setup %}

Asynchronous workflows is a very powerful feature of F#, and recently I wanted to explore the state of the JVM and in particular Clojure when it comes to replicate the functionality. In this post I'll share some of my findings and I'll include some background material to explain the problems.

Let's start with an example of a webclient using "async" in F#.
<script src="https://gist.github.com/1694970.js?file=fhsarp-async.fs"> </script>
The magic here is that you can write continuation-style code in a sequential manner. This combines the scalability of asynchronous programs with the readability of sequential code. So, what lessons can we learn from this code and how would we do this with the JVM and Clojure? First of all, this is not the same as using futures over blocking calls;
<script src="https://gist.github.com/1694970.js?file=blocking-future.clj"> </script>
While naively this looks good; we are handing over some tasks to a worker thread, but this is infact the old "one thread per connection" chestnut. It will spawn a thread in a thread pool that just sits around and waits for the IO to complete. Here is a picture (credit to <a href="http://tomasp.net/">Tomas Petricek</a>) that tries to visualise the problem;
<p align="center"><img src="/assets/images/asyncclj/oneperconnection.png"></p>

In our example we have 2 function calls that can take a long time; _openStream_ and _line-seq_ (of the BufferedReader). Unfortunately these 2 calls are both blocking, so like in the picture, our thread spends most of it's time blocked. What the F# code above achieves, is that while the the GetResponse and ReadToEnd function wait for the result, the thread yields (back to the thread pool) and other tasks can do work on that thread. See this picture of how we can get the same amount of work done with just 2 threads.
<p align="center"><img src="/assets/images/asyncclj/asyncthreads.png"></p>

Why is it so bad with many threads you might wonder. Well, first of all they are expensive, both in the JVM and on .NET. If you want to write some code that can scale to thousands of connections, one thread per connection simply doesn't work. If you are using futures like above, when you try to make thousands of simultaneous connections, they will just queue on the thread pool, and the threads that are claimed will spend almost all their time blocked on IO (plus it will be dominated by accesses to slow servers). So either you kill you system spawning thousands of threads or you take for ever to complete when the thread pool slowly easts through the queued up work.

We need non blocking versions of openStream and the readers to have a chance to make this work. While .NET have plentiful supply for async begin/end "callback" APIs, the JVM has been relying on 3rd party libraries such as <a href="http://www.jboss.org/netty">Netty</a>. Java7 shipped with something called "NIO.2" which provides async channels for sockets and files, but it's still quite new and is hard to get on for instance OSX.

Let's get back to our web client example; here's how a better version could look like using Netty;
<script src="https://gist.github.com/1694970.js?file=netty-http-req.clj"> </script>
This example downloads 70 F# snippets in parallel. This is better than the sequential code since execution has been broken up in 2 callbacks (one for each long running operation). It is also better than the naive "future" code since the threads yield back to the thread pool when they are blocked on IO. The _connection-ok_ callback is called (from a netty pool thread) when a connection to the web server is established. Here we trigger the "GET" request from the server. The second callback is the _response-handler_, where we log the read data in an Clojure agent. When we run this example we are closer to the second "interleaved" picture above, and we are not consuming one thread per connection.

We managed to solve the scalability problem, but we also made the code much harder to read and maintain. And if we were to make this code "real" it would get even worse. All error handling try/catch would have to be duplicated in all callbacks, since they are run in separate contexts. Just imagine what happens when we have more than 2 callbacks!

How can we get closer to the F# example above? One solution is to embrace the concept of channels and pipelines and wrap the netty internals in some Clojure idiomatic way. Fortunately this is exactly what the projects <a href="https://github.com/ztellman/lamina">lamina</a> and <a href="https://github.com/ztellman/aleph">aleph</a> have done. With aleph the example above can be written as succinctly as this;
<script src="https://gist.github.com/1694970.js?file=aleph-lamina.clj"> </script>
Errors will propagate on the result channel, so they can be handled in one place.&nbsp;Lamina also provides an async macro, taking is a little bit further to the F# example above.
<script src="https://gist.github.com/1694970.js?file=aleph-async.clj"> </script>

### Conclusion
We managed to create a solution in Clojure/netty/aleph that was scalable, and almost as readable as the F# starting point. However, we only covered network accesses in this post. The fact is that the JVM is far behind .NET in the standardisation of asynchronous APIs. Where on .NET the Async begin/end pattern is common in anywhere where you have long-running operations, the JVM user is left to 3rd party libraries, all with their own non compliant APIs. Java7 today only supports network and file access, but it's async recipe can hopefully be a new standard that can proliferate to other areas (database access etc). This could set some kind of API standard making it easier to interface to. In the Clojure world, I think the channels approach set out by the lamina project is promising, and could well be considered to merge into clojure.contrib.