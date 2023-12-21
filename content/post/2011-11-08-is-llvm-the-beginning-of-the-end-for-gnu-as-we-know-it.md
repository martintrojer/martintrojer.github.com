---
categories:
- software
date: "2011-11-08T00:00:00Z"
description: ""
tags:
- clang
- gcc
- gnu
- llvm
title: Is LLVM the beginning of the end for GNU (as we know it)?
---

[GNU](http://en.wikipedia.org/wiki/GNU_Project) and [Richard Stallman](http://en.wikipedia.org/wiki/Richard_stallman) was a real catalyst for the open source movement and it's crown jewel; the Linux kernel. Not only did [Mr Torvalds](http://en.wikipedia.org/wiki/Linus_Torvalds) early Linux releases have near 100% GNU "user-land", he also decided to use release it under the GNU Public License; GPL. GNU and Stallman is forever linked with the birth and popularization of open source, and innovated both technically and legally by turning copyright laws on it's head with the [copy-left](http://en.wikipedia.org/wiki/Copyleft) licenses. The [Free Software Foundation](http://www.fsf.org/), the custodians of the GPL, is a constant source of spicy statements about the state of the software industry.

As the years have progressed, the "<a href="http://pedrocr.net/text/how-much-gnu-in-gnu-linux">GNU percentage</a>" of the popular Linux distributions has dwindled, quite naturally if you ask me. GNU focuses on core \*ix command line and developer tools. The most important project is the <a href="http://gcc.gnu.org/">GNU Compiler Collection</a> (or GCC), used by pretty much everybody in the Linux community (and other platforms) for compiling C/C++ code. Since GCC (with binutils) can generate code for pretty much any CPU, the term "Linux community" in this context includes smartphones (Android, Linaro, Meego etc), and countless other embedded systems.

When Apple transformed <a href="http://en.wikipedia.org/wiki/NeXT">NeXT</a>&nbsp;(<a href="http://en.wikipedia.org/wiki/Mach_(kernel)">mach micro-kernel</a> and BSD user-land) into OSX, the whole tools suite was based on GCC and it's debugger GDB (targetting PowerPC). They made significant contributions to GDB to make it sing in the <a href="http://en.wikipedia.org/wiki/Xcode">XCode IDE</a>.

Even though there is a plethora of GNU projects, it's GCC (and perhaps Emacs) that kept GNU relevant moving into the 21st century.

However, there's a new kid on the open source compiler block, and it's called <a href="http://llvm.org/">LLVM </a>and <a href="http://clang.llvm.org/">Clang</a>. LLVM is real breath of fresh air in the compiler space. It features a beautiful modular architecture making it ideal for research and innovation. It already outperforms GCC in both compiler speed, and more importantly, quality of the generated code. The GCC code base has always been known to be almost impossible to work on, and LLVM has really called that bluff. LLVM/Clang is moving ahead in lightning speed, already supporting C/C++/Obj-C, features a debugger and having it's own c++ std library.

Apple is the main benefactor of the LLVM project, and they have already replaced GCC as the default compiler in XCode4. GDB to being swapped over pretty soon as well. With Apple "gone", how long will it take for the Linux community to switch over? The technical inertia should be small, since the Clang boys has gone for drop-in GCC replacement capability. If the technical benefits are there, I think the switch should be pretty rapid.

GNU without GCC is less relevant, the "GNU percentage" will drop even further. I believe we are witnessing the beginning of the end for GNU, at least in the form we know it.&nbsp;The free software foundation still has a role to play, as opinion makers, lobbyists and evangelists of the GPL.
