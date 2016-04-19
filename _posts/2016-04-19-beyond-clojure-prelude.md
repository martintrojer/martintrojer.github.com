---
layout: post
title: "Beyond Clojure: Prelude"
description: ""
category: beyond-clojure
tags: [clojure]
---
{% include JB/setup %}

Here we are, after five years of learning and later doing Clojure full time, I've come to the point where I am seriously looking around for alternatives. I've gotten very comfortable working in Clojure, and it has and will continue to serve me very well. But getting comfortable has a flip-side, you stop caring.

<!--more-->

The brain is a muscle like any other, it needs constant and regular exercise to thrive. Looking back at my arc, Clojure transitioned from a hobby to a job about 2 years ago. I haven't touched a single line of Clojure in my spare time since then, and I stopped writing on this blog. Its not good a situation, I want to care, I want to be passionate. But what I miss most of all is learning, and sadly Clojure stopped being an inspiration of learning some time ago.

Back when I started with Clojure it was hugely exciting, the old noodle was working hard devouring all the new techniques and the seemingly endless stream of [mind bending libraries](https://github.com/clojure/core.logic) that was released. Now, the Clojure ecosystem and community has matured and settled, and the headline-grabbing news are new build tools and proposed [web-frameworks](https://www.kickstarter.com/projects/1346708779/arachne-rapid-web-development-for-clojure). Sorry, but I can't muster an ounce of interest for either. I actually caught myself thinking the other day that I much rather re-write a 10k line Clojure service in Haskell than convert it from Leiningen to Boot.

Further, resentment against Clojure is building up in my mind as well. This is where we get into trickier waters, because here comes criticism. I just want to point out that what follows is my personal opinion, and that your experiences can (and will) differ.

## Types

Lets talk about the big one, and you knew it was coming. The lack of automated type checking is the built-in cancer in any dynamic language (dynlang). Clojure masks this better than any other dynlang I've seen, but its still there. I'd go so far to say that Clojure is the local maximum in the dynlang camp, but at the end of the day, its lipstick on a pig.

Before we get too deep into this matter, lets specify what kind of type systems I am talking about. Broadly I categorize type systems into 3 buckets;

* C-style languages (C++, Go, Java, C# ...) Types exist to make it easier for the compiler to do its job. Types are a chore that the developer has to put up with.

* ML-style languages (Miranda, OCaml, Haskell, F#, ...) Types exist to aid the programmer to validate the logical assumptions in the code.

* Scala. I'm still trying to figure out what the hell this is :-)

When talking about 'types' I'm referring to ML-style language type systems and nothing else. If your initial reaction to 'types' is nausea because you spent too long writing Java, I feel for you, but don't throw out the baby with the bath-water.

After years of working on real world large-ish (20k+ lines) Clojure code-bases, I've come to the conclusion that Clojure (like any other dynlang) doesn't scale. It doesn't scale on 3 very important axis in software development; code size, team size and time elapsed. The Achilles heel is refactoring. When I say refactoring, I am not talking about huge re-writes, but the day to day tweaks and shuffles that you do to a living code base. In Clojure, like Python and Ruby, you are basically stabbing in the dark. Keyword typos, shape changes of your nested maps, [nil punning](http://www.lispcast.com/nil-punning) etc all work against you. Maintaining any confidence that your change didn't break the code is near impossible.

On a high level, I've only seen 2 mitigation strategies that really work;

* Keeping a model of the entire code-base in your head (including all the subtleties). This works if you are the sole developer (which is true for many of the popular Clojure libraries for instance).

* A huge corpus of unit / integration / [quickcheck](https://github.com/clojure/test.check) tests (more than 50% of the total line count)

Neither of them scale on some or all of the 3 axis; when the code grows, when the team grows or when time elapses. The horrible truth is that Clojure code rots quickly. The end result is bugs, bugs and more bugs. Most of them are really subtle as well, its a long tail of bugs that is only found in production after weeks of uptime. Its the kind of bugs that, when fixed, are accompanied with the developer saying "Ahh, yes, I didn't think about that scenario".

The real tragedy here is that we Clojure developers think in types all the time when writing code, we just don't write them down (and let the computer validate them). I think that is a huge missed opportunity not to have the computer help us write better programs.

I'm sure you have lots of objections by now, and before we go on, [here is a recent talk about Typed Racket](https://www.youtube.com/watch?v=XTl7Jn_kmio) by a much more experienced person than myself, which addresses many of them (promise!), for instance where 'runtime contracts' (prismatic/schema in clojure-speak) and Typed Clojure plays in all this.

## UI programming

Somewhat surprisingly perhaps, the one area where the lack of types really bites is UI development. In most cases for us Clojurists UI means web front-ends, i.e. Clojurescript. The reasons why this area is particularly bad are many, but I've boiled it down to a couple of things.

* UIs are very complicated, they basically contain a pretty complete model of the backend, plus all user interaction complexities

* They are notoriously hard to write automated tests for

The lack of automated testing is the real killer for any reasonably sized Clojurescript code-base. The long tail of bugs I wrote about earlier is brutal with Clojurescript in my experience. You'll find yourself stuck in the 'fix 2 bugs introduce another' limbo forever.

In the backend, Clojure works better. Building a REST API, which is a machine API, is much easier to test. And with better test coverage, your confidence that the change you just made didn't break the other 42 endpoints can be reasonably high.

## An infestation of nulls

Another big bugbear of mine is nulls. And let me tell you, Clojure is a petri dish of them. We attach meaning and truthy-ness to nil of course, see [nil punning](http://www.lispcast.com/nil-punning). At first, this looks like a reasonable idea, but then you start finding the corner cases where it doesn't work. You stop trusting it, and viola, you are back in null-checking hell. NullPointerException is a very real thing in Clojure code-bases. Its a crying shame.

I don't think the majority of Node, Ruby, Java, Clojure developers are aware of the fact that there are languages out there without nulls. Its hard to explain how big of a deal to code quality this really is, it has to be experienced.

## What about REPL-driven development?

The killer app for dynlangs is the `eval` call, which enables REPLs. The data-centric approach of Clojure gives a fantastic experience when interactively looking and transforming data. Prime example here is pulling down some JSON and mapping, filtering, reducing it.

In Clojure you start off as a single developer in the REPL and the first week you are tremendously productive. You have the entire program in your head, you are whizzing around without any blockers, like type checkers pointing out your logical fallacies. The problems comes later, when you want more people working on the code or if you get back to it a few weeks later; "What the hell was I thinking here?".

All is not lost in typed land however, the languages I'm looking at do have REPLs (not using the strictest meaning of the word, but still, close enough). Further, F# is moving the needle with something called [type providers](https://msdn.microsoft.com/en-us/library/hh156509.aspx). I'm convinced this is a big deal, [here is an example](http://martintrojer.github.io/fsharp/2013/06/04/comparing-fp-repl-sessions). The difference is that while still being reasonably productive, you are building on a solid foundation.

# Beyond Clojure

I'm starting a blog series where I look at typed alternatives to Clojure, both for the Backend and Front End. They will be centered around a simple TodoMVC-ish app. In this series I will not only look at the code, but also offer views on the production-worthynes of the language in question, taking into account maturity, ecosystem etc. Another thing that is dear to my heart is the operations aspects, how to build, deploy, run and monitor services of apps written in these languages.

Think of this series as a 'grumpy Clojure guy looking at building web apps in different typed languages' kind of thing.
