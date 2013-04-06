---
layout: post
title: "Clojure Hacking on the Samsung ARM Chromebook"
description: ""
category: clojure
tags: [clojure, chrome, arm, rpi]
---
{% include JB/setup %}

<p align="center"><img src="/assets/images/chromebook/cb.jpg"></p>

I recently switched to the [Samsung ARM Chromebook](http://www.samsung.com/uk/consumer/pc-peripherals/chrome-devices/chrome-devices/XE303C12-A01UK) for all my laptop needs. The pitch it's quite appealing, 200 quid, dual core ARM CortexA15s, good keyboard, totally fan-less (CPU is passively cooled), good battery life, 1kg weight. The one downside is it's quite limited RAM size, just 2GB. But with a decent swap file, I'm running multiple JVMs (with Datomic, Elasicsearch, [CLJS](https://github.com/clojure/clojurescript) compiler etc without any hickups).

Out of the box it runs [ChromeOS](http://en.wikipedia.org/wiki/Google_Chrome_OS), which I have to say is pretty stellar for browsing and consuming content on the web. It is also possible to run any Linux you wish on this machine, google has an [outspoken strategy](http://www.chromium.org/chromium-os/chromiumos-design-docs/developer-mode) to enable it.

I use a dual-boot setup where I have the ChromeOS system on the internal SSD and Chrubuntu (currently 12.04) on an SDCard. So if you buy one of these chromebooks, also get a decent SDCard (I have a [32Gb Sandisk Extreme](http://www.sandisk.co.uk/products/memory-cards/sd/)). [Setting up Chrubuntu](http://chromeos-cr48.blogspot.co.uk/2012/12/so-you-want-chrubuntu-on-external-drive.html) is a breeze, and after the base system is installed you need to spend some time installing the other essential development tools. It's not as easy as [homebrew](http://mxcl.github.io/homebrew/) on OSX, but if you have any Linux experience (or want to gain some) it's straight forward.

Now, since we are running on an ARM processor, any prebuilt x86 binaries won't run. The Chrubuntu distro is pretty complete, but you probably have to build some stuff yourself. One thing to keep in mind when working with Linux on ARM hardware is pay extra attention to "hard-float" vs "soft-float" binaries. On the Samsung ARM Chromebook you will be running `armhf` which is the hard-float option. Unfortunately soft-float [ELFs](http://en.wikipedia.org/wiki/Executable_and_Linkable_Format) is not binary compatible with armhf, thus you might experience crashes if you don't pass the correct flags to `./configure`.

Fortunately it's not a big problem. Emacs builds nicely and you can snap up a JVM for armhf [here](http://jdk8.java.net/fxarmpreview/). On my system I also work quite a bit with [node.js](http://nodejs.org/), when building it you must enable HARDFLOAT and disable the snapshot feature in v8 (otherwise v8's ARM JIT will not behave correctly).

Once you have Emacs and Java8/armhf, just can install and run [leiningen](https://github.com/technomancy/leiningen) as normal, jack-in in Emacs and hack away! You will quickly forget you're on ARM hardware, it's just normal Ubuntu. Well, you might notice that there aren't any CPU fans, and you won't get 2nd degree burns on your legs :-)

As you can see in the picture above, I'm an also working a bit on my [Raspberry Pi](http://www.raspberrypi.org/). This work is greatly helped by having developer spec-ed ARM hardware to work on. All binaries have be copied verbatim to/from the PI -- no more ARM Emulators on x86 hardware!

I recommend the Samsung ARM Chromebook for Clojure development!
