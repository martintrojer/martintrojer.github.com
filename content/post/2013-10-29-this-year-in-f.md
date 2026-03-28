---
categories:
- fsharp
date: "2013-10-29T00:00:00Z"
description: ""
tags:
- .net
- jvm
- csharp
- fsharp
- mono
- ocaml
title: This year in F#
---

For the third year running, here's my annual (and extremely subjective) review of the state of the F# language, its community and other loosely connected things. How would I sum up the noises coming from F# the last year? Pretty darn awesome. A lot of what's been happening was on my wish-list outlined in [last year's post]({{< ref "2012-10-24-the-future-of-net-lies-in-mono-the-future-of-f-lies-in-monodevelop.md" >}}). What are the highlights?

<!--more-->

Let's start with the [F# foundation](http://fsharp.org/). This is a fantastic move in the right direction, and as the [mission statement](http://fsharp.org/foundation.html) hints at, all about making F# a viable technology no matter what Microsoft does next. If you haven't looked at the site yet please do, it's an impressive collection of docs (like getting started guides), real world testimonials and more.

One thing I want to point out is the [F# organization on github](https://github.com/fsharp/). This is already an impressive collection of projects, and most importantly it hosts the open source edition of the F# compiler and core libraries. This is a nice improvement over the once-every-3-year code drop approach that F# have adopted so far. I'm still waiting for the official announcement that this github repo is now the official (and only) version of F#, something tells me it's just around the corner.

The next huge thing is meteoric rise of [Xamarin](http://xamarin.com/), the custodians of the [Mono project](http://www.mono-project.com/Main_Page) -- which I predicted is the future of .NET (and thus F#). Xamarin focuses on tooling and libraries for mobile devices, and their success it's a very good thing for Mono in general. I would personally like to see a bit more focus on Mono for server / back-end usage but I understand Xamarin have to go where the money is. My small F# toys are constantly getting faster with Mono, but they are still a factor 2-4 off the Windows benchmark. I do think Mono will eventually catch up, and more importantly I think it's going to take the lead on ARM platforms -- which is going to be important for servers in the future. [ARMv8 is the dogs b**s.](https://twitter.com/migueldeicaza/statuses/382307711213260801)

Mr de Icaza seems to warming to F#, and recently spoke at a F# event at a [skillsmatter event in New York](http://skillsmatter.com/podcast/scala/keynote-4066). Xamarin is also hiring people with F# background, this is a slam dunk for F# is you ask me.

> Loved meeting the F# lovers and trainees at [@skillsmatter](https://twitter.com/skillsmatter) training in NYC. See you online peeps! -- Miguel de Icaza ([@migueldeicaza](https://twitter.com/migueldeicaza/statuses/380835425176539136)) September 19, 2013

The shift in focus to open source (and in effect Mono) is perhaps best expressed in Don Syme's [F# in the Open Source World talk](http://skillsmatter.com/podcast/scala/keynote-4011). I've attended this talk in March this year, and I really enjoyed it. If you haven't seen it, please do -- it's awesome. And yes, there is a live demo of F# in Emacs with 'intellisense' / auto-complete.

Talking about open source, [Nuget](http://www.nuget.org/) continues to grow in strength. It's still orders of magnitude off maven central / sontatype but there certainly is some very good stuff available. Which is interesting indeed for a Microsoft community, where open source software has always been frowned upon. It's really good news for F#, since C# interrop is excellent. One cool project I want to pick out is [Funscript](http://funscript.info/), a really clever F# quotation to JavaScript compiler. [Zach](http://zbray.com/) and [Tomas](http://tomasp.net/) are doing a great good job here, you should check out the demos.

The introduction of Type Providers in F# 3 has spurred a lot of excitement. This [list of available providers](http://sergeytihon.wordpress.com/2013/08/05/f-type-providers-news-from-the-battlefields/) are impressive and growing. They really are a nice bridge to the convenience of a dynamically typed languages from the comforts of your Hindley-Milner type system.

So what about good old Microsoft? Well, any comments on the Windows8-SurfaceRT-Ballmer-XBONE-Nokia-Elop-year-of-fail is kind of [redundant at this stage](http://www.youtube.com/watch?v=xqmj-9XlDzY). Windows (and .NET) continues to be strong in the client space. I witnessed this firsthand many times this year, big companies use Linux / JVM / Oracle for back-end stuff and Windows for clients. If a thick client is needed then you go XAML, if not, you let the Java guys do a web UI. F# would do very well in the server space, but for that to really take off it needs a rock-solid runtime for Linux. Mono is the key to get F# back on the [tech radar](http://www.thoughtworks.com/radar).

So Xamarin is making C# / .NET work really well in the mobile space, and then there is [Unity](http://unity3d.com/) and [MonoGame](http://monogame.net/). It's good news all round for client software and .NET. F# have an important role to play here, and some bloggers/communities has caught on to the gaming trend, like [Dave](http://7sharpnine.com/), [Neil](http://neildanson.wordpress.com/) and the [London Gramecraft](http://skillsmatter.com/event/java-jee/london-gamecraft). It'll be interesting to see where this goes.

I'll close off with my old reminder to all F#-ers out there; Microsoft is a fickle mistress, who will randomly drop a technology on a whim. This year F# has taken many important steps to break free from Microsoft and take control of its own fate. This work must continue.

P.S. Here's some other F# related things I will spend time with over the coming year;

* [F# Deep Dives](http://www.manning.com/petricek2/) by Perticek, Trelford et al.
* [F# for fun and profit](http://fsharpforfunandprofit.com/)
* [Tsunami IDE](http://tsunami.io/)
* [Real world OCaml](https://realworldocaml.org/) by Hickey, Madhavapeddy, Minsky
