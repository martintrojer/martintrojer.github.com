---
layout: post
title: "Why F# needs Mono (and really should be a JVM language)"
description: ""
category:
tags: [.NET, C#, F#, jvm, llvm, mono]
---
{% include JB/setup %}

When people think about .NET development, they think of C#. Sure there are other languages (VB, ASP.NET etc) but .NET and C# are very tightly linked (just drop an .NET assembly in <a href="http://www.reflector.net/">reflector</a> for technical proof). If you're writing a new Windows application (and it's not a high performant game), chances are you are reading <a href="http://en.wikipedia.org/wiki/Windows_Presentation_Foundation">WPF</a> books right now.

One of the promises of .NET when it was released was "the great language independent" runtime, making all these languages interoperate in joyful blizz. Technically this still holds, but in practice it's all about C#.

F# is still considered a new .NET language, but the fact is that it's been around since 2007. Let me tell you, it's an absolute gem of a language, and it's a fully supported in Visual Studio 2010. F# is however not .NET the same way C# is. Drawing from it's <a href="http://caml.inria.fr/">OCaml </a>roots, it doesn't feels like typical Microsoft technology (it's just too darn good :) It seems more at home in the open source world -- the F# compiler is in fact <a href="http://blogs.msdn.com/b/dsyme/archive/2010/11/04/announcing-the-f-compiler-library-source-code-drop.aspx">open source</a>.

In the recent Microsoft 2011 <a href="http://www.buildwindows.com/">build conference</a>, where Windows8,&nbsp;<a href="http://tirania.org/blog/archive/2011/Sep-15.html">WinRT</a>, future of Silverlight, new Visual Studio etc was announced. F# wasn't mentioned in the headlining presentations. How much mind-share does F# have internally at Microsoft?

The approach taken by the F# team is to educate the C# crowd, and win them over on technical excellence. It's a valid strategy, but it's going to be a very long process. Force feeding a new language and a new programming paradigm to the OO crowd is a very hard sell. What needs to happen in the .NET community for F# to gain ground is pull rather than push. A couple of high profile Microsoft apps showing off F# to the world \(just see what <a href="http://rubyonrails.org/">Rails</a> did for Ruby\) and get the C#-ers' attention.

.NET being Microsoft technology, it's Windows only. Microsoft have <a href="http://en.wikipedia.org/wiki/Common_Language_Runtime">opened the runtime standard</a>, but it's a mine field of patents, and Microsoft has an army of lawyers. If you're a non-windows user your only hope is <a href="http://www.mono-project.com/Main_Page">Mono</a>, a open-source .NET runtime and C# compiler with a limp. In my experience, it's not ready for running production code. Some of Mono's core technologies, like it's garbage collector is not up to scratch. I can still easily get the runtime to crash using the experimental "generational gc". Some really core .NET libraries is missing, like WPF, and it doesn't support <a href="http://flyingfrogblog.blogspot.com/2009/01/mono-does-not-support-tail-calls.html">tail call elimination</a>.

F#'s creator <a href="http://blogs.msdn.com/b/dsyme/">Dom Syme</a> is flirting heavily with Mono, and he understands the importance of getting the universities and hobbyists on board. There is no way they are going to fork out for a Windows and Visual Studio license. F# is included in the <a href="http://www.mono-project.com/Release_Notes_Mono_2.10">standard Mono</a> release, but it's still missing from the MonoDevelop IDE. Tomas Petricek has made a <a href="http://tomasp.net/blog/fsharp-in-monodevelop.aspx">F# plugin for MonoDevelop</a>, but not yet officially included in MonoDevelop, and doesn't work for version 2.8. A big part of the potential F# community is in the open source world, so F# needs Mono. Too bad Mono isn't good enough.

F# is perceived more of a "server room" language, leaving the UI code for C#.&nbsp;Technically, this is false, but that is a bias that will be near impossible to break. Server rooms are the domain of \*UX, thus once again F# needs Mono.

So, F# have a tough battle of survival against C# on Windows and a weak story in the open source world.&nbsp;F# sorely needs a good open runtime, it deserves it. Mono's main contributing company <a href="http://xamarin.com/">Xamarin</a> seems to have it's focus elsewhere (iPhone apps written in C#) instead of fixing the basics. It's worth noting that there are other promising projects on the horizon however, <a href="http://vmkit.llvm.org/">vmkit</a>&nbsp;might come along and save the day? Unfortunately it's going to be a long wait.

I've thought many times how awesome F# would be if it targeted the JVM. Scala would be completely redundant and F# would have a much bigger and more eager user base. There is a F#-shaped hole in the JVM language space, and given it's open source heritage, I am sure it would be big hit. The server-room developers are now starting to use Scala and Clojure, just imagine what they could do with active patterns and asynchronous workflows! The JVM world needs solid ML language, there have been some valiant <a href="http://mth.github.com/yeti/">attempts</a>, but none of them have taken off.

Mr Syme; just think how much easier this would all be if you were in the JVM camp? :-)

Ps. Here's a workshop <a href="http://www.infoq.com/presentations/FSharp-and-Mono">presentation</a> by <a href="http://richardminerich.com/">Richard Minerich</a> showing F# in Mono and MonoDevelop.

_Update_: After talking to some people in the F# / Mono community, my lacklustre attitude of Mono has slightly changed. The TCO problems is fixed, which I can verify. And even if we all agree that the Mono + F# tooling situation is bad, the runtime seems to in a better shape than I feared, and are indeed used in production. I stand by my absolute conviction that F#'s fate is tightly linked to Mono's, and thus deserves the full attention from the F# community.