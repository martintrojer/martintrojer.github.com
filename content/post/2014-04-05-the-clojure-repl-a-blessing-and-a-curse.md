---
categories:
- clojure
date: "2014-04-05T00:00:00Z"
description: ""
tags:
- clojure
title: The Clojure REPL; a blessing and a curse
---

All Clojure developers swear by their REPL; it's one of the most powerful tools in our arsenal. Coming from traditional edit/compile/launch languages, it is also a great productivity boost. The Clojure community takes non-AOT (ahead of time compilation) to the extreme. By default, we ship Clojure source code in our development and production jars and thus leave compilation to the very last minute (when the program launches). This gives us lots of power and flexibility; if you've ever navigated into a library in Emacs and fixed a bug, re-evaled the form and carried on working, you know what I'm talking about.

<!--more-->

{{< figure src="/assets/images/repl/compiling.png" >}}

However, there is a flip side to this approach; increased time to launch a fresh REPL session (or production jar for that matter). Clojure launch time has been debated for a long time (see references below) and I'd like to break it down into two distinct categories; launch time for production programs (on servers and android phones) and launch time of the REPL in a development setting. In this post I want to focus on the latter, because I believe that Clojure have now reached the point where REPL launch time is impeding developer productivity.

On a AWS [m1.small](http://aws.amazon.com/ec2/instance-types/) box, launching the REPL in a basic Clojure/Ring/Compojure (and friends) project now is approaching a minute. If we compare Clojure to 'competing' stacks such as Rails, Node.js and Go, Clojure is multiple orders of magnitude slower in this respect. The gut reaction is to blame the JVM, but in fact that is not correct, Clojure is the major factor when it comes to boot time. For more details see Nicholas Kariniemi's [blog posts](http://nicholaskariniemi.github.io).

I find it particularly interesting how a technical detail like startup time dictates our workflow. The major reason Stuart Sierra's (excellent) [clojure.tools.namespace](https://github.com/clojure/tools.namespace), [re-loaded](https://github.com/stuartsierra/reloaded) and [component](https://github.com/stuartsierra/reloaded) libraries has been universally adopted is due to the simple fact that Clojure developers simply can't stand bouncing the REPL all the time. c.t.n comes with some pretty restrictive design principles but gives you a 'refresh' command that quite quickly loads all your changes and gives you a 'fresh' REPL. Anyone who adopted this approach can't even think back to the days before we had `(reset)` in the user namespace. c.t.n is not perfect, there are still plenty of scenarios when bouncing the REPL is your only option, switching branches and calling reset usually does terrible things. The reloaded workflow is also an extra mental tax imposed on all Clojure developers. If the REPL booted in seconds, we could write simpler code and have the OS do all resource cleanup for us.

If you ever worked along side Rails, Node or Go developers one thing that will surprise you (coming from Clojure) is how different their workflow is. I would also argue that their workflow is a lot simpler (less convoluted if you will). A language like Go, in trying to lure C++ developers over has a very sharp focus on developer productivity, and an absolute key metric is the edit / compile / run round-trip. Since they generally drop their process every time in this round-trip, no holding-on-to-resources restrictions apply. As stated above, resource cleanup is best left to the OS. You can rightly argue that once the Clojure REPL is up, the instant-feedback time in Clojure is unmatched, but when you have to bounce the REPL you get very frustrated. Hence we guard our REPLs like Gollum guards his ring. One a side note, if you ever worked with Clojurescript and Node.js, the first thing that will floor you is how insanely fast your clojurescript program starts up.

Here's a scenario that you might recognize. You've done a pretty substantial refactor, including new dependencies in `project.clj`. You need to bounce the REPL. Knowing that this will take forever, you immediately switch to [Prismatic](http://getprismatic.com). 15 minutes later, you look at your Emacs again where you notice that there's a syntax error, so the REPL didn't launch. You parse the impossibly long stack trace and fix the bug. `cider-jack-in` again and switch back to HipChat. 10 minutes pass, you look again, still doesn't compile. Rinse and repeat. 1 hour has now passed and you finally got your REPL back, but you've completely forgotten what you were doing, so you decide to go out for a coffee.

### Solutions

For the issue of launch time for production programs a number of solutions have been proposed; tree shaking, static compilation of vars etc. They all look promising but doesn't completely solve the problem for slow REPLs. I think a mixture of improved namespace bootstrapping, selective AOT and faster reading/analyzing/emitting is the way to go. This could be one possible outcome of the Clojure-in-Clojure projects currently being worked on. Parallel, lazy loading of immutable namespaces can perhaps lead some simplifications and speed improvements.

### References

* Clojure in Clojure
     - [clojure.tools.reader](https://github.com/clojure/tools.reader)
     - [clojure.tools.analyzer](https://github.com/clojure/tools.analyzer)
     - [clojure.tools.analyzer.jvm](https://github.com/clojure/tools.analyzer.jvm)
     - [clojure.tools.emitter.jvm](https://github.com/clojure/tools.emitter.jvm)
* [Stuart Sierra - Components Just Enough Structure](https://www.youtube.com/watch?v=13cmHf_kt-Q)
* [Rich Hickey Clojure/Conj 2011 keynote](https://www.youtube.com/watch?v=I5iNUtrYQSM)
* [Clojure and Android - Daniel Solano Gomez](https://www.youtube.com/watch?v=1NptqU3bqZE)
* [Daniel Solano Gomez - How Clojure Works: Understanding the Clojure Runtime](https://www.youtube.com/watch?v=8NUI07y1SlQ)
* [Some thought on Clojure Performance]({{< ref "2012-02-18-some-thoughts-on-clojure-performance.md" >}})
* [The (Clojure) "JVM Slow Startup Time" Myth](http://nicholaskariniemi.github.io/2014/02/11/jvm-slow-startup.html)
* [Why is Clojure bootstrapping so slow?](http://nicholaskariniemi.github.io/2014/02/25/clojure-bootstrapping.html)
* [Solving Clojure Boot Time](http://nicholaskariniemi.github.io/2014/03/19/solving-clojure-boot-time.html)
* [Var-les clojure](https://twitter.com/cgrand/status/441915165718900737)
* [@mikera kiss project](https://github.com/mikera/kiss)
