---
layout: post
title: "Announcing Frins, a practical unit of measure calculator DSL for Scala"
description: ""
category: scala
tags: [scala, frinj, frins]
---
{% include JB/setup %}

I am proud to announce a new Scala project called "Frins".

Frins is a practical unit-of-measure calculator DSL for Scala.

Key features;
* Tracks units of measure through all calculations allowing you to mix units of measure transparently
* Comes with a **huge** database of units and conversion factors
* Inspired by the [Frink project](http://futureboy.us/frinkdocs/)

Full source code available on [github](https://github.com/martintrojer/frins).

To wet your appetite head straight over to the [example calculations](https://github.com/martintrojer/frins/blob/master/src/main/scala/frins/ExampleCalculations.scala).

### How Frins came about

About a year ago I created [Frinj](https://github.com/martintrojer/frinj). With Frinj I tried to marry some of the joys of one of my favorite programming languages (Frink) with the Clojure REPL. I was quite pleased with the results, and the response was encouraging.

Recently I started reading [Odersky](http://www.amazon.co.uk/Programming-In-Scala-2nd-Edition/dp/0981531644) (again) and when I came to the chapter on implicit conversions I got the idea of trying to create a Frinj style DSL for the Scala interpreter. I could leverage some of the efforts made in Frinj (like parsing the Frink unit database) and the result is quite cool.

It's indeed possible to create a very fluent and powerful DSL using some of Scala's core language constructs!

<script src="https://gist.github.com/martintrojer/5861174.js"> </script>
