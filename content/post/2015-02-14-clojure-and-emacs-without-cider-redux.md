---
categories:
- clojure
date: "2015-02-14T00:00:00Z"
description: ""
tags:
- clojure
- emacs
title: Clojure and Emacs without Cider redux
---
Its been a couple of months since I've stopped using [Cider](https://github.com/clojure-emacs/cider) for Clojure development in Emacs. I find a simple 'inferior lisp' setup faster and more reliable. For a good summary of why one would consider not using Cider, see [Luke VanderHart's excellent summary](https://gist.github.com/levand/b1012bb7bdb5fcc6486f).

<!--more-->

There's been some news in the non-cider/emacs/clojure world since I wrote [my last post on the topic](http://martintrojer.github.io/clojure/2014/10/02/clojure-and-emacs-without-cider/). Mainly the release of [inf-clojure](https://github.com/clojure-emacs/inf-clojure) by Mr Batsov himself. I recently switched my emacs config over to inf-clojure and it simplified the setup quite a bit. 2 additions remain, re-loading of, and switching to, namespaces, and code navigation (with the use of etags). For more details on how to get etags working from Clojure [see here](http://martintrojer.github.io/clojure/2014/10/02/clojure-and-emacs-without-cider/#navigate).

This is the current state of my Clojure-related Emacs setup.

{{< gist martintrojer 14ebb9b2a51b8e53a6e5 init2.el >}}

<script src="https://gist.github.com/martintrojer/14ebb9b2a51b8e53a6e5.js?file=init2.el"> </script>
