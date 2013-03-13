---
layout: post
title: "Javascript and the future of code in browsers"
description: ""
category:
tags: [.NET, clojure, dart, javascript, jvm]
---
{% include JB/setup %}

Here's an observation; Javascript (the lingua franca for code in browsers) is transforming from a programming language to a specification for code generators, an <a href="http://en.wikipedia.org/wiki/Intermediate_language">IL</a> if you will.

Popular tools like <a href="http://jashkenas.github.com/coffee-script/">CoffeScript</a>, and more experimental ones like <a href="https://github.com/clojure/clojurescript/wiki">ClojureScript</a> and <a href="http://www.dartlang.org/">Google Dart</a> are just some examples. That's great right? Well, yes kind of. Developers gets better tools and can be more productive / write more correct programs. However, this can be seen as another form of obfuscation because the output is anything but readable. The output is certainly not small, leading to slower websites. The famous Dart "hello world" example being some 17000 lines of javascript.

Javascript is not well suited as an IL. We can do much better. What if the had a proper managed runtime in common for all browsers? Think JVM or CLR. Something actually designed to be an IL, and not a crippled language taken by surprise once again. This would mean that, with the right compiler, you could use any language you wanted for your web development. Heck, you could use any combination of languages you wanted. I really like the sound of that!

One obvious objection to this idea is that we don't want binary blobs in our HTML pages, it should be readable. But how readable is obfuscated Javascript anyway, especially if it has been code generated? The statement that IL isn't readable doesn't really hold true either, check out what you can do with reflector or java decompilers. That stuff is pretty readable if you ask me;
<p align="center"><img src="/assets/images/js/Reflection.Emit-Language.png"></p>

So how would the HTML with this code look like? Well, the obvious way is to put the link in there;
<script src="https://gist.github.com/1698056.js?file=link.html"> </script>
Or we could use the byte codes directly;
<script src="https://gist.github.com/1698056.js?file=bytecode-src.html"> </script>
Another example is to put the blob in there;
<script src="https://gist.github.com/1698056.js?file=bytecode.html"> </script>
With good APIs, we could merge stuff like <a href="http://en.wikipedia.org/wiki/WebGL">WebGL</a> into this thing.

And given that it's a proper IL, we could make the runtime run really fast, using JIT compilation etc. This would eliminate the need for "inventions" like <a href="http://code.google.com/chrome/nativeclient/">Google NaCl</a>, which is a bad fit for the web if you ask me. Also, any Java or Silverlight plugins are not needed anymore.

I can't shake the feeling that Google missed a great opportunity when they announced Dart. They were thinking to small. Dart should have been an proper IL instead of a new language and a new language specific runtime.