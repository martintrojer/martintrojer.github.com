---
categories:
- fsharp
date: "2012-10-24T00:00:00Z"
description: ""
tags:
- .net
- mono
- f#
title: The future of .NET lies in Mono. The future of F# lies in MonoDevelop.
---
{% include JB/setup %}

It's been a year since [I last wrote about F# and Mono](/fsharp/2011/11/03/why-f-needs-mono-and-really-should-be-a-jvm-language) - what's happened since then?

F# 3.0 has recently been released, bundled in with the new <a href="http://www.theregister.co.uk/2012/08/28/visual_studio_2012_review/">all-grey</a>, <a href="http://blogs.msdn.com/b/visualstudio/archive/2012/06/05/a-design-with-all-caps.aspx">ALL-CAPS</a> Visual Studio 2012. The biggest new feature is <a href="http://msdn.microsoft.com/en-us/library/hh156509.aspx">type providers</a>, bringing some of the benefits of dynamic languages into type safe world. Innovations like type providers deserve more industry attention. I really hope these ideas will spread and hopefully languages like Scala will pick them up pretty soon so more developers (including me) can enjoy the benefits.

OK, that's cool, but how is good old F# doing? Well, about the same. It lumbers on in obscurity under the massive shadow of Microsoft and whatever crazy idea the company is currently peddling (<a href="http://arstechnica.com/gaming/2012/07/steams-newell-windows-8-catastrophe-driving-valve-to-embrace-linux/">Win8 metro UI</a>, <a href="http://www.businessinsider.com/microsoft-has-big-problem-with-windows-8-2012-10">touch-screen laptops</a>, <a href="http://tirania.org/blog/archive/2011/Sep-15.html">WinRT</a>, <a href="http://news.yahoo.com/microsoft-surface-pricing-flat-crazy-165658134.html">$100 surface cover</a>s, <a href="http://www.neowin.net/news/former-microsoft-pm-silverlight-is-dead">pretending Silverlight never happened</a>, etc...) F# is still awesome and deserves a lot more attention and adoption.

Take a look at&nbsp;<a href="http://www.thoughtworks.com/articles/technology-radar-october-2012">ThoughWorks latest Tech Radar</a>. F# distant relatives (as in fairly new "<a href="http://skillsmatter.com/podcast/home/practical-fsharp/js-4400">functional-first</a>"  languages) Scala and Clojure are steaming ahead and have both reached "Adopt" status. F# is stuck in "assess" never-land. I don't see many signs of that changing anytime soon.

F# has limited credibility because of Microsoft. Even though <a href="https://github.com/fsharp">F# is actually open source</a>, it has a very small open source community. The development is completely driven from Microsoft, and there is very little "open source buzz" about it, typical for any Microsoft products. F# moves with the same slow cadence as Visual Studio, which is software terms are eons between releases. Any big and open F# frameworks are sorely lacking. Microsoft's completely r\*\*\*\*\*\*d (there, I said it) messaging regarding F# and .NET is also to blame.

On messaging; firstly, there is the total confusion about .NET. Where is that going? Windows8 is all about HTML5. <a href="http://channel9.msdn.com/posts/Anders-Hejlsberg-Introducing-TypeScript">Anders is doing Typescript now</a>, silverlight is dead. There's a lot of frustrated .NET developer out there. I've predicted that Mono is future home and legacy for .NET, and it looks more likely every day. As a die-hard MSDN developer you might frown upon this fact, but really it's not a bad thing. Open-source and Mono has a lot to offer, for instance OS independence. This is absolutely critical to continue to drive adoption.

Secondly, F# has always been the odd one out in the .NET space (compared to headline technologies such as C#, VB, ASP). If Microsofts messaging on the future of .NET is confusing, their messaging on what F# is and supposed to be used for is crazy; "Use C# for everything, and if you're an academic do some data analysis check out F#". Screw that, F# is superior to C# in every single way, for any application. Microsoft should promote the hell out of it and stop pussyfooting about. However, I have very little faith that this will ever improve, and F# is (and always has been) dancing close to the edge of oblivion.

There is a big F# shaped hole in the language space currently, on the JVM and elsewhere. Like I stated a year ago, if F# did run on the JVM the story would be completely different, it would have massive adoption. It is a perfect candidate for "the static typed language of choice" in your language toolbox. Today people are seriously looking into Haskell when they get fed up with their gnarly python/ruby projects. Sadly F# is getting overlooked.

So what about Mono and open source then? <a href="https://twitter.com/dsyme/status/259986508071702528">Don Syme spoke</a> at the recent <a href="http://monkeyspace.org/">MonkeySpace conference</a>, and <a href="http://news.ycombinator.com/item?id=4685053">generated a lot of buzz</a>. .NET has never been sexy technology in the hands of Microsoft, but the Xamarin guys are turning Mono into just that. <a href="http://xamarin.com/monotouch">MonoTouch</a>, <a href="http://monogame.codeplex.com/">MonoGame</a>, <a href="http://unity3d.com/">Unity</a> are some really good products. Mr Don Syme, this is where you and your language belong, this is how you take F# to the next level. Forget about all the in-fighting and bickering at Microsoft and focus on what's good for F#. That is to embrace Mono fully, it's your number one platform.

The culture shift for developers who's been living inside the Microsoft/MSDN bubble moving to Mono is drastic. Mono is an all-out open source community with all it's up and downsides. Say goodbye to stable, supported releases every 3/4 years and hello to nightly builds and pull requests. That certainly won't fit all current .NET developers, like lemmings they'll just move along to whatever Microsoft is feeding them next. Could that be the <a href="http://channel9.msdn.com/Shows/C9-GoingNative">native renaissance&nbsp;<link></link>perhaps</a>? :) Real .NET enthusiast should free themselves from the Microsoft shackles and embrace Mono, they'd be much better for it. Join the community, contribute improvements to the garbage collector. Go to awesome conferences in Boston, have fun!

To summarise, how do we save this gem of a language? F# must break out of the Microsoft prison. Ideally I'd like to see a couple of key members of the team to actually leave Microsoft, get some funding and set up a independent F# foundation (or maybe join Xamarin). This foundation could pursue important issues like sponsoring key libraries like web frameworks, making sure the F# MonoDevelop integration is top notch etc. So while Microsoft is committing corporate suicide with Windows8, the .NET and F# community needs to move on.

The future of .NET lies in Mono. The future of F# lies in MonoDevelop.