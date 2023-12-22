---
categories:
- clojure
date: "2012-02-18T00:00:00Z"
description: ""
tags:
- .net
- csharp
- clojure
- fsharp
- javascript
- jvm
- mono
- scala
title: Some thoughts on Clojure performance
---

_Edit_: This post recently re-surfaced on hacker news and caused a bit of a stir, mainly because of a slightly sensational/misleading title (was "Why is Clojure so slow?"). I wrote this before [Rich Hickey's Clojure/Conj 2011 keynote](http://www.youtube.com/watch?v=I5iNUtrYQSM) was published, in which he talks about most of my concerns (and outlines possible solutions).

Clojure is great in many ways, but one thing it can't be accused of is being particularly fast. What I mean by fast here is the speed in which Clojure programs execute. This is a well known issue in the Clojure community and have been discussed on the [mailing list](http://groups.google.com/group/clojure) and [stack overflow](http://stackoverflow.com/questions/2531616/why-is-the-clojure-hello-world-program-so-slow-compared-to-java-and-python). I am not intending to troll or fuel any fires here, just jotting down some of my findings when looking into the matter.

Measuring the speed of code is quite tricky, because there are many parts to a program. This is especially true for Clojure programs where the JVM, Clojure bootstrapping and dynamic compilation is part of the puzzle. But the fact remains, running tools like [Leiningen](https://github.com/technomancy/leiningen) (lein) or "jack-in" is annoyingly slow, mainly because Clojure programs takes a long time to "spin up". Further more, even when Clojure is up and running, it's not particularly fast compared to it's JVM cousins, see [The Computer Language Benchmarks Game](http://shootout.alioth.debian.org/).

## Getting going...
The slow startup time is probably what you will notice first when starting to code in Clojure. Anything from running your first "hello worlds" to starting the REPL is painful. Here's some average numbers for a simple "Hello world" program taken on a 2.5GHz Core2Duo MacBook Pro;

| Language             | Total running time OSX | Relative | Total running time Ubuntu | Relative |
|----------------------|------------------------|----------|---------------------------|----------|
| C (printf)           | 0.011s                 | 1        | 0.001s                    | 1        |
| C# (mono)            | 0.085s                 | 7.7      | 0.027s                    | 27       |
| F# (mono)            | 0.105s                 | 9.5      | 0.036s                    | 36       |
| Java                 | 0.350s                 | 32       | 0.038s                    | 38       |
| Scala                | 0.710s                 | 64.5     | 0.228s                    | 228      |
| Groovy               | 0.740s                 | 67.4     | 0.335s                    | 335      |
| JRuby (non-compiled) | 0.820s                 | 74.5     |                           |          |
| Clojure (uberjar)    | 1.250s                 | 113.5    | 0.652s                    | 652      |

What we can see it that Java itself accounts for 0.35s of the startup time, but unfortunately Clojure adds another second(!) on top of that. This 1.3s pause before main gets called is why Clojure is unsuitable for "terminal scripts". The running time of any scripts (like lein or starting the REPL) will be totally dominated by the startup time. Most Clojure developers will not notice this too much to, since they spend almost all their time in the REPL itself, but users of those Clojure programs will!

The CLR (mono) is about 4x faster getting going than the JVM. This is a big plus for the "#-py" languages. Also note that the difference between F# and C# is much smaller than Clojure and Java, so there isn't any excuse/president for more functional/declarative languages to start slower then their "bare" counterparts.

So why don't we use the Clojure/CLR on mono for stuff like lein then? Well, as it currently stands, the Clojure startup times are even worse on the CLR. The same hello world example as above clocks in a 1.8s! (using the debug Clojure/CLR assembly) - the difference between ClojureCLR and C# is an order of magnitude worse than Clojure and Java, some work left to be done in the ClojureCLR project...

### What's taking so long?
[Daniel Solano](http://www.deepbluelambda.org/) gave a talk at [Clojure/conj 2011](http://www.youtube.com/watch?v=1NptqU3bqZE) about Clojure and Android - [slides](https://github.com/relevance/clojure-conj/blob/master/2011-slides/daniel-solano-g%C3%B3mez-clojure-and-android.pdf), the performance part of that talk gives some valuable insights into Clojure internals and what happens when it starts up. My summary is that it spends 95% of the startup-time loading the clojure.core namespace (the clojure.lang.RT class in particular) and filling out all the metadata/docstrings etc for the methods. This process stresses the GC quite a bit, some 130k objects are allocated and 90k free-d during multiple invokes of the GC (3-6 times), the building up of meta data is one big source of this massive object churn.

_Edit_: By using the "-verbose:gc" flag when running the clojure test above, I notice a single collection, taking some 0.018s. This is different to Daniel's findings, but hardly surprising since he measured performance on the [Dalvik VM](http://code.google.com/p/dalvik/).

Daniel mentions a few ideas to improve the situation, and some of those ideas sounds pretty good to me;
* Having a separate jar for development (when you want all the docstring etc in the REPL) and a slim one with all that stuff removed to "runtime" jar (not to be confused with the existing clojure-slim jar file)
* Serialising the clojure.core initialisation so it can be dumped into memory from disk when starting up</li>

### ClojureScript to the rescue
ClojureScript and Google's blistering fast [javascript engine V8](http://code.google.com/p/v8/) is another way to go. When using the ClojureScript compiler on a hello word example with advanced optimisation, we end up with some 100kb of Javascript. The V8 engine runs this is in 0.140s, which is 2.5x faster than the "bare" Java version and 9x faster than the Clojure/JVM version! The [Google Closure](http://code.google.com/closure/) compiler certainly helps here by removing lots of unused code, and the resulting Javascript file is indeed free from all docstrings etc.

Also, Rich Hickey did mention ClojureScript as "Clojure's script story" when he [unveiled](http://blip.tv/clojure/rich-hickey-unveils-clojurescript-5399498) ClojureScript last year - one of the main benefits is the much improved startup time.

## Up and running...

How fast is Clojure at running your code once it finally has got going? A look around the [The Computer Language Benchmarks Game](http://shootout.alioth.debian.org/u32/which-programming-languages-are-fastest.php) gives you a good idea. Clojure is on average 4x slower than Java and 2x slower than Scala. There are a couple of reasons, and the biggest factor is Clojure's immutable data structures.

The fact is that immutable data structures will always be slower then their mutable counterparts. The promise of Clojure's persistant data structures is that they have the same [time complexity](http://en.wikipedia.org/wiki/Time_complexity) as the mutable equivalents, but they are not as fast - constant time factors do play a big role in running times. Most of the benchmarks above run for 50-200 seconds, so Clojure's startup time will be a factor in the results as well. Finally, dynamic languages a generally slower than static ones, because of the extra boxing overheads etc.

## Conclusion
Where does all this leave us? Clojure is a beautiful, powerful and very useful language, but (in it's current incarnation) not great for small script-y programs. The problems with startup time can be solved, either by changes to Clojure itself or by exploring the ClojureScript route. I personally like the javascript track; Javascript has lower processor and space overhead than the JVM, so by making ClojureScript-scripting better, Clojure can be more widely used, reaching embedded systems etc.

However, in order to make ClojureScript a viable option for non-browser programs, there are certainly more work to be done. Building on the [Node.js](http://nodejs.org/) integration looks like an interesting path forward...
