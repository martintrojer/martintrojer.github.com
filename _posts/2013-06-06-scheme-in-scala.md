---
layout: post
title: "Scheme in Scala"
description: ""
category: scala
tags: [scala, scheme]
---
{% include JB/setup %}

In this post I present some of my experiences writing a [Scheme interpreter in Scala](https://github.com/martintrojer/scheme-scala) (as an external DSL) and compare it with my recent similar experiences in Clojure and F#.

Overall, the Scala solution is very similar to the [F# one](https://github.com/martintrojer/scheme-fsharp). Not very surprising, since the problem lends itself well to case classes / discriminated union types and pattern matching. One difference is more type declarations in Scala, due to the lack of a Hindley-Milner type inference. Scala uses a "flow based" type inferrer, which is less powerful than ML, but apparently works better for OO sub-classes etc. I will look into this in a future blog post.

Here's the eval / apply functions;
<script src="https://gist.github.com/martintrojer/5707573.js?file=eval-apply.scala"> </script>

## OO vs. FP

Scala feels like a OO language with FP features, where Clojure and F# appears the other way around. In Clojure and F#, you typically group functions that somehow "belong together" in namespaces/modules, in Scala you put them in classes and objects (scala speak for singletons). You can treat these object like namespaces if you want, but that doesn't feel like idiomatic Scala. One example of this, in this particular case, is the environment (or stack) functions that sat quite happily in the interpreter namespace in F# / Clojure. In Scala that felt awkward, I ended up creating a [Env class](https://github.com/martintrojer/scheme-scala/blob/master/src/main/scala/mtscheme/Env.scala), with some methods, to model this better.

This Scheme implementation is still very FP, and I don't really feel the OO parts gets in the way. But it highlights the issue that Scala isn't a very opinionated language. Many paradigms are supported; Old-school OO with mutable variables / collections is idiomatic just as strict immutable, function-oriented code. Discipline is needed if a codebase of any size, worked on by many individuals, is to be kept coherent.

Scala tries to fix some of the common problems found in popular OO languages, with featrues like [abstract types](http://www.scala-lang.org/node/105), [implicits](http://blog.joa-ebert.com/2010/12/26/understanding-scala-implicits/), [co/contra-variance](http://blogs.atlassian.com/2013/01/covariance-and-contravariance-in-scala/) and more. It's all very clever stuff, but be prepared to spend quite a bit of time getting the type declarations right if you want to leverage all this.

It can be argued that time is better spend working on the problems/functions themselves instead of messing about with clever type annotations ([speaking to the problem vs speaking to the compiler](http://vimeo.com/16753929#)). The just as valid counter-argument is that once you gotten your types and model right, the type system will help you drive your code and eliminate many logical errors early. I do enjoy that warm fuzzy feeling you get when to compiler tells you about forgotten pattern match cases, and the "if it compiles it works" experience.

## Parsing

I'm really impressed by [scala.util.parsing.combinator](http://www.scala-lang.org/api/current/index.html#scala.util.parsing.combinator.Parsers). The code below is the entire parser, both readable (once you get the hang of it) and powerful.
<script src="https://gist.github.com/martintrojer/5707573.js?file=Parser.scala"> </script>
The way you map the parse results onto your own type domain is fantastic. Contrast this is an example of a [hand rolled parser](https://github.com/martintrojer/scheme-scala/blob/master/src/main/scala/mtscheme/HandRolledParser.scala), which still is pretty neat if you ask me, but much more code.

## IDE vs Emacs and REPLs

I decided to use IntelliJ for this project, and the experience was much better than when I used the abysmal [Eclipse/Scala](http://scala-ide.org/index.html) package 4-5 months ago. Maybe the Eclipse integration is better now, but I've been scarred for life. I have no complaints really, all the IntelliJ goodness and a pretty rock solid compile/debug/run tests work flow. You can also drop into the [SBT](http://www.scala-sbt.org/) console, which is similar to the F# interactive stuff in Visual Studio -- which give you a REPL-like shell where you can get to your objects that your currently writing.

I did quickly fall into the old trodden tracks of writing unit test to drive my coding. Coming from Clojure this is a bit of a change where work is much more interactive, in the REPL, and unit tests feels more like an afterthought. The compiler is also more apparent working with Scala, while is pretty well hidden in the Clojure flow. One of the reasons it's more in your face is because it's a lot slower, which is understandable since it's doing a lot more. That fact that there is an obvious compile step also drives you towards "old" work flows.

Scala [Emacs integration](https://github.com/aemoncannon/ensime) looks promising, but I didn't use it enough to give a verdict. However, I do feel that due to the OO aspects of Scala, an traditional IDE is probably a better fit. I used the refactor functions in IntelliJ frequently. I also used the debugger on occasion, and it's hard to beat an IDE in that area. Dropping stack frames in the debugger and running again etc is powerful stuff.

Finally, JVM hot-swapping is less useful in Scala than Java, due to how many classes etc is generated under the covers even for quite small changes. It's a bit sad, since it's a real time saver working with Java, maybe this is better with JRebel?

## Speed

Let's compare the execution speed (using a silly little benchmark) of these interpreters I've written (and a native scheme implementation). All run on Linux, JDK1.7.0_21 x64, Mono 2.10.8.1. Results in milliseconds.

<div align="center">
<table border="1">
<tbody>
<tr><td/><td>100 x (fact 50)</td><td>10000 x (fact 50)</td></tr>
<tr><td><a href="https://github.com/martintrojer/scheme-scala">Scala</a> (2.10.1)</td><td>580</td><td>58800</td></tr>
<tr><td><a href="https://github.com/martintrojer/scheme-clojure">Clojure</a> (1.5.1)</td><td>300</td><td>29700</td></tr>
<tr><td><a href="https://github.com/martintrojer/scheme-fsharp">F#</a> (3.0)</td><td>80</td><td>6600</td></tr>
<tr><td><a href="https://github.com/martintrojer/scheme-python">Python</a> (2.7.4)</td><td>420</td><td>40500</td></tr>
<tr><td><a href="http://www.call-cc.org/">Chicken Scheme</a> (4.8.0)</td><td>4</td><td>150</td></tr>
<tr><td><a href="https://github.com/martintrojer/scheme-clojure">Clojure embedded</a></td><td>1</td><td>40</td></tr>
</tbody>
</table>
</div>
<br/>
I'm a bit surprised with the results here, Scala is quite slow and F# is very fast. If you consider that the F# and Scala implementations are fundamentally identical, my only conclusion can be that Scala pattern matching is slow. Daniel Spiewak alluded to this in a [recent talk](http://2013.flatmap.no/spiewak.html), if I understand him correctly, it is much faster (in Scala) to replace pattern matches with 'polymorphic operators' -- [here's an example](https://gist.github.com/martintrojer/5646283).

If you watch that talk, it boils down to different ways to tackle the expression problem, where pattern matches and 'polymorphic operators' are on different extremes on the spectrum. However, it doesn't explain why pattern matching in Scala is so much slower than F#.

If you are interested how these benchmarks were run, here's some [snippets](https://gist.github.com/martintrojer/5719803).
