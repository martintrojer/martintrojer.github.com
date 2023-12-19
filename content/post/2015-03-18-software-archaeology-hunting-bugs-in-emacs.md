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

```
[[?25l^[[38;5;252m^[[40m                          ^[[39;49m^[[2;1H^[[?12l^[[?25h^[[?12;25h^[[43d^[[?25l^[[38;5;77m^[[40mRegexp I-search: ^[[39;49m^[[2;1H^[[?12l^[[?25h^[[?12;25h^[[42;57H^[[?25l^[[3
8;5;69m^[[48;5;236m Isearch) 10:16 jvm[2] ^[[39;49m^[[2;1H^[[?12l^[[?25h^[[?12;25h^[[43;18H^[[?25l^[[38;5;252m^[[40mC^[[39;49m^[[?12l^[[?25h^[[?12;25h^[[2;1H^[[5d^[[?25l^[[30m^[[48;5;198mC^[[39;49m^
[[42;34H^[[38;5;69m^[[48;5;236m5,1^[[39;49m^[[5;2H^[[?12l^[[?25h^[[?12;25h^[[5;24H^[[?25l^[[30m^[[103mC^[[39;49m^[[7;1H^[[30m^[[103mC^[[39;49m^[[9;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 SP^
[[39;49m^[[30m^[[103mC^[[39;49m^[[10;1H^[[30m^[[103mC^[[39;49m^[[11;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 "         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[12;1H^[[30m^[[103mC^[[39;49m^[
[13;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 '         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[14;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 *         Prefix ^[[39;49m^[[30m^[[103mC^[[
39;49m^[[15;1H^[[30m^[[103mC^[[39;49m^[[16;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 ,         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[17;1H^[[30m^[[103mC^[[39;49m^[[18;1H^[[30m^[[103mC^[[39
;49m^[[19;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 /         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[5;2H^[[?12l^[[?25h^[[?12;25h^[[20;1H^[[?25l^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8
 1         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[21;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 3         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[22;1H^[[30m^[[103mC^[[39;49m^[[23;1H^[[30m
^[[103mC^[[39;49m^[[24;1H^[[30m^[[103mC^[[39;49m^[[25;1H^[[30m^[[103mC^[[39;49m^[[26;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 ^[[39;49m^[[30m^[[103mC^[[39;49m^[[27;1H^[[30m^[[103mC^[[39;49m^[
[28;1H^[[30m^[[103mC^[[39;49m^[[29;1H^[[30m^[[103mC^[[39;49m^[[30;1H^[[30m^[[103mC^[[39;49m^[[31;1H^[[30m^[[103mC^[[39;49m^[[32;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 ^         Prefix ^[[39
;49m^[[30m^[[103mC^[[39;49m^[[33;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 _         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[34;1H^[[30m^[[103mC^[[39;49m^[[5d^[[?12l^[[?25h^[[?12;25h^[[34;24
H^[[?25l^[[30m^[[103mC^[[39;49m^[[35;1H^[[30m^[[103mC^[[39;49m^[[36;1H^[[30m^[[103mC^[[39;49m^[[37;1H^[[30m^[[103mC^[[39;49m^[[38;1H^[[30m^[[103mC^[[39;49m^[[39;1H^[[30m^[[103mC^[[39;49m^[[40;1H^[[3
0m^[[103mC^[[39;49m^[[41;1H^[[30m^[[103mC^[[39;49m^[[38;5;252m^[[40m-x 8 ~         Prefix ^[[39;49m^[[30m^[[103mC^[[39;49m^[[5;2H^[[?12l^[[?25h^[[?12;25h^[[43;19H^[[?25l^[[38;5;252m^[[40m-^[[39;49m^
[[?12l^[[?25h^[[?12;25h^[[5;2H^[[?25l^[[30m^[[48;5;198m-^[[39;49m^[[42;36H^[[38;5;69m^[[48;5;236m2^[[39;49m^[[5;3H^[[?12l^[[?25h^[[?12;25h^[[5;24H^[[?25l^[[38;5;252m^[[40mC^[[39;49m^[[7;1H^[[38;5;25
2m^[[40mC^[[39;49m^[[9;1H^[[38;5;252m^[[40mC-x 8 SPC^[[39;49m^[[10;1H^[[38;5;252m^[[40mC^[[39;49m^[[11;1H^[[38;5;252m^[[40mC-x 8 "         Prefix C^[[39;49m^[[12;1H^[[38;5;252m^[[40mC^[[39;49m^[[13;
1H^[[38;5;252m^[[40mC-x 8 '         Prefix C^[[39;49m^[[14;1H^[[38;5;252m^[[40mC-x 8 *         Prefix C^[[39;49m^[[15;1H^[[38;5;252m^[[40mC^[[39;49m^[[16;1H^[[38;5;252m^[[40mC-x 8 ,         Prefix C
^[[39;49m^[[17;1H^[[38;5;252m^[[40mC^[[39;49m^[[18;1H^[[38;5;252m^[[40mC^[[39;49m^[[19;1H^[[38;5;252m^[[40mC-x 8 /         Prefix C^[[39;49m^[[20;1H^[[38;5;252m^[[40mC-x 8 1         Prefix C^[[39;49
m^[[21;1H^[[38;5;252m^[[40mC-x 8 3         Prefix C^[[39;49m^[[22;1H^[[38;5;252m^[[40mC^[[39;49m^[[23;1H^[[38;5;252m^[[40mC^[[39;49m^[[24;1H^[[38;5;252m^[[40mC^[[39;49m^[[25;1H^[[38;5;252m^[[40mC^[[
39;49m^[[26;1H^[[38;5;252m^[[40mC-x 8 C^[[39;49m^[[27;1H^[[38;5;252m^[[40mC^[[39;49m^[[28;1H^[[38;5;252m^[[40mC^[[39;49m^[[29;1H^[[38;5;252m^[[40mC^[[39;49m^[[30;1H^[[38;5;252m^[[40mC^[[39;49m^[[31;
1H^[[38;5;252m^[[40mC^[[39;49m^[[32;1H^[[38;5;252m^[[40mC-x 8 ^         Prefix C^[[39;49m^[[33;1H^[[38;5;252m^[[40mC-x 8 _         Prefix C^[[39;49m^[[34;1H^[[38;5;252m^[[40mC-x 8 `         Prefix C
^[[39;49m^[[35;1H^[[38;5;252m^[[40mC^[[39;49m^[[36;1H^[[38;5;252m^[[40mC^[[39;49m^[[37;1H^[[38;5;252m^[[40mC^[[39;49m^[[38;1H^[[38;5;252m^[[40mC^[[39;49m^[[39;1H^[[38;5;252m^[[40mC^[[39;49m^[[40;1H^
[[38;5;252m^[[40mC^[[39;49m^[[41;1H^[[38;5;252m^[[40mC-x 8 ~         Prefix C
```

To read this one you'll need a table of the control codes and patience. I found cases when cursor moves seemed to be missing. That's one of these control codes, and after that point the screen will get garbled.

Here a simple script to replay the termscript (slowly)

```sh
while read line; do
  echo "$line"
  sleep 2
done < "$1"
```

### gdb

Having familiarized myself with how Emacs sends commands to the terminal. Now the question is where (and if) we can fix the problem in Emacs itself. There is not much we can do to the network stack of the OS, but we can change up the way we send control codes which might make help to treat some of the symptoms.

Emacs is written in 2 languages, C and Elisp (most of it is in Elisp). The C code contains the core functionality (including the Elisp interpreter) that are used by all the modes etc. The C code also contains functions for writing to the terminal, outputting control codes etc. This makes want to look at the C code first, because its likely that a potential fix will be there.

Debugging Elisp code is quite pleasant, Emacs comes with many tools and modes to do just that. Debugging the C code is a different matter, you are left with good old [gdb](http://www.gnu.org/software/gdb/) which is less user friendly but still very powerful.

Step one is to download the latest Emacs [source tar ball](http://www.gnu.org/software/emacs/#Obtaining) and build it. When you build it by hand you'll get debug symbols in the binaries which is crucial when debugging. Once built we can run Emacs in the debugger. That immediately causes another problem, Emacs and gdb are now competing for the terminal making it impossible to send debugger commands and using Emacs at the same time. What we need to do is to launch Emacs by itself and attach gdb to the running process `gdb emacs <PID>`. At this point we can look at the stack trace, set breakpoints etc.

```
(gdb) bt
#0  cmgoto (tty=0x126bbc0, row=45, col=0) at cm.c:320
#1  0x000000000040a642 in update_frame_line (f=f@entry=0xb06300, vpos=45) at dispnew.c:5031
#2  0x000000000040bcfb in update_frame_1 (f=f@entry=0xb06300, force_p=force_p@entry=true, inhibit_id_p=inhibit_id_p@entry=true, set_cursor_p=set_cursor_p@entry=true) at dispnew.c:4512
#3  0x000000000040d770 in update_frame (f=f@entry=0xb06300, force_p=<optimized out>, force_p@entry=true, inhibit_hairy_id_p=inhibit_hairy_id_p@entry=true) at dispnew.c:3113
#4  0x0000000000432c12 in echo_area_display (update_frame_p=update_frame_p@entry=1) at xdisp.c:11310
#5  0x0000000000432d5e in message3_nolog (m=m@entry=19444193) at xdisp.c:10271
#6  0x0000000000432f1a in message3 (m=m@entry=19444193) at xdisp.c:10213
#7  0x00000000004f4ddb in Fmessage (nargs=<optimized out>, args=<optimized out>) at editfns.c:3452
#8  0x00000000004fc891 in Ffuncall (nargs=<optimized out>, args=<optimized out>) at eval.c:2793
#9  0x0000000000530065 in exec_byte_code (bytestr=1, vector=45, maxdepth=0, args_template=11479922, nargs=140736461706320, args=0x3) at bytecode.c:916
#10 0x00000000004fc43f in funcall_lambda (fun=9442429, nargs=nargs@entry=0, arg_vector=arg_vector@entry=0x7fffc2ce9610) at eval.c:3045
#11 0x00000000004fc7b3 in Ffuncall (nargs=1, args=0x7fffc2ce9608) at eval.c:2873
#12 0x0000000000530065 in exec_byte_code (bytestr=1, vector=45, maxdepth=0, args_template=11479922, nargs=140736461706752, args=0x1) at bytecode.c:916
#13 0x00000000004fc43f in funcall_lambda (fun=9412165, nargs=nargs@entry=0, arg_vector=arg_vector@entry=0x7fffc2ce97c0) at eval.c:3045
#14 0x00000000004fc7b3 in Ffuncall (nargs=1, args=0x7fffc2ce97b8) at eval.c:2873
#15 0x0000000000530065 in exec_byte_code (bytestr=1, vector=45, maxdepth=0, args_template=11479922, nargs=140736461707184, args=0x1) at bytecode.c:916
#16 0x00000000004fc43f in funcall_lambda (fun=9411149, nargs=nargs@entry=4, arg_vector=arg_vector@entry=0x7fffc2ce9970) at eval.c:3045
#17 0x00000000004fc7b3 in Ffuncall (nargs=5, args=0x7fffc2ce9968) at eval.c:2873
#18 0x0000000000530065 in exec_byte_code (bytestr=1, vector=45, maxdepth=0, args_template=11479922, nargs=0, args=0x5) at bytecode.c:916
#19 0x00000000004fc43f in funcall_lambda (fun=9409613, nargs=nargs@entry=2, arg_vector=arg_vector@entry=0x7fffc2ce9b78) at eval.c:3045
#20 0x00000000004fc7b3 in Ffuncall (nargs=nargs@entry=3, args=args@entry=0x7fffc2ce9b70) at eval.c:2873
#21 0x00000000004f8d40 in Fcall_interactively (function=<optimized out>, record_flag=<optimized out>, keys=<optimized out>) at callint.c:836
#22 0x00000000004fc990 in Ffuncall (nargs=<optimized out>, args=<optimized out>) at eval.c:2819
#23 0x0000000000530065 in exec_byte_code (bytestr=1, vector=45, maxdepth=0, args_template=4100, nargs=140736461708624, args=0x4) at bytecode.c:916
#24 0x00000000004fc4d7 in funcall_lambda (fun=0, nargs=nargs@entry=1, arg_vector=0x88bc59 <pure+910393>, arg_vector@entry=0x7fffc2ce9ea8) at eval.c:2979
#25 0x00000000004fc7b3 in Ffuncall (nargs=nargs@entry=2, args=args@entry=0x7fffc2ce9ea0) at eval.c:2873
#26 0x00000000004fcafa in call1 (fn=<optimized out>, arg1=<optimized out>) at eval.c:2611
#27 0x0000000000499c45 in command_loop_1 () at keyboard.c:1559
#28 0x00000000004fadae in internal_condition_case (bfun=bfun@entry=0x4998e0 <command_loop_1>, handlers=<optimized out>, hfun=hfun@entry=0x490f00 <cmd_error>) at eval.c:1348
#29 0x000000000048c98e in command_loop_2 (ignore=ignore@entry=11479922) at keyboard.c:1177
#30 0x00000000004facbb in internal_catch (tag=11526722, func=func@entry=0x48c970 <command_loop_2>, arg=11479922) at eval.c:1112
#31 0x0000000000490b27 in command_loop () at keyboard.c:1156
#32 recursive_edit_1 () at keyboard.c:777
#33 0x0000000000490e3d in Frecursive_edit () at keyboard.c:848
#34 0x000000000040620b in main (argc=<optimized out>, argv=0x7fffc2cea238) at emacs.c:1646
```

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
