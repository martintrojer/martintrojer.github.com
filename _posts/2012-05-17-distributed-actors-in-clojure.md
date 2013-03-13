---
layout: post
title: "Distributed Actors in Clojure"
description: ""
category: clojure
tags: [akka, clojure, erlang, jvm]
---
{% include JB/setup %}

Here's another post on a topic that have been discussed since the <a href="https://groups.google.com/d/msg/clojure/Kisk_-9dFjE/_2WxSxyd1SoJ">dawn-of-time</a>, is there is nice and idiomatic way to write Erlang/Actor style distributed programs in Clojure?&nbsp;There has certainly been a few attempts, but Rich's post (above) still holds true today.

First some clarification; I am not primarily thinking about number-crunching, map/reduce-y stuff, where Clojure has a pretty good story;
* [clojure-hadoop](https://github.com/stuartsierra/clojure-hadoop)
* [swamiji](https://github.com/amitrathore/swarmiji)
* [cacalog](https://github.com/nathanmarz/cascalog)
* [zookeeper-clj](https://github.com/liebke/zookeeper-clj)
* [storm](https://github.com/nathanmarz/storm)
* etc...

### Akka and the Erlang legacy
I am trying to write programs that solve problems in the areas where <a href="http://www.erlang.org/">Erlang</a> typically excels such as
* Event-driven, asynchronous, non-blocking programming model
* Scalability (location transparency etc)
* Fault tolerance (supervisors, "let it crash")

The closest we've got on the JVM is <a href="http://akka.io/">Akka</a>, which claims to have all features (and more) listed above. Akka is the "<a href="http://typesafe.com/stack">killer app</a>" for Clojure's sister-language Scala, and is very feature rich and performant. Levering it's power in a safe and idiomatic way is certainly appealing.

However, <a href="http://blog.darevay.com/2011/06/clojure-and-akka-a-match-made-in/">interfacing to Akka from Clojure is not nice</a>, and certainly not idiomatic. Some work is clearly needed in order to <a href="https://gist.github.com/2716711#file_commented_vision.clj">improve Akka/Clojure interrop</a>. The bigger question is if it's worth pursuing? Even if the interrop is made as pain-free as possible, how badly will it clash with Clojure's underlaying design and philosophy? For instance;&nbsp;Akka comes with a <a href="http://doc.akka.io/docs/akka/1.3.1/scala/stm.html">STM</a>, how nasty will that be when used in conjunction with Clojure's own?

**Update** 2 Akka/Clojure libraries has emerged since this article was written, which solves some of the problems I was facing; <a href="https://github.com/jasongustafson/akka-clojure">akka-clojure</a> and <a href="https://github.com/gaverhae/okku">okku</a>. Perfomance compared to Scala/Akka is yet to be determined.

### Wishful thinking
Ideally, Clojure should support distributed actors in it's core, that looks, behaves and interrops nicely with it's other concurrency primitives. It's pretty easy to create a ideal-world straw-man for how this might look from a code/syntax perspective; <a href="http://code.google.com/p/termite/">Termite</a>&nbsp;is a good place to start. Here is a cleaned-up version of the <a href="https://gist.github.com/2716711">hello-world examples in the gist above</a>.
<script src="https://gist.github.com/2716711.js?file=clojure-builtin-actor-vision.clj"> </script>

Many problem arises, serialisation is a big one. Since Clojure's data structures can contain "anything", like Java objects, some limitations needs to be applied to strike a good usability / performance balance. Limiting the stuff you can distribute amongst actors to mimic Erlangs atoms/lists/tuples are probably a fair trade off (all you need is a hashmap right?), and maybe baking in <a href="https://github.com/flatland/clojure-protobuf">Google Protobuf</a> for efficiency.

For data transport / socket stuff, I'd vote for using a message queue such as <a href="http://www.zeromq.org/">0MQ</a> or maybe even <a href="http://www.rabbitmq.com/">RabbitMQ</a>, this would simplify and empower matters greatly.

With all that in place, it would be possible to build Clojure equivalents of Erlang's OTP, <a href="http://www.erlang.org/doc/man/mnesia.html">Mnesia</a> etc, now that's a world I want to live in! :)

### More reading

<ul>
<li><a href="http://learnyousomeerlang.com/">Learn you some Erlang for Great Good</a><br />Quickly get into the Erlang frame of mind</li>
<li>A vision for Erlang-style actors in clojure-py<br /><a href="http://clojure-py.blogspot.co.uk/2012/04/clojure-py-and-distributed-concurrency.html">Part1</a> and <a href="http://clojure-py.blogspot.co.uk/2012/04/clojure-py-and-distributed-concurrency_18.html">Part2</a></li>
<li><a href="http://elixir-lang.org/">Exlir</a><br />ErlangVM language with support for Lisp-style macros</li>
<li><a href="http://joxa.org/">Joxa</a><br />Clojure-style Lisp for the ErlangVM</li>
<li><a href="http://avout.io/">Avout</a><br />Distributed STM for Clojure, for synchronously updating of shared state.</li>
<li><a href="https://github.com/antoniogarrote/jobim">Jobim</a> <br />An attempt to mimic the Erlang programming model in Clojure</li>
</ul>