---
layout: post
title: "Announcing Frinj, a practical unit of measure calculator DSL for Clojure"
description: ""
category: clojure
tags: [clojure, frinj]
---
{% include JB/setup %}

I am proud to announce a new Clojure project called "Frinj".

Frinj is a practical unit-of-measure calculator DSL for Clojure.

Key features;
* Tracks units of measure through all calculations allowing you to mix units of measure transparently
* Comes with a huge database of units and conversion factors
* Inspired by the [Frink project](http://futureboy.us/frinkdocs/)
* Tries to combine Frink's fluent calculation style with idiomatic Clojure

Full source code available on <a href="https://github.com/martintrojer/frinj">github</a>.

To wet your apatite head straight over to the <a href="https://github.com/martintrojer/frinj/blob/master/src/frinj/examples.clj">sample calculations</a> page to see what Frinj can do!

I also want to explain that despite it's name, Frinj was never intended to be a clone of Fink, and thus does not support the entire Frink language. But since it's a Clojure DSL, it doesn't have to!

There was a couple of reasons I decided to create frinj;
* I wanted the power of frink but with Clojure idioms.
* I love Frink, and wanted to learn more about it.
* Frink isn't open source.
* I wanted to have some fun.

So please take it for a spin, it's damn fun!
