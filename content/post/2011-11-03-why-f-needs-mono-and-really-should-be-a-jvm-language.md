---
categories:
- fsharp
date: "2011-11-03T00:00:00Z"
description: ""
tags:
- .net
- csharp
- fsharp
- jvm
- llvm
- mono
title: Why F# needs Mono (and really should be a JVM language)
---

When people think about .NET development, they think of C#. Sure there are other languages (VB, ASP.NET etc) but .NET and C# are very tightly linked (just drop an .NET assembly in [reflector](http://www.reflector.net/) for technical proof). If you're writing a new Windows application (and it's not a high performant game), chances are you are reading [WPF](http://en.wikipedia.org/wiki/Windows_Presentation_Foundation) books right now.

One of the promises of .NET when it was released was "the great language independent" runtime, making all these languages interoperate in joyful bliss. Technically this still holds, but in practice it's all about C#.

F# is still considered a new .NET language, but the fact is that it's been around since 2007. Let me tell you, it's an absolute gem of a language, and it's fully supported in Visual Studio 2010. F# is however not .NET the same way C# is. Drawing from its OCaml roots, it doesn't feel like typical Microsoft technology (it's just too darn good :) It seems more at home in the open source world -- the F# compiler is in fact open source.

In the recent Microsoft 2011 [build conference](http://www.buildwindows.com/), where Windows8, [WinRT](http://tirania.org/blog/archive/2011/Sep-15.html), future of Silverlight, new Visual Studio etc was announced. F# wasn't mentioned in the headlining presentations. How much mind-share does F# have internally at Microsoft?

The approach taken by the F# team is to educate the C# crowd, and win them over on technical excellence. It's a valid strategy, but it's going to be a very long process. Force feeding a new language and a new programming paradigm to the OO crowd is a very hard sell. What needs to happen in the .NET community for F# to gain ground is pull rather than push. A couple of high profile Microsoft apps showing off F# to the world (just see what [Rails](http://rubyonrails.org/) did for Ruby) and get the C#-ers' attention.

.NET being Microsoft technology, it's Windows only. Microsoft have [opened the runtime standard](http://en.wikipedia.org/wiki/Common_Language_Runtime), but it's a mine field of patents, and Microsoft has an army of lawyers. If you're a non-windows user your only hope is [Mono](http://www.mono-project.com/Main_Page), a open-source .NET runtime and C# compiler with a limp. In my experience, it's not ready for running production code. Some of Mono's core technologies, like it's garbage collector is not up to scratch. I can still easily get the runtime to crash using the experimental "generational gc". Some really core .NET libraries is missing, like WPF, and it doesn't support [tail call elimination](http://flyingfrogblog.blogspot.com/2009/01/mono-does-not-support-tail-calls.html).

F#'s creator [Dom Syme](http://blogs.msdn.com/b/dsyme/) is flirting heavily with Mono, and he understands the importance of getting the universities and hobbyists on board. There is no way they are going to fork out for a Windows and Visual Studio license. F# is included in the [standard Mono](http://www.mono-project.com/Release_Notes_Mono_2.10) release, but it's still missing from the MonoDevelop IDE. Tomas Petricek has made a [F# plugin for MonoDevelop](http://tomasp.net/blog/fsharp-in-monodevelop.aspx), but not yet officially included in MonoDevelop, and doesn't work for version 2.8. A big part of the potential F# community is in the open source world, so F# needs Mono. Too bad Mono isn't good enough.

F# is perceived more as a "server room" language, leaving the UI code for C#. Technically, this is false, but that is a bias that will be near impossible to break. Server rooms are the domain of *nix, thus once again F# needs Mono.

So, F# have a tough battle of survival against C# on Windows and a weak story in the open source world. F# sorely needs a good open runtime, it deserves it. Mono's main contributing company [Xamarin](http://xamarin.com/) seems to have it's focus elsewhere (iPhone apps written in C#) instead of fixing the basics. It's worth noting that there are other promising projects on the horizon however, [vmkit](http://vmkit.llvm.org/) might come along and save the day? Unfortunately it's going to be a long wait.

I've thought many times how awesome F# would be if it targeted the JVM. Scala would be completely redundant and F# would have a much bigger and more eager user base. There is a F#-shaped hole in the JVM language space, and given it's open source heritage, I am sure it would be big hit. The server-room developers are now starting to use Scala and Clojure, just imagine what they could do with active patterns and asynchronous workflows! The JVM world needs solid ML language, there have been some valiant [attempts](http://mth.github.com/yeti/), but none of them have taken off.

Mr Syme; just think how much easier this would all be if you were in the JVM camp? :-)

Ps. Here's a workshop [presentation](http://www.infoq.com/presentations/FSharp-and-Mono) by [Richard Minerich](http://richardminerich.com/) showing F# in Mono and MonoDevelop.

_Update_: After talking to some people in the F# / Mono community, my lacklustre attitude of Mono has slightly changed. The TCO problems is fixed, which I can verify. And even if we all agree that the Mono + F# tooling situation is bad, the runtime seems to in a better shape than I feared, and are indeed used in production. I stand by my absolute conviction that F#'s fate is tightly linked to Mono's, and thus deserves the full attention from the F# community.
