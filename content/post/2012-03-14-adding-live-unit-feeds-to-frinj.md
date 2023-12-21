---
categories:
- clojure
date: "2012-03-14T00:00:00Z"
description: ""
tags:
- clojure
- frinj
title: Adding Live Unit Feeds to Frinj
---

A couple of weeks has passed since I've pushed [Frinj to github](https://github.com/martintrojer/frinj) and blogged/tweeted about it. The response have been pretty awesome, one highlight being when [@stuarthalloway](https://twitter.com/#!/stuarthalloway) showed me a [frinj+datomic example gist](https://gist.github.com/1980351) on the #datomic IRC channel. In short, the Clojure community is #badass.

Frinj comes with a big database of units and conversion factors, and while as many conversion factors are "eternal", others aren't. Exchange rates for instance has to be kept up to date to be relevant. The Frinj unit database was designed to be updatable, both for usability when doing various calculations, but also for rates that constantly change. This is the reason the frinj.calc namespace exposes the (frinj-init!) function to reset the unit database to a know baseline (in case you write over some factors etc). Clojure's support for atomically updating state is ideal for this purpose, the calculator's state is [kept in a number of refs](https://github.com/martintrojer/frinj/blob/master/src/frinj/core.clj#L17) and thanks to the STM always kept consistent.

Frinj now supports live currency exchange rates, precious/industrial metals and agrarian commodities, by adding the concept of unit feeds. This is handled by the new frinj.feeds namespace, and the basic idea is to have multiple feeds sharing one ScheduledThreadPoolExecutor for periodically updating Frinj's state. The generic feed utility functions; (start-feed, stop-feed, update-units!) are separated from the feed specific ones. For more information see the [wiki](https://github.com/martintrojer/frinj/wiki/Live-Unit-Feeds) and [source](https://github.com/martintrojer/frinj/blob/master/src/frinj/feeds.clj#L19). As you can imagine, these live units rates are just a couple of many potential feeds.

Currencies use the 3 letter (ISO 4217) currency acronym (uppercase), and the metals and commodities use capitalised names, see below for examples.

I've also added an new convenience namespace called frinj.repl that will initialise the built-in units, start the feeds and immigrate the rest of the frinj vars.

```clojure
user=> (use 'frinj.repl)
user=> (str (fj 10 :thousand :SEK :to :GBP))   ;; standard currency conversion
"937.1075201531269 [dimensionless]"
user=> (str (fj :Gold :per :Silver))           ;; Gold vs Silver price
"49.95612708018155 [dimensionless]"
user=> (str (fj :Milk))
"0.3659673552268969 dollar kg^-1 [price_per_mass]"
```

Next time, I'll explain how to use Frinj in ClojureScript.
