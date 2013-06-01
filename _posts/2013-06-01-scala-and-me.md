---
layout: post
title: "Scala and me"
description: ""
category: Scala
tags: [f#, scala, clojure, sicp]
---
{% include JB/setup %}

<div style="float:right"><img src="/assets/images/scalame/martin.png"/></div>

This epic journey (yeah right) began at Uni with discovering the mighty [SICP](http://mitpress.mit.edu/sicp/), still the best book on programming I've read (and let's face it, the best I will ever read). After that profound experience I kept an eye on the Lisp/FP world and wrote some toys in [Scheme](http://plt-scheme.org/), [ELisp](http://en.wikipedia.org/wiki/Emacs_Lisp), [OCaml](http://ocaml.org/) every now and then. One thing that dawned on me was that none of these languages had much practical use, they weren't very applicable to real-world software problems. While very clever and mind expanding, they seemed mainly an academic exercise. There were zero jobs out there using these languages. Heck, hardly anybody of my peers have heard nor cared about them.

Another problem with the early FP languages, which didn't come clear to me until java really took off, was that all those languages were islands. They had close to no libraries, so if you wanted to write an application with UI, socket connections etc you were stuck reinventing wheels. It made choosing such a language practically impossible.

My FP fire was rekindled in a big way when I joined a company in 2011, where an ex-Microsoft Research hacker ([Phil Trelford](https://twitter.com/ptrelford)) introduced me to [F#](http://fsharp.org/). I was aware of F#, but hadn't realised the most profound difference between F# and OCaml; it was a very practical language. By embracing the .NET platform and offering seamless C# interrop, you could leverage all the libraries AND the awesome power of ML. I got the opportunity to work on a few F# projects, some the mighty [Dr Harrop](https://twitter.com/jonharrop), and convinced myself that FP had a lot to offer mainstream software engineering. I was excited of my craft again, and started attending some FP conferences and user groups (mainly at [Skills Matter](http://skillsmatter.com/)).

At the same time I wanted to see if there were any other "practical" FPs out there. Naturally I looked on "the other" big runtime, and initially found Scala. I started browsing [Odersky's book](http://www.artima.com/shop/programming_in_scala_2ed) and there were lots of similarities with F#. I was primarily interested in the FP angle (there is certainly lots of clever OO stuff in Scala, which I glossed over at the time) -- but there were a few things that bugged me. The lack of "proper" [Hindley-Milner](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner) type inference was certainly one. I kept looking a bit more and found Clojure.

I was immediately attracted because of it being a Lisp, and after some more digging it turned out to be an extraordinary well-designed and clean language. Also a very opinionated one; FP and immutability all the way down, and tightly controlled [state transitions](http://clojure.org/state). Through some of my contacts from previously mentioned user groups, I've landed a Clojure gig as a contractor.

When Scala [2.10 was released](http://typesafe.com/blog/announcing-scala-210-a-simpler-way-to-tackle), my interest (in Scala) was peaked again. The work [Typesafe](http://typesafe.com) is doing on Async (which is hard on the JVM) and the momentum around Scala is impressive. I'm also an Erlang fan ([Armstrong's dissertation](http://www.sics.se/~joe/thesis/armstrong_thesis_2003.pdf) is an eye opener) so [Akka](http://akka.io/) is something I want to learn more about. I took the first [Scala Coursera course](https://www.coursera.org/course/progfun) (aced the quizzes thank you very much) and started reading Odersky again (this time the second edition). I really enjoy the power of case classes and pattern matching, and you have to be impressed by the innovation in the OO space that Scala is (in my opinion) spearheading.

I also recently started on a [Scheme interpreter in Scala](https://github.com/martintrojer/scheme-scala). This has become my standard way of learning a new language, I find a scheme interpreter is just big enough to drill into the guts of the thing. I'm enjoying my Scala implementation quite a bit.
