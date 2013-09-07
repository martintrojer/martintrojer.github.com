---
layout: post
title: "Retrofitting the Reloaded pattern into Clojure projects"
description: ""
category: clojure
tags: [clojure]
---
{% include JB/setup %}

[Stuart Sierra](https://twitter.com/stuartsierra) has done a great job with [clojure.tools.namespace](https://github.com/clojure/tools.namespace) and the [reloaded](https://github.com/stuartsierra/reloaded) leiningen template. If you haven't heard about this before please have a look at c.t.n readme and watch [this presentation](http://www.infoq.com/presentations/Clojure-Large-scale-patterns-techniques).

I've have retrofitted this pattern into two rather big clojure projects (20k and 5k lines) with several modules and here are some of my findings.

## Removing global state

The first step is to find all resources that needs to be "lifecycled". Typical examples are Jetty servers, database / message bus clients etc. It's common that these resources are in a `(defonce server (atom ...))` form. I tend to grep for `defonce` and `atom` to find these guys.

Please note that not all defonces / atoms need to be lifecycled. Some of them can be safely "dropped" when you un-/re-load the namespace. In this case you can leave them as `(def thing (atom ...))`. The rule of thumb is to lifecycle the ones that create a system wide resource, like a network port, message queue channel etc.

After you found your candidates you should replace them with `defrecords` implementing some kind of `LifeCycle` protocol. Here's a version I use;
<script src="https://gist.github.com/martintrojer/6473714.js?file=lifecycle.clj"> </script>

The records themselves hold their state (typically in an atom) which gets updated by the `start` and `stop` functions. Here's an example;
<script src="https://gist.github.com/martintrojer/6473714.js?file=jetty.clj"> </script>

Turning your global state into lifecycle records is the most intrusive part of this whole operation, expect to touch quite a few files.

## Creating the system

After you created these records you need to create (and start) your system (the collection of the lifecycled records). This will most likely be done in 2 places, in your apps "main" function and in the `user` namespace (more on REPL usage below).
<script src="https://gist.github.com/martintrojer/6473714.js?file=system.clj"> </script>

Simple huh?

### Dealing with omnipresent / implicit databases

One thing you'll find while removing these atoms is all the places in your code where a database / connection is "assumed". This leads to quite brittle code, which is also hard to test since you have to set everything up in the correct order. In some cases you set a global db connection in the db library but you can also have lots of code that uses that global atom you just removed!

When retrofitting this pattern into existing codebases, having the system passed around everywhere can be a big change. Furtunately you can cheat a little here, and still get all the REPL benefits. A compromise I've settled on is after the resource have been lifecycled in a record as described above, I put a dynamic var where the atom used to be. Then the start/stop functions does a `alter-var-root` on this var, and test fixtures can (safely) bind it. This doesn't solve the fundamental problem of implied resources, but it does let me move on and get the REPL environment I want (without terrifying my co-workers with a monumental pull request).

## Removing class files from the jar

If you have a `:main` (and `:aot`) key in your `project.clj` you might have noticed that you have quite a few .class files in your jar. This is usually not a big deal, but it causes problems for clojure.tools.namespace since it can't unload these namespaces correctly.

One method to minimize the class files in your jar is a new namespace like this;
<script src="https://gist.github.com/martintrojer/6473714.js?file=app.clj"> </script>

Note that this namespace doesn't require any other in the `ns` macro, this will minimize the number of generated class files.

## Dealing with dependant services

Now, your application probably consist of more than one service. So you'll have to apply the steps described above to all of them. Then, in order to maximize your REPL productivity you want to include and control all the services your current project interact with. This is only done in the `:dev` profile, since you wouldn't do this in the "real" entry point of your service.

To make this work you need 2 things; Add a leiningen dependency to these services (under the `:dev` profile) and soft links to their folders in the current projects [checkouts folder](https://github.com/technomancy/leiningen/blob/master/doc/TUTORIAL.md#checkout-dependencies). The reason for the dependency is that we want to pull in of the sub-projects dependencies (in the REPL) and checkouts is where we will do our edits.

This means that you are probably going to need a local [nexus](http://www.sonatype.org/nexus/go) / [archiva](http://archiva.apache.org/index.cgi) / [clojars](https://github.com/ato/clojars-web). Then have your CI system do a `lein deploy` after each successful build.

## user.clj

The final piece is to add the reloaded template's user.clj to your project. Simply copy reloaded's [user.clj](https://github.com/stuartsierra/reloaded/blob/master/src/leiningen/new/reloaded/templates/user.clj) into `dev/user.clj` and do some modifications to it. You want to require the namespace with your `create-system` function, and do a `(alter-var-root #'system (fn [_] (system/create-system)))` in the `init` function. Then add the `(lifecycle/start-system system)` in `start` (and the equivalent for stop).

That takes care of managing the lifecycle of the current service. If you are dependant on others (as described above) you should create and start/stop them here as well. In this case change the `user/system` to a map with a key / value for each of the sub-systems you have.

Finally add `:repl-options {:init (user/go)` to `project.clj` (once again under `:dev`) to launch the entire system when you "jack-in".

## Your new workflow

For maximum flexibility I tend to always "jack-into" the project at the "top" of the hierarchy. This means that I will have control over all other services from the REPL, and I can work on any of them without ever bouncing the REPL. I've found this to improve my productivity and remove alot of annoyances of slow startup times, so it's defenately worth the effort.

Good luck refactoring!
