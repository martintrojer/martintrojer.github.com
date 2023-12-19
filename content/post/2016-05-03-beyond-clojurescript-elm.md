---
categories:
- beyond-clojure
date: "2016-05-03T00:00:00Z"
description: ""
tags:
- clojure
- clojurescript
- elm
title: 'Beyond ClojureScript: Elm'
---

This is a post in the [Beyond Clojure](/categories/beyond-clojure/) blog series, in which a Clojure developer looks at typed languages for web app development. In this episode we look at front-end development in the language Elm.

Front end development targeting web browsers is a ghetto, everybody seems to agree. The core tools at our disposal are the amalgamation of ideas and accidents thrown together without much overall strategy. One positive development in recent years has been the drastic improvement of the JavaScript (JS) engines in popular browsers. They have now gotten so good that its a valid option to treat JS as a compilation target. This fact is one of the drivers behind the explosion of JS transpilers, there are now literally hundreds of languages that (either primarily or as an after-though) can compile to JS. These languages range from light syntax improvements (ala [CoffeScript](http://coffeescript.org/)) to full blown languages with big runtimes and everything in between.

<!--more-->

## Elm

[Elm](http://elm-lang.org/) is a purely functional, strongly typed language, designed to write UIs in the browser. Elm is built upon immutable values (using persistent data-structures) and [functional reactive programming](https://en.wikipedia.org/wiki/Functional_reactive_programming) (FRP) design principles. Further, Elm is a language with 'controlled effects', i.e. code with side effects are tracked by the type system. Key concepts are 'signals' (similar to observables in [Reactive Extensions](http://reactivex.io/)) and 'foldp' (fold past) by which a step function can update its state based on the old state and an event. Every Elm program is in effect a (static) signal graph where inputs are transformed, internal states updated and finally put on one or more output signals. This design, subtly more constrained compared to Rx, results in a number of very powerful benefits. For example, Elm takes interactive development to new heights with [hot-swapping](http://elm-lang.org/blog/interactive-programming) and [time travel debuggers](http://debug.elm-lang.org/). One would expect that such impressive features are a bunch of smoke and mirrors, but in fact they fall neatly out of the FRP design principles that Elm sticks to. The language comes across as very well designed.

Another important result of how FRP works in Elm is that programs gravitates to a certain structure, known as the 'Elm Architecture'. I find this particularly appealing since it clearly separates the model, state-updating actions and rendering. There is no, render-loop-updating-the-model, cross-talk that is ripe in many JS frameworks. The Elm community has taken this one step further by the use of the [StartApp library](http://package.elm-lang.org/packages/evancz/start-app/2.0.2/). This gives the apps a Rails-like uniformity further improving readability. There is nothing stopping structuring your Elm app differently, but you have to ask yourself why. In most cases its easy to read and understand your own (and others) Elm code.

One thing that really stands out working with Elm is the compiler error messages. No other language I've seen comes close to how understandable they are. Cryptic type errors have always been one of the biggest objections to ML type systems but Elm totally nails this area. It throws down the gauntlet and puts pretty much every other language (typed or dynamic) to shame. The nonsensical runtime errors given by Clojurescript is a particularly stark contrast.

### JS interrop

One crucial feature of compile-to-JS languages is easy interrop with existing JS APIs and libraries. Given Elm's stance on type safety and controlled effects, enabling code to just 'call out' to JS functions isn't going to work. Instead, interrop is done via the same signal mechanism as the rest of the program, and these signals are sent to and from JS land via 'ports'. A Elm program interacts with JS in a client/server manner and ports acts as gatekeepers enforcing type-safety. 'Tasks' are asynchronous IO effects that can return either a result or an error. The Task type play a similar role to IO in Haskell, and the 'Result' type corresponds to Either.

Working with JS is more cumbersome than Clojurescript, since you have to write this port plumbing. It does however work well and I am happy to pay the price to keep sanity in the Elm part of my app. Most of the common JS API interactions you'll need has a corresponding Elm library at this point, but there will be times where you have to take time out of your busy schedule to write port code (which would be a one-line function call in Clojurescript).

### Ecosystem and tooling

Elm is a young language and because of this it will not have the same number of libraries compared to other more established ones. This problem is somewhat mitigated since the area of front end development well covered by JS libraries (which Elm can interrop with). You will find yourself tapping into JS libraries every now and then and its not a big deal.

The Elm libraries that do exist tend to be of high quality. Not only that, they are also mostly well documented. Elm has a guideline for library developers that results in uniform documentation and descriptions. Its also gives you versioning that you can trust. A patch release is really a patch release. This fact makes consuming Elm libraries a very pleasant experience. The coding style guide is also widely followed making scanning others Elm code a breeze. I used the tool [elm-format](https://github.com/avh4/elm-format) frequently to get my source layout just right and so far it has worked flawlessly.

The elm package manager works well and each project is sandboxed by default, much like the local 'node_modules' folder using npm. Packages are git(hub) backed which works great most of the time. One problem is that it can't pull from private repos (workarounds do exist). The package manager has a 'diff' command, which will show all the API changes between two versions. Very handy.

Another detail that is very close to my heart is that Elm libraries tends to use 'simple names', i.e. they are called what they do. The Clojure community have a deeply routed 'disease' of coming up with clever names for libraries. The problem with clever names is that they add extra mental steps between what you need and the clever-70s-movie-reference-name. I personally much prefer a name like 'elm-mustache' for a library dealing with mustache templates.

My development setup is Emacs and elm-mode and I have no complaints. I tend to flip between [Elm reactor](https://github.com/elm-lang/elm-reactor) and [Webpack](https://webpack.github.io/) plus [elm loader](https://github.com/rtfeldman/elm-webpack-loader) to trigger my builds and serve all the resources I need during development. Elm reactor is the default tool for interactive Elm development with features like on-the-fly compilation, hot-swapping and the time travel debugger.

### Size and perf

A Elm app includes the runtime and the (compiled output) of the libraries you pull in. Unlike Clojurescript, it does not rely on the Google Closure compiler for dead code elimination. Thus I'd expect a Elm release artifact to be bigger than the equivalent Clojurescript one. A simple 'write hello world to a div' in Elm weighs in at about 40k minified and gzipped. This does include the core runtime, elm-html and the [virtual-dom](https://github.com/Matt-Esch/virtual-dom) JS package. So Elm apps doesn't start off huge, how big they grow to be is a thing that you need to monitor, and if you are size restricted you have to pay extra attention when pulling in new libraries. The Elm compiler supports incremental compilation is generally fast. Compared to Clojurescript compiling Elm is extremely fast, mostly because its not relying on Google Closure. I've seen Clojurescript builds taking up to 5 minutes on CircleCI, an equivalent Elm build would be less than 10 seconds.

Elm apps typically perform extremely well. Elm does not use React like most Clojurescript apps but a similar library called virtual-dom. These virtual dom differs fare particularly well when coupled with immutable data structures, see these (now slightly outdated) [performance comparisons](http://elm-lang.org/blog/blazing-fast-html).

### Innovation speed

Everyone knows that the JS ecosystem moves at blinding speed. One development that has caught the attention of Clojuresript developers are 'post REST' technologies such as Facebook's [GraphQL](https://github.com/facebook/graphql) and Netflix' [Falcor](https://github.com/Netflix/falcor). Elm moves slower than Clojurescript but from the mailing lists its clear that the main contributers actively tracks these technologies. If one of these JS libraries really takes off I'm certain support will be added. Don't expect Elm to be the first compile-to-JS language to adopt red-hot JS frameworks but at the same time you shouldn't fear being left out of the 'next big JS thing'.

Elm currently doesn't have a story for Node. This is an area that is being worked on and I'd say its only a matter of time before it happens. Expect a solution for server side rendered Elm apps in a not too distant future.

### Working in a safe language

I'm on the opinion that UI development is an area where a good type system is perhaps even more helpful than for backend services. UIs are very complex, they typically consists of a pretty complete model of the backend plus having to deal with all the human interaction complexities. The human interaction part is especially troubling, since its very hard to write tests for these. What you end up with is large parts of your code untested, which in turn exposes the biggest weakness of dynamic languages, lack of refactor-ability. I have terribly low confidence in my ClojureScript code and this fear is constantly fed by the face-palm bugs I push to production. Its not a good place to be.

A common theme in this blog series is me trying to explain to Clojurists what its like to work in a strongly typed language, and in this case a language with controlled effects. Its hard to convey how big deal this is for your productivity and the quality of the resulting code. Many Clojurists does not have previous experience with 'proper' typed languages, and have the same knee-jerk response to type systems as many JS developers. Working with a language like Elm is different and you owe it to yourself to give it a try. The level of confidence it gives you and the productivity boost in refactoring your code is palpable. To me personally, its like taking a heavy load of my shoulders, freeing my mind to work unencumbered. I no longer feel crushed by the weight of having to keep all subtle details of what might break in my head and leave the bookkeeping to my buddy, the compiler.

Elm (like Haskell) take safety further and tracks side effecting functions in the type system. This facility takes the confidence in your code to yet another level. Its no longer possible to sneak in side-effecting code into functions without explicitly pointing it out in the type signature. Once the benefits of this dawns on you, it can be hard to consider going back to the mayhem of unsafe languages.

### Achieve success at all cost

[Evan Czaplicki](https://twitter.com/czaplic?lang=en-gb), the creator of Elm, spends a lot of time thinking about how a language like Elm can become more widely adopted than other strongly typed, purely functional languages that proceeds it. One of the most common objections to Haskell goes something like "If its so superior, surely everybody would be using it by now?". He's working hard on improving the areas Haskell has failed, such as excellent and beginner-friendly documentation, high quality libraries are easy to find and understand. He also fostered a very friendly and curious community around the language. 'Descending into Elm' is a pleasant experience and the idea to provide a gentle slope to newcomers is apparent. Most learning materials lets you get something running very quickly and then gradually introduce the underlying concepts. You will eventually be exposed to the 'M word', but its not slapped in your face first thing.

Elm is blazing a trail, language designers would do well to take a close look.

### Some code

If you want to get a sense of what a single-page app looks like in Elm have a look at [this example](https://github.com/sporto/elm-tutorial-app). Its explained in great details in this excellent [tutorial](http://www.elm-tutorial.org/).
