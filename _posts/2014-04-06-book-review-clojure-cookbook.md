---
layout: post
title: "Book Review: Clojure Cookbook"
description: "clojure, review"
category: clojure
tags: []
---
{% include JB/setup %}

<div style="float:right"><img style="padding: 10px" src="/assets/images/cookbook/cover.png"/></div>

The Clojure Cookbook is part of the O'Reilly cookbook series. I'd describe this format as a 'curated wiki in print'. The wiki analogy is especially true for this volume since its contents was contributed by some 60 different developers. It's packed with small bite-sized recipes for solving common problems in Clojure. This is useful for developers in the entire spectrum from beginner to expert.

The content is organized into 11 chapters each containing a number of recipes. The chapter layout is clear and serves its purpose when looking for content. The book covers a lot of ground, all from working with primitives and basic data structures to dealing with databases, writing web apps and running hadoop jobs. Each recipe comes with code and/or REPL examples, so its very easy and enlightening to 'play along'. In contrast to other books with code snippets, the authors have made all recipes self contained (no other projects / files need to be created and run in order for the examples to work) which makes it very easy to dive in at any point in the book.

Each recipe also contain a reference section, often this is a URL to a javadoc and in some cases references to other books and resources. This make the Clojure Cookbook perfect for your first port of call when tackling a given problem -- if you want to dig deeper the references are a good starting point.

Some sections stand out to me, for example the sections on DateTime (which is always a headache in Java/Clojure) are rich, clear and very helpful. Implementing a Red-Black tree and parsers with core.match is interesting. The core.logic example is perfect primer for anybody wanting to come to grips with logic programming. Speeding up IO with reducers I also found very enlightening. The datomic recipes are actually easier to understand than most of datomic's own documentation.

There are some drawbacks with the 'wiki in print' approach. I made quite a few notes while reading the book, and I believe material like this should evolve and improve over time. For instance the part of mean/medium/standard-deviation should have a snippet on procentiles, and the part on generating random numbers should talk about secure randoms. It would be great to see this material on a wiki as well as in print. The clojure docs site is in desperate need of a refresh and a lot of the material in this book would be a perfect starting point.

I warmly recommend this book to all Clojure developers of any skill level. I suggest beginning with a proper read-through and then keeping a copy handy for looking up stuff when you need it. Chances are that after the first read-through, you (like me) immediately go back and clean up some of recent code.

This book will make you a better Clojure developer.
