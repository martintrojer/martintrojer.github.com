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

There's been some news in the non-cider/emacs/clojure world since I wrote [my last post on the topic](http://martintrojer.github.io/clojure/2014/10/02/clojure-and-emacs-without-cider/). Mainly the release of [inf-clojure](https://github.com/clojure-emacs/inf-clojure) by Mr Batsov himself. I recently switched my emacs config over to inf-clojure and it simplified the setup quite a bit. 2 additions remain, re-loading of, and switching to, namespaces, and code navigation (with the use of etags). For more details on how to get etags working from Clojure [see here]({{< ref "2014-10-02-clojure-and-emacs-without-cider#navigate" >}}).

This is the current state of my Clojure-related Emacs setup.

```el
;; Clojure
(require 'clojure-mode)
(setq auto-mode-alist (cons '("\\.cljs$" . clojure-mode) auto-mode-alist))

(require 'inf-clojure)
(setq inf-clojure-prompt-read-only nil)
(add-hook 'inf-clojure-minor-mode-hook   ;; prevent company-mode from freezing Emacs when the REPL is busy
          (lambda () (setq completion-at-point-functions nil)))
(add-hook 'clojure-mode-hook 'inf-clojure-minor-mode)

(defun reload-current-clj-ns (next-p)
  (interactive "P")
  (let ((ns (clojure-find-ns)))
    (message (format "Loading %s ..." ns))
    (inf-clojure-eval-string (format "(require '%s :reload)" ns))
    (when (not next-p) (inf-clojure-eval-string (format "(in-ns '%s)" ns)))))

(defun find-tag-without-ns (next-p)
  (interactive "P")
  (find-tag (first (last (split-string (symbol-name (symbol-at-point)) "/")))
            next-p))

(defun erase-inf-buffer ()
  (interactive)
  (with-current-buffer (get-buffer "*inf-clojure*")
    (erase-buffer))
  (inf-clojure-eval-string ""))

(add-hook 'clojure-mode-hook
          '(lambda ()
             (define-key clojure-mode-map "\C-c\C-k" 'reload-current-clj-ns)
             (define-key clojure-mode-map "\M-." 'find-tag-without-ns)
             (define-key clojure-mode-map "\C-cl" 'erase-inf-buffer)
             (define-key clojure-mode-map "\C-c\C-t" 'clojure-toggle-keyword-string)))
(add-hook 'inf-clojure-mode-hook
          '(lambda ()
             (define-key inf-clojure-mode-map "\C-cl" 'erase-inf-buffer)))

;; clj-refactor
(require 'clj-refactor)
(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
                               (cljr-add-keybindings-with-prefix "C-c C-o")))

;; align-cljlet
(require 'align-cljlet)
(add-hook 'clojure-mode-hook
          '(lambda ()
             (define-key clojure-mode-map "\C-c\C-y" 'align-cljlet)))

;; paredit
(require 'paredit)
(add-hook 'clojure-mode-hook 'paredit-mode)

;; projectile
(require 'projectile)
(add-hook 'clojure-mode-hook 'projectile-mode)

;; company-mode
(require 'company)
(require 'company-etags)
(add-to-list 'company-etags-modes 'clojure-mode)
(add-hook 'after-init-hook 'global-company-mode)

;; yasnippet
(require 'yasnippet)
(require 'clojure-snippets)
(yas-global-mode 1)
(add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
(yas-load-directory "~/.emacs.d/snippets")
```
