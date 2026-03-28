---
categories:
- clojure
date: "2013-04-06T00:00:00Z"
description: ""
tags:
- clojure
- chrome
- arm
- rpi
title: Clojure Hacking on the Samsung ARM Chromebook
---

{{< figure src="/assets/images/chromebook/cb.jpg" >}}

I recently switched to the [Samsung ARM Chromebook](http://www.samsung.com/uk/consumer/pc-peripherals/chrome-devices/chrome-devices/XE303C12-A01UK) for all my laptop needs. The pitch is quite appealing: £200, dual-core ARM Cortex-A15s, good keyboard, totally fanless (CPU is passively cooled), good battery life, and 1kg weight. The one downside is its quite limited RAM size, just 2GB. But with a decent swap file, I'm running multiple JVMs (with Datomic, Elasticsearch, [CLJS](https://github.com/clojure/clojurescript) compiler, etc.) without any hiccups.

Out of the box, it runs [ChromeOS](http://en.wikipedia.org/wiki/Google_Chrome_OS), which I have to say is pretty stellar for browsing and consuming content on the web. It is also possible to run any Linux distribution you wish on this machine; Google has an [outspoken strategy](http://www.chromium.org/chromium-os/chromiumos-design-docs/developer-mode) to enable it.

I use a dual-boot setup where I have the ChromeOS system on the internal SSD and Chrubuntu (currently 12.04) on an SD card. So if you buy one of these Chromebooks, also get a decent SD card (I have a [32GB SanDisk Extreme](http://www.sandisk.co.uk/products/memory-cards/sd/)). [Setting up Chrubuntu](http://chromeos-cr48.blogspot.co.uk/2012/12/so-you-want-chrubuntu-on-external-drive.html) is a breeze, and after the base system is installed, you need to spend some time installing the other essential development tools. It's not as easy as [Homebrew](http://mxcl.github.io/homebrew/) on OS X, but if you have any Linux experience (or want to gain some), it's straightforward.

**Edit:** As pointed out in the comments section below, I decided to give [Crouton](https://github.com/dnschneid/crouton) a try. These are some clever scripts around [debootstrap](http://wiki.debian.org/Debootstrap) that give you a full Ubuntu installation inside Chrome OS. You can then launch it from the Crosh (developer) shell and drop into a (for instance) 13.04 Xfce environment and install whatever you want. This is very convenient since you can easily switch back to Chrome OS (which runs in parallel) for Flash websites, etc. It also solves some of the annoyances you'll face when booting straight into Chrubuntu (like hardware-accelerated graphics and the resume-on-sleep issue). The price you pay is slightly less memory available for your Ubuntu system since you share all resources with Chrome OS, and Chrome is still running 'on the other side'. If you install your Crouton environment on the SSD, be very careful at the "scary boot screen" - you might end up wiping your entire environment and losing all your files.

Now, since we are running on an ARM processor, any prebuilt x86 binaries won't run. The Chrubuntu distribution is pretty complete, but you probably have to build some stuff yourself. One thing to keep in mind when working with Linux on ARM hardware is to pay extra attention to "hard-float" vs. "soft-float" binaries. On the Samsung ARM Chromebook, you will be running `armhf`, which is the hard-float option. Unfortunately, soft-float [ELFs](http://en.wikipedia.org/wiki/Executable_and_Linkable_Format) are not binary-compatible with armhf, thus you might experience crashes if you don't pass the correct flags to `./configure`.

Fortunately, it's not a big problem. Emacs builds nicely, and you can get a JVM for armhf [here](http://jdk8.java.net/fxarmpreview/). On my system, I also work quite a bit with [Node.js](http://nodejs.org/); when building it, you must enable HARDFLOAT and disable the snapshot feature in V8 (otherwise V8's ARM JIT will not behave correctly).

Once you have Emacs and Java 8/armhf, you can just install and run [Leiningen](https://github.com/technomancy/leiningen) as normal, jack in to Emacs, and hack away! You will quickly forget you're on ARM hardware - it's just normal Ubuntu. Well, you might notice that there aren't any CPU fans and no second-degree burns on your legs. :-)

As you can see in the picture above, I'm also working a bit on my [Raspberry Pi](http://www.raspberrypi.org/). This work is greatly helped by having developer-spec'd ARM hardware to work on. All binaries can be copied verbatim to/from the Pi - no more ARM emulators on x86 hardware!

I recommend the Samsung ARM Chromebook for Clojure development!
