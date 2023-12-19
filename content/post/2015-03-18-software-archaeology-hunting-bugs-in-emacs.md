---
categories:
- software
date: "2015-03-18T00:00:00Z"
description: ""
tags:
- emacs
- gnu
- lisp
- gdb
title: Software archaeology, hunting bugs in Emacs
---

By reading the title of this post you might think this entry is about using some clever Emacs skills to find bugs in old software. But no, it's actually about hunting down bugs in Emacs itself (which incidentally happens to be very old software).

<!--more-->

## Background

Let me set the scene, I tend to do all my development inside VMs and/or Docker containers. Why? well see [here](http://martintrojer.github.io/clojure/2014/12/04/developing-clojure-in-the-cloud/) and [here](http://martintrojer.github.io/software/2015/02/22/moving-my-devboxes-to-docker/). My host OS is OSX and my guests Linux, I use [VirtualBox](http://virtualbox.org) for local VM-ing. After upgrading to OSX 10.10 I saw strange glitches when using Emacs terminal-mode in my VMs;

{{< figure src="/assets/images/emacs/garbled.png" >}}

First port of call when Emacs draws garbled text to the terminal is to check the TERM / TERMCAP environment variables. If Emacs is outputting control chars that the terminal can't understand then you found your problem. One way to check this is to do `C-l` when your screen is garbled, this causes Emacs to re-draw the screen. In my case the re-draw command rendered the screen correctly.

Some brave soul on the internet had found out that if you change the number of virtual CPUs to 1 on the VM, the problems goes away. Very strange indeed. This tells me its some kind on timing issue. After some googling I learned that world of terminals and [control codes](http://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes) is complex and messy. Control codes and the text is a byte stream which the network stack can flush at its leisure, and if you mix in the user input these network transactions becomes quite unpredictable. The problem is that this byte stream can be cut off in the middle of a control char (network packet envelope) and the terminal emulator can timeout and misinterpret the remaining stream of bytes resulting in garbled output. One possible scenario is then that OSX 10.10 made some changes to the network stack resulting in these control codes being chopped of more often. What can I say, welcome the wonderful world of computers.

## Finding a solution

So how do I arrive at this conclusion and how can we solve it?

### termscript

One of the beauties of working with terminal apps is that you can record all the draw events and then replay them (but printing them) to a terminal. This means you can figure out what the app (Emacs in this case) does to the screen on each keypress.

I used 2 methods to capture this data, Emacs has a built in command `M-x open-termscript` that starts this logging. There is also a tools like [script](http://man7.org/linux/man-pages/man1/script.1.html) and [screen](https://www.gnu.org/software/screen/manual/screen.html) that can log these events.

Here is an example termscript file.

{{< gist martintrojer b7203ca8fd851d04c9b8 termscript >}}

To read this one you'll need a table of the control codes and patience. I found cases when cursor moves seemed to be missing. That's one of these control codes, and after that point the screen will get garbled.

Here a simple script to replay the termscript (slowly)

{{< gist martintrojer b7203ca8fd851d04c9b8 replay.sh >}}

### gdb

Having familiarized myself with how Emacs sends commands to the terminal. Now the question is where (and if) we can fix the problem in Emacs itself. There is not much we can do to the network stack of the OS, but we can change up the way we send control codes which might make help to treat some of the symptoms.

Emacs is written in 2 languages, C and Elisp (most of it is in Elisp). The C code contains the core functionality (including the Elisp interpreter) that are used by all the modes etc. The C code also contains functions for writing to the terminal, outputting control codes etc. This makes want to look at the C code first, because its likely that a potential fix will be there.

Debugging Elisp code is quite pleasant, Emacs comes with many tools and modes to do just that. Debugging the C code is a different matter, you are left with good old [gdb](http://www.gnu.org/software/gdb/) which is less user friendly but still very powerful.

Step one is to download the latest Emacs [source tar ball](http://www.gnu.org/software/emacs/#Obtaining) and build it. When you build it by hand you'll get debug symbols in the binaries which is crucial when debugging. Once built we can run Emacs in the debugger. That immediately causes another problem, Emacs and gdb are now competing for the terminal making it impossible to send debugger commands and using Emacs at the same time. What we need to do is to launch Emacs by itself and attach gdb to the running process `gdb emacs <PID>`. At this point we can look at the stack trace, set breakpoints etc.

{{< gist martintrojer b7203ca8fd851d04c9b8 bt >}}

This stacktrace clearly shows the duality of Emacs, there some C code at the bottom, then a chunk of Elisp in the middle (funcall_lambda etc) and eventually back into C to update the screen / write to disk etc.

My starting point was [term.c](https://github.com/martintrojer/emacs/blob/master/src/term.c) and I was looking for code that moved the cursor. I eventually ended up looking at the function called `cmgoto` in [cm.c](https://github.com/martintrojer/emacs/blob/master/src/cm.c). This function tries to be clever and work out the cheapest way to move the cursor to where it needs to be. I put a [blunt hack](https://github.com/martintrojer/emacs/commit/bdff1ff98d02f4307659c052d0b35a40a36f0706) in here to always use the 'direct move' approach. This seems to solve the problem with re-draws what I was suffering from.

## Publishing the solution to my devboxes

Ok, we have arrived at a solution and now I have to make it available in the VMs and containers that I use for development (and to the rest of the world). I'm using Ubuntu systems, so I decided to make PPA with my patch.

Here is a short log of how to publish a [PPA](http://en.wikipedia.org/wiki/Personal_Package_Archive).

1. Create a [launchpad](https://launchpad.net) account
2. Publish your PGP key to the [Ubuntu key server](http://keyserver.ubuntu.com)
3. Paste you PGP fingerprint into the launchpad dashboard
4. Sing the 'Ubuntu Code of Conduct' on the launchpad dashboard
5. Create a new PPA

Next step is to build the deb files to publish.

1. `apt-get source emacs24-nox`
2. untar the .debian.tar.gz file (which contains the debian control files, patches etc). See [this commit](https://github.com/martintrojer/emacs-debian/commit/5a04fe59af8617e4b4eb34843f94b3b33f070941) for what I edited.
3. move the debian folder into the source folder
4. debuild -S -sa
5. You will now have a .changes file in the parent folder
6. `dput ppa:<PPA-name> <source.changes>`

After this upload is done you should receive and email saying it's been accepted and after about 15 minutes the package will be built.

The final step is to update your Dockerfiles, puppet modules etc to `add-apt-repository ppa:martin-trojer/emacs24-termfix` before install emacs. That snippet uses the PPA I created, its landing page is [here](https://launchpad.net/~martin-trojer/+archive/ubuntu/emacs24-termfix).
