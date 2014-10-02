---
layout: post
title: "Clojure and Emacs without Cider"
description: ""
category: clojure
tags: [clojure, emacs]
---
{% include JB/setup %}

I've been hacking Clojure for many years now, and I've been happy to rekindle my love for Emacs. The Clojure/Emacs tool-chain has come a long way during this time, swank-clojure, nREPL, nrepl.el and now Cider. The feature list is ever growing, and every-time you look there are some new awesome shortcut that will 'make your day'.

However, the last couple of months have been rough for the Cider project. I've experienced lots of instability, crashes and hanged UIs. Cider has become very complex and is starting to feel bloated. I went from Visual Studio to the simpler & snappier Emacs for a reason, and there is a part of me that feel concerned that Cider is 're-inventing' an IDE inside Emacs.

In this post I'll describe a simpler Emacs/Clojure setup that I've been using for the last couple of weeks. It's much closer to 'vanilla Emacs' and thus has much less features. On the flip side, it's very fast and super stable.

It's based on Emacs standard way to talk to Lisp REPLs, `inferior-lisp-mode`. This setup bypasses nREPL completely, it simply launches `lein repl` in a buffer and communicates via stdin/stdout (never again any hanged UI because cider-nrepl middle-ware have crashed).

The setup consists of the following main emacs modes (all available on [Melpa](http://melpa.milkbox.net/#/));

- [clojure-mode](https://github.com/clojure-emacs/clojure-mode)
- paredit
- [projectile](https://github.com/bbatsov/projectile)
- [company-etags](https://github.com/company-mode/company-mode)
- [clj-refactor](https://github.com/clojure-emacs/clj-refactor.el)
- [clojure-snippets](https://github.com/mpenet/clojure-snippets)
- [align-cljlet](https://github.com/gstamp/align-cljlet)

## init.el
Here's some relevant snippets from my `init.el`, the full file can be found [here](https://github.com/martintrojer/dotfiles/blob/master/.emacs.d/full-init.el);

<script src="https://gist.github.com/martintrojer/14ebb9b2a51b8e53a6e5.js"> </script>

## A repl session with this setup
I typically start with loading the `project.clj` file of the project I want to work on. Then I'll do a `M-x run-lisp`, this will launch a repl in the `*inferior-lisp*` buffer. Now you can go ahead and type what you like in that buffer. Typically I would do `(load-dev)` and `(reset)` to start my [component](https://github.com/stuartsierra/component) system.

I also have a growing number of snippets for REPL convenience, see [here](https://github.com/martintrojer/dotfiles/tree/master/.emacs.d/snippets).

Edit text like normal, `C-c C-e` to eval sexpr under point and `C-c C-k` to eval a file (see above).

Running tests are done manually in the REPL buffer. I typically do `(run-tests)` or `(test-vars [...])`. I strongly recommend having [humane test output](https://github.com/pjstadig/humane-test-output) enabled.

## Code navigation and auto-complete
Make sure you have [Exuberant ctags](http://ctags.sourceforge.net) installed on your system; `apt-get install exuberant-ctags` or `brew install ctags`.

You will also need to put the following in `~/.ctags` [see here](https://github.com/martintrojer/dotfiles/blob/master/.ctags).

Then use `C-c p R` to rebuild your TAGS file (this works when you're in projectile mode). After that just can either do `M-.` to jump to definition (or `C-c p j`). Remember that `C-u C-space` takes you back. One great thing about tags is that you don't have to be 'jacked in' to use them! That goes for both navigation and auto-complete.

That's it really, nice and simple! If you have any nice additions to make this setup even better I'd love to hear about them.
