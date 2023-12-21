---
categories:
- clojure
date: "2012-05-17T00:00:00Z"
description: ""
tags:
- akka
- clojure
- erlang
- jvm
title: Distributed Actors in Clojure
---

Here's another post on a topic that have been discussed since the [dawn-of-time](https://groups.google.com/d/msg/clojure/Kisk_-9dFjE/_2WxSxyd1SoJ), is there is nice and idiomatic way to write Erlang/Actor style distributed programs in Clojure? There has certainly been a few attempts, but Rich's post (above) still holds true today.

First some clarification; I am not primarily thinking about number-crunching, map/reduce-y stuff, where Clojure has a pretty good story;

* [clojure-hadoop](https://github.com/stuartsierra/clojure-hadoop)
* [swamiji](https://github.com/amitrathore/swarmiji)
* [cacalog](https://github.com/nathanmarz/cascalog)
* [zookeeper-clj](https://github.com/liebke/zookeeper-clj)
* [storm](https://github.com/nathanmarz/storm)
* etc...

### Akka and the Erlang legacy
I am trying to write programs that solve problems in the areas where [Erlang](http://www.erlang.org/) typically excels such as

* Event-driven, asynchronous, non-blocking programming model
* Scalability (location transparency etc)
* Fault tolerance (supervisors, "let it crash")

The closest we've got on the JVM is [Akka](http://akka.io/), which claims to have all features (and more) listed above. Akka is the "[killer app](http://typesafe.com/stack)" for Clojure's sister-language Scala, and is very feature rich and performant. Levering it's power in a safe and idiomatic way is certainly appealing.

However, [interfacing to Akka from Clojure is not nice](http://blog.darevay.com/2011/06/clojure-and-akka-a-match-made-in/), and certainly not idiomatic. Some work is clearly needed in order to [improve Akka/Clojure interrop](https://gist.github.com/2716711#file_commented_vision.clj). The bigger question is if it's worth pursuing? Even if the interrop is made as pain-free as possible, how badly will it clash with Clojure's underlaying design and philosophy? For instance; Akka comes with a [STM](http://doc.akka.io/docs/akka/1.3.1/scala/stm.html), how nasty will that be when used in conjunction with Clojure's own?

**Update** 2 Akka/Clojure libraries has emerged since this article was written, which solves some of the problems I was facing; [akka-clojure](https://github.com/jasongustafson/akka-clojure) and [okku](https://github.com/gaverhae/okku). Perfomance compared to Scala/Akka is yet to be determined.

### Wishful thinking
Ideally, Clojure should support distributed actors in it's core, that looks, behaves and interrops nicely with it's other concurrency primitives. It's pretty easy to create a ideal-world straw-man for how this might look from a code/syntax perspective; [Termite](http://code.google.com/p/termite/) is a good place to start. Here is a cleaned-up version of the [hello-world examples in the gist above](https://gist.github.com/2716711).

```clojure
;; An (imaginary) actor macro takes an initial state and callback fns.
;; (actor {} (fn1 [state message]) (fn2 [state message) ...)

;; The most obvious callback fn is (receive [state message) that is called when a
;; message is consumed from the agents mailbox. receive is called with the old state
;; and the message as parameters -- it returns the new state.
;; sender is bound to the senders pid.

;; other callbacks are stuff broken link detection etc.

;; (spawn) creates a lightweight actor process, also has remote-actor semantics
;; (tell) is used to send messages to an spawned actor's pid.

(def hello-actor
  (actor {:world-actor
          (spawn
           (actor {}
                  (receive [state [message-type word :as message]]
                           (condp = message-type
                             :hello (do
                                      (tell sender (str (.toUpperCase word) "world!"))
                                      state)
                             (unhandled message)))))}
         (receive [state [message-type word]]
                  (condp = message-type
                    :start (do
                             (tell (:world-actor state) [:hello "hello"])
                             state)
                    (do
                      (println (str "Received message:" word))
                      (shutdown)))))

(let [pid (spawn hello-actor)]
  (tell pid [:start]))
```

Many problem arises, serialisation is a big one. Since Clojure's data structures can contain "anything", like Java objects, some limitations needs to be applied to strike a good usability / performance balance. Limiting the stuff you can distribute amongst actors to mimic Erlangs atoms/lists/tuples are probably a fair trade off (all you need is a hashmap right?), and maybe baking in [Google Protobuf](https://github.com/flatland/clojure-protobuf) for efficiency.

For data transport / socket stuff, I'd vote for using a message queue such as [0MQ](http://www.zeromq.org/) or maybe even [RabbitMQ](http://www.rabbitmq.com/), this would simplify and empower matters greatly.

With all that in place, it would be possible to build Clojure equivalents of Erlang's OTP, [Mnesia](http://www.erlang.org/doc/man/mnesia.html) etc, now that's a world I want to live in! :)

### More reading

- [Quickly get into the Erlang frame of mind](http://learnyousomeerlang.com/)
- A vision for Erlang-style actors in clojure-py [part1](http://clojure-py.blogspot.co.uk/2012/04/clojure-py-and-distributed-concurrency.html) [part2](http://clojure-py.blogspot.co.uk/2012/04/clojure-py-and-distributed-concurrency_18.html)
- [ErlangVM language with support for Lisp-style macros](http://elixir-lang.org/)
- [Clojure-style Lisp for the ErlangVM](http://joxa.org/)
- [Distributed STM for Clojure, for synchronously updating of shared state](http://avout.io/)
- [An attempt to mimic the Erlang programming model in Clojure](https://github.com/antoniogarrote/jobim)
