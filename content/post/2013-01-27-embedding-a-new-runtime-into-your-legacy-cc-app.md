---
categories:
- software
date: "2013-01-27T00:00:00Z"
description: ""
tags:
- .net
- csharp
- fsharp
- gnu
- guile
- javascript
- lisp
- lua
- mono
title: Embedding a new runtime into your legacy C/C++ app
---

Let's say you have a big / legacy C++ app, then you're undoubtedly covered by [Greenspun's tenth rule](http://en.wikipedia.org/wiki/Greenspun's_tenth_rule). Let's also say that your home-grown, buggy and slow DSL / scripting language has been pushed to the limit and can not be tweaked any further. What do you do, how can you replace it?

As you might expect, this is quite a common problem, and embedding scripting languages into a big C/C++ monolith is popular. There are famous examples from gaming where [Lisps](http://en.wikipedia.org/wiki/Game_Oriented_Assembly_Lisp) and [Lua](http://www.wowwiki.com/Lua) are widely used.

In this post I'll focus on 4 options; [Mono](http://www.mono-project.com/Main_Page), [JavaScript / v8](http://code.google.com/p/v8/), [Guile](http://www.gnu.org/software/guile/) and [Lua](http://www.lua.org/). I only picked runtimes where true 'scripting' is possible, thus all of them are managed environments with garbage collection. I will try to categorize these 4 with some key metrics that is of interest when embedded runtimes. I assume that you need to "properly" embed these runtimes, i.e. creating a RESTful micro service is not an option.

Benchmarking figures for most of these runtimes are available on [Alioth](http://benchmarksgame.alioth.debian.org/).

### Option 1/ Heavy-weight full blown generic runtime - Mono (.NET)
Mono is an open-source implementation of the [Microsoft's Common Language Runtime (CLR)](http://msdn.microsoft.com/en-us/vstudio/aa569283.aspx) and a few tools such as a C# compiler etc. The project has been going for 8 years now and has been making steady progress. Version 3 introduced a new [generational garbage collector](http://www.mono-project.com/Generational_GC), and overall it's performant and stable. It is possible to [embed into your application](http://www.mono-project.com/Embedding_Mono), but you have to realise that Mono/CLR is a generic VM specified at byte-code level. It's intended to be the target of many languages compilers, even if C# is the most commonly known. .NET is one of the corner-stones of Windows, so it comes with mechanisms for versioning and signing it's "assemblies" (executables / libraries) and storing them in a central depot (the global assembly cache, GAC). Mono includes most of these features as well.

|                                             |                                                                                                    |
|---------------------------------------------|----------------------------------------------------------------------------------------------------|
| Pros                                        | - General purpose, supports many languages                                                         |
|                                             | - Speed                                                                                            |
|                                             | - Big eco-system with [ready-made libraries](https://www.nuget.org)                                |
|                                             | - Multi threaded applications                                                                      |
|                                             | - Great IDE support                                                                                |
| Cons                                        | - Big                                                                                              |
|                                             | - Somewhat clunky [interrop with native code](https://www.mono-project.com/docs/advanced/pinvoke/) |
|                                             | - Assemblies needs to be stored/shipped in binar form, not as simple scripts                       |
|                                             | - No natural way to work with the GAC from the embedded VM                                         |
|                                             | - C# and F# are statically typed languages (might not be a great fit for scripting purposes)       |
|                                             | - Hard to static-link (embed) into your app                                                        |
| Size of (static-linked) hello world example | 12MB                                                                                               |
| Time of running hello world example         | 70ms                                                                                               |
| License                                     | LGPL                                                                                               |
| Future proof (10 years from now)            | 3 out of 5                                                                                         |
|                                             |                                                                                                    |

The static-link issue can be a major headache when embedding Mono. Other than this it's a very powerful and stable runtime. Mono can also use LLVM for it's JIT code generation making is suitable for many different CPU architectures. The fact that C# and F# "scripts" need to be shipped / stored as binary assemblies can be a deal-breaker if you're looking for a easily editable/patchable script solution. Note that this is only true for the compiled CLR languages as C# / F#, IronPython/Clojure for instance can be shipped in source.

### Option 2/ Medium-weight, not-so generic runtime - Javascript V8
Javascript is [huge language nowadays](http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html) and the runtime implementations in the big browsers (except maybe IE) are now very sofisticated and fast. In fact, [v8 is on par with Mono/C#](http://benchmarksgame.alioth.debian.org/u32/benchmark.php?test=all&lang=v8&lang2=csharp), that is a quite astonishing fact if you consider the nature of the Javascript language and what v8 has to do in order to run that fast. V8 has been [designed to be embeddable](https://developers.google.com/v8/get_started) and offers also [nice and easy interrop](https://developers.google.com/v8/embed).

|                                             |                                                                                            |
|---------------------------------------------|--------------------------------------------------------------------------------------------|
| Pros                                        | - Fast                                                                                     |
|                                             | - Small                                                                                    |
|                                             | - Wide industry usage                                                                      |
|                                             | - Big ecosystem (node.js is a great source)                                                |
|                                             | - Easy to embed / interrop (again, node.js is a great example)                             |
|                                             | - Reads scripts in source format so they can be stored/shipped in that manner              |
|                                             | - Dynamically typed                                                                        |
|                                             | - Huge industry uptake, you can safely assume that all your new devs will know it          |
| Cons                                        | - Single threaded                                                                          |
|                                             | - [Quirky syntax and other language artefacts](http://www.youtube.com/watch?v=kXEgk1Hdze0) |
| Size of (static-linked) hello world example | 5.5MB                                                                                      |
| Time of running hello world example         | 25ms                                                                                       |
| License                                     | New BSD License                                                                            |
| Future proof (10 years from now)            | 5 out of 5                                                                                 |
|                                             |                                                                                            |

Due to the fact that all browsers can run javascript, the language have unmatched reach. Over the last couple of years it has become the "bytecode of the web", meaning that lots of languages/compilers has emerged that targets javascript. For example; [CoffeScript](http://coffeescript.org/), [ClojureScript](https://github.com/clojure/clojurescript), [TypeScript](http://www.typescriptlang.org/) to mention just a few.

### Option 3/ Medium-weight, generic runtime - Guile
Guile is the official extension language in the GNU universe. Originally it's been a <a href="http://en.wikipedia.org/wiki/Scheme_(programming_language)">Scheme</a>, but with guile2.0 parsers for Javascript, [Emacs lisp](http://en.wikipedia.org/wiki/Emacs_Lisp) was added. Support for Lua is also in the works. The idea is to expose the innards of your app to scheme programs, in the form of Scheme functions, and thus making it possible for you and your users to use the software in a very flexible way.

|                                             |                                                      |
|---------------------------------------------|------------------------------------------------------|
| Pros                                        | - Good interrop                                      |
|                                             | - Very powerful language                             |
|                                             | - Dynamically typed                                  |
| Cons                                        | - Quite slow, order of magnitude slower than Mono/v8 |
|                                             | - Hard to static-link (embed) into your app          |
|                                             | - Small ecosystem of ready-made libraries            |
|                                             | - Restrictive licensing                              |
| Size of (static-linked) hello world example | 5MB                                                  |
| Time of running hello world example         | 20ms                                                 |
| License                                     | GPL                                                  |
| Future proof (10 years from now)            | 5 out of 5                                           |
|                                             |                                                      |

Picking a Lisp for you scripting might seem controversial, but the level of expressiveness it gives in unmatched by any other language. If licensing is problem, there are other Scheme implementations worth considering, [Chicken](http://www.call-cc.org/), [Gambit](http://gambitscheme.org/wiki/index.php/Main_Page), [Bigloo](http://www-sop.inria.fr/indes/fp/Bigloo/). [Guile tends to be slowest](http://www.cs.utah.edu/%7Emflatt/benchmarks-20100126/log3/Benchmarks.html) of them all. Guile also shares some of the headaches with Mono when it comes to static compile it into your app.

### Option 4/ Light-weight, single-language runtime - Lua
Lua is a popular embedded scripting language in games ([world of warcraft](http://www.wowwiki.com/Lua)) and many embedded systems. It's extremely small and draws a lot of it's power from it's simplicity. It's also very easy to interrop with your existing code. Lua was specifically designed to be embedded and interrop easily.

|                                             |                                           |
|---------------------------------------------|-------------------------------------------|
| Pros                                        | - Extremely lightweight                   |
|                                             | - Amazing interrop                        |
|                                             | - Simple yet powerful language            |
|                                             | - Broad industry uptake                   |
|                                             | - Dynamically typed                       |
| Cons                                        | - Slow (about 30x slower than v8/mono)    |
|                                             | - Single threaded                         |
|                                             | - Small ecosystem of ready-made libraries |
| Size of (static-linked) hello world example | 198KB                                     |
| Time of running hello world example         | 12ms                                      |
| License                                     | MIT                                       |
| Future proof (10 years from now)            | 5 out of 5                                |
|                                             |                                           |

The slowness of Lua has been adressed in the [LuaJIT project](http://luajit.org/), which indeed produces some very impressive numbers, well worth a look.

### Summary
While these 4 aren't a complete list, I believe they cover many bases. Other popular embeddable languages include Python and Ruby, I'd put them in the same group as Guile when it comes to complexity and performance. The safest option in most cases is IMHO Javascript / v8. It's got the speed, industry acceptance and developer familiarity. If you have a resource constrained system, Lua is very attractive. Finally, if you're looking for maximum expressiveness in your embedded language Scheme/Guile is hard to beat.
