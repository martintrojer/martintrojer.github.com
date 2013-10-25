---
layout: post
title: "This year in F#"
description: ""
category: fsharp
tags: [.net, jvm, c#, f#, mono]
---
{% include JB/setup %}

For the third year running, here's my annual (and extremely subjective) review of the state of F# the language, community and other loosly connected things. This last year I've been even further removed from F# than the last times, so my vintage view is from quite far away.

How would I sum up the noises coming out of the F# work for the last year? Pretty damn awesome. Alot of what's been happening is prettly close to my 'dream scenario' outlined in [last year's post](http://martintrojer.github.io/fsharp/2012/10/24/the-future-of-net-lies-in-mono-the-future-of-f-lies-in-monodevelop/). What are the highlights? Let's start with the [F# foundation](http://fsharp.org/). This is fantastic move in the right direciton, and as the [mission statement](http://fsharp.org/foundation.html) points out, making F# a viable technology nomatter whatever Microsoft does next. If you haven't looked at the site yet please do, its an impressive collection of docs (like getting started guides), real world testimonials and more.

One thing I want to point out is the [F# organization on github](https://github.com/fsharp/). This is already an impressive collection of projects, and most importantly it hosts the open source edition of the F# compiler and core libraries. This is a nice improvement over the once-every-3-year code drop approach that F# has adopted so far. I'm still watiting for the official announcement that this github repo is now the official (and only) version of F# -- I sincerely that is just around the corner.

The next huge thing is meteoric rise of [Xamarin](http://xamarin.com/), the custodians of Mono -- which I predicted is the future of .NET (and thus F#). Xamarin focuses on mobile devices, but their success it's a very good thing for Mono in general. I would personally like to see a bit more focus on Mono for server / back-end usage but I understand Xamarin have to go where the money is. My trivial small experiments are constantly getting faster with Mono, but they are still a factor 2-4 off the Windows benchmark. I do think Mono will eventually catch up, and more importantly I think it's going to take the lead on ARM platforms -- which is going to be important in the future, even for servers.

<blockquote align="center" class="twitter-tweet"><p>My team on ARM64: &quot;basically everything anybody would want. lots of registers, hw div/mult, single abi, hard-fp, reliable stack walk, etc.&quot;</p>&mdash; Miguel de Icaza (@migueldeicaza) <a href="https://twitter.com/migueldeicaza/statuses/382307711213260801">September 24, 2013</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"> </script>

This shift in focus to open source (and in effect Mono) is perhaps best expressed in Don Syme's [F# in the Open Source wold talk](http://skillsmatter.com/podcast/scala/keynote-4011). I've attended this talk in March this year, and I really enjoyed it. If you haven't seen it, please do -- it's awesome. And yes, there is a live demo of F# in Emacs with 'intellisense' or auto-complete.

Cool blog series (Neil and Dave)

Funcscript

Nuget

Phil and Tomas' book

Websharper

Tech radar

F# skillsmatter stuff
- Miguel talking

Microsoft, the future of .NET, Windows8 debacle, Balmer / Elop

Breaking out of the M$ prison

Phil's blog post (polyglot)

-----------------------------------------

Don Syme talks

FSharp foundation
-- F# compiler github repo

Xamarin / mono
