---
categories:
- beyond-clojure
date: "2016-04-21"
description: ""
tags:
- clojure
- haskell
title: 'Beyond Clojure: Haskell'
---

This is a post in the [Beyond Clojure](http://martintrojer.github.io/categories.html#beyond-clojure-ref) blog series, in which a Clojure developer looks at typed languages for web app development. This is by no means a complete survey of the Haskell web development landscape, rather a random collection of thoughts.

If you are interested in typed functional languages one stands taller than the rest. Its impossible not to get sucked into the Haskell vortex, but why fight it? In spite of its reputation of being extremely hard to learn and even harder to master, there are several excellent resources out there and you are guaranteed to learn a lots of very valuable lessons.

<!--more-->

Haskell is pure in the truest form, the succinctness of its core ideas and libraries are nothing but fantastic. It is the one language that has truly transcended the mundane imperative problem solving style and instead tackling problems (very neatly) at a higher level. One thing I really like about Haskell is that 'things' are called what they are, using academic terminology. Many other languages, which do have Monads etc, tend to shy away and use another names for them, which I think only adds to the prevailing confusion.

As long as you stay in the walled garden on the core libraries (which most of the Haskell literature does) you are presented with concise and beautiful world. Its an environment that inspires problem solving and looking at a problem from many angles. There is almost always a way to solve a problem in a cleaner way, and this inquisitive attitude is widespread in the community. In Haskell beginner meet-ups / chat-rooms more experienced developers tend to give hints and let you 'work out the problem on your own' rather than just give you the answer. I find it makes learning the language a very gratifying experience.

### Avoid success at all cost

One thing to understand about Haskell is that its a research language, and this fact makes it very different from many other 'industry languages'. The ironic motto of Haskell has always been 'avoid success at all cost'. One way of interpreting this statement is that by avoiding having a large user-base relying on the stability of the language features, the authors/researchers are free to explore new ideas, which they can later remove if they change their mind. Contrast that to a language like Java which is a victim of its own success and has been stuck in innovation-paralysis for decades. Its quite evident in the most popular Haskell compiler, GHC, which supports the latest Haskell standard [Haskell2010](https://www.haskell.org/onlinereport/haskell2010/) and on top of that has a plethora of [language extensions](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/ghc-language-features.html), some considered more safe than others.

It turns out that when you venture outside the walled garden of the core libraries and start using Haskell 'for real', its unavoidable to have several of these language extensions in pretty much all your modules. Most, if not all, libraries you use will also use extensions and some even require the use of them in your code. How big of a deal this is comes down to your tolerance for future change.

If you are thinking about using Haskell as you main language, and having a 5+ year view, this could be cause for concern. If you plan to start using GHC (which is the compiler 'everybody' uses) for business critical services, having a strategy for keeping up with language/compiler changes and the extra work it will impose on your teams is something to factor in. Developing a discipline amongst your developers on what extensions to use is also important.

### Lazy-ness

One of the core design principles since the beginning of Haskell is lazy evaluation. This is more than lazy sequences that you see in other functional languages. Basically every expression gets thunked and is only realized when another expressions 'pulls' for the result. Lots of the beauty of Haskell comes from this technique, but it does offer a number of practical problems. The chief one being that its very hard to work out the time/space complexity of a function. Huge ripples of expressions in other functions might get triggered in the context of the function you are currently benchmarking. There is no way around it, eager evaluation is easier to reason about, but that doesn't invalidate Haskell's approach.

Another problem is that you generally don't get stack traces on runtime exceptions. It has to be enabled at compile time and for production builds this is generally not on. And even when you get the trace, since its lazy evaluated, its not exactly as straight forward as a Java stack trace.

As always there are more or less complete workarounds, but in non trivial situations (like production downtime scenarios always are) will have you pray for Java-like profiling tools. You will inevitably go through a journey of learning the right mix of [compiler optimization flags](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/options-optimise.html), [bang patterns](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/bang-patterns.html) and other hard lessons learned before landing a on a set of best practices that works for your applications.

### Working in a typed language

Being a Clojure guy working in Haskell the difference of how you go about crafting your code is quite stark. In Clojure you save off some off the data you want to work on in var, and start writing transformations. Feedback are often Clojure runtime errors while you trying to get your expressions to match the shape of the data. In Haskell you start off thinking about the your abstractions (types) and your main feedback is type errors from the compiler pointing out where you contradict yourself. You also develop a strong sense of 'if it compiles it works', because runtime errors are rare. This does by no means eliminate the importance of tests, but tests doesn't play the same role it does in a Clojure code-base. In Haskell I don't need tests to give me confidence that my code is glued together correctly or that I didn't forget to alter a case expression because of a change in a GADT. The compiler checks all that for me and says "that change requires further changes here, here, here and here". For me this is a massive a win, huge.

The type errors are scary in the beginning, but you develop patterns how to interpret them. The complexity of the error messages also ramps when you move from following along in a Haskell book, to build real applications, with 6 level deep Monad Transformer stacks. Some libraries are worse than others, the [lens library's](https://hackage.haskell.org/package/lens) type errors are a chapter in and of itself.

You are constantly building up your toolbox on how to fix issues that crop up. Lots of learning, sometimes frustrating but also lots of fun.

### Tooling

The 'Haskell IDE' has traditionally been Emacs/Vim plus a terminal, which has really good language modes. There are lots of extra helpers and linters that give a very pleasant developer experience. There are plug-ins for the traditional IDEs but they are typically less refined. I'm happy with my Emacs, [haskell-mode](https://github.com/haskell/haskell-mode), [ghc-mod](https://hackage.haskell.org/package/ghc-mod), [hlint](https://hackage.haskell.org/package/hlint) setup which gives me a very interactive workflow. If you need a more traditional IDE setup, [IDE-Haskell](https://atom.io/packages/ide-haskell) and [Haskell For Mac](http://haskellformac.com/) looks promising.

Working with libraries and dealing with dependencies are done with [cabal](https://www.haskell.org/cabal/). Cabal has lots of issues and a tarnished reputation inside and outside Haskell circles. Haskell developers have been looking [far and wide](https://ocharles.org.uk/blog/posts/2014-02-04-how-i-develop-with-nixos.html) for solutions. Part of the problem is that, not only does the version of the library (and its dependencies) matter, but also what version of the compiler was used to produce it. Since the compiler is generating machine code, you also have the problem of cross-compiling. Compiling an executable on your Mac won't run on your Linux server.

Recently, lots of the gripes working with cabal were solved by a tool called [Stack](http://docs.haskellstack.org/en/stable/README/). I'm a very happy stack user (and I don't need Nix). Stack is a huge improvement for the Haskell tooling story.

You are mainly working with GHCi (the REPL) or GHC itself. I can't say that GHC is particularly fast, my main experience in this regard is compiling various libraries and their dependencies. Going for a 5 min tea break while GHC chugs away is not uncommon. Also, GHC needs lots of ram, gigabytes of it to compile the larger libraries. If you are growing a large code-base, I imagine compile time and RAM usage on the CI box will become real issues.

### Libraries

There are lots of Haskell libraries available, its a bit bewildering finding the good ones. If you are building web apps most bases are covered; web frameworks, database connections, templating etc are there and of good quality. However, its still far off the Java ecosystem. Haskell is kind of trapped in a chicken or egg situation when it comes to available libraries. In Java land, chances are high that you'll find a 'off the shelf' library for pretty much any service you want to interact with or task you want to perform. This is not the case in Haskell, the landscape is much narrower. If you want an easy route to use the latest AWS APIs or hook up to a Riak data-store you're out of luck. The basic building blocks are there but you have quite a bit of work ahead of you putting them together. This fact is holding back Haskell adoption, which in turn is not helping these libraries being written.

This leads me to another problem, saying that the libraries on the web-app space are of good quality is one thing, they are however not battle-tested to anywhere near the same degree as [Jetty](http://www.eclipse.org/jetty/), JDBC or [Netty](http://netty.io/) in the Java space. One thing you don't want to have to deal with as a time-constrained developer is bugs or inefficiencies deep inside your web server.

Documentation of Haskell libraries is usually quite bad. Some authors seem to think that type signatures are all the documentation you'll need, but of course that is not true. I can't say that documentation in the Clojure world is much better, but don't expect loads of beginner friendly docs on how to use the various libraries you are evaluating. I find myself resorting to googling for stack overflow answers or a "import TheLibIAmLookingAt" in-all-repos-in-github search.

The topic of libraries is my main concern with adopting Haskell as 'the language to use' in a real world scenario. Lack of battle-scars and the niggling feeling that you'll end up in a situation 6 months down the line where a crucial library you desperately need hasn't been written or is not good enough. You don't want to find yourself painted in a corner concluding that 'Oh, you can't do that in Haskell (without a herculean effort)'.

### Ops

Compiling to native executable has benefits, you avoid having to provision runtimes (and upgrading them) on your deployment machines. But you do have to deal with the cross-compilation complexities stated above however. As a whole, deployment of Haskell programs is fine, build your binary, stick it in a container or find another means to transfer it to the production VMs and run it.

Next up, logging. Logging is a bit tricky in Haskell since its lazy evaluated. It can be quite hard to make sense of the logs of a Haskell program since alot of it can seemingly 'run out of order' or 'happen at the wrong time'. There is also no standard logging framework, so in a production situation where you want to know what is going on in your code (and the libraries you are using), and send those logs back to logstash, you'll have work cut out for you. Not insurmountable but effort has to be put into it. It's a different world than using logback in Clojure without thinking about it much and being able to tweak the log levels of the the different libs you are using.

Another thing you really need in production is insight into your Haskell processes. What's happening to the heap? How busy is the garbage collector? Is service B about to fall over? While there are solutions out there, they are nowhere near as complete as whats available on JVM/.NET. While packages like [ekg](https://hackage.haskell.org/package/ekg) looks good enough, its a source for concern.

## A simple JSON service

Throughout this blog series I'll use a simple TodoMVC-ish example for both backend and front end code. For the Haskell backend I chose the following;

* [Snap](http://snapframework.com/) web framework
* [Persistent](http://www.yesodweb.com/book/persistent) database abstraction and connection pooling
* [Esqueleto](https://hackage.haskell.org/package/esqueleto-2.4.3/docs/Database-Esqueleto.html) SQL query DSL

[My code can be found here](https://github.com/martintrojer/beyond-clojure/tree/master/backends/haskell)

With my Clojure glasses on I'm quite happy with the layout of the web app I get with Snap. For a very simple app like this, I really have no complaints. The routing functionality looks deep enough to cover my needs, and its straightforward to factor out model and handler functions.

{{< highlight haskell >}}
-- Setting up the routes
appInit = makeSnaplet "app" "a player db backend" Nothing $ do
  addRoutes [ ("", ifTop $ writeText "Welcome to the Players API v0.1")
            , ("players", method GET getPlayersHandler)
            , ("players/:player", method GET getPlayerHandler <|>
                                  method POST createPlayerHandler <|>
                                  method DELETE deletePlayerHandler)
            ]
  d <- nestSnaplet "db" db $ initSqlite setupDB
  return $ App d

-- A simple handler
getPlayersHandler = do
  users <- runPersist getAllPlayers
  writeJSON users

-- A model/db function
getAllPlayers = do
  players <- select $ from $ \player -> do
    orderBy [asc (player ^. PlayerName)]
    return player
  return $ map entityVal players
{{< /highlight >}}

JSON marshaling works nicely and ties into Haskell data in a good way.

{{< highlight haskell >}}
[persistLowerCase|
Player
  name String
  level Int
  deriving Show
  deriving Generic
|]

instance ToJSON Player
instance FromJSON Player
{{< /highlight >}}

Getting migrations 'for free' from Persistent is a nice touch.

{{< highlight haskell >}}
setupDB = do
  runMigration migrateAll
  insert_ $ Player "Sally" 2
  insert_ $ Player "Lance" 1
  insert_ $ Player "Aki" 3
  insert_ $ Player "Maria" 4
{{< /highlight >}}

I am also really enjoying using pattern matching for situations with many cases

{{< highlight haskell >}}
createPlayerHandler = do
  player <- getPlayer'
  name <- getParam "player"
  level <- getPostParam "level"
  case (player, name, level) of
    (Nothing, Just n, Just l) -> do
      runPersist $ createPlayer (BS.unpack n) $ read (BS.unpack l)
      modifyResponse $ setResponseStatus 201 "Created"
    (Just _, _, _) -> modifyResponse $ setResponseStatus 400 "Player exists"
    _ -> notFound
{{< /highlight >}}

... and in MaybeT to simplify code that in Clojure would be big cond blocks.

{{< highlight haskell >}}
-- Flattening 2 nested calls that returns Maybe
getPlayer' = do
  player <- runMaybeT $ do
    param <- MaybeT $ getParam "player"
    MaybeT . runPersist . getPlayer $ BS.unpack param
  return player
  {{< /highlight >}}

Finally, Snap comes with a handy test module to testing your handlers, which kept me happy for this little experiment.
