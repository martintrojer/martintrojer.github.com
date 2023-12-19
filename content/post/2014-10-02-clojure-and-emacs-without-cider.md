---
categories:
- clojure
date: "2014-10-02T00:00:00Z"
description: ""
tags:
- clojure
- emacs
title: Clojure and Emacs without Cider
---

I've been hacking Clojure for many years now, and I've been happy to rekindle my love for Emacs. The Clojure/Emacs tool-chain has come a long way during this time, swank-clojure, nREPL, nrepl.el and now Cider. The feature list is ever growing, and every-time you look there are some new awesome shortcut that will 'make your day'.

<!--more-->

However, the last couple of months have been rough for the Cider project. I've experienced lots of instability, crashes and hanged UIs. Cider has become very complex and is starting to feel bloated. I went from Visual Studio to the simpler & snappier Emacs for a reason, and there is a part of me that feel concerned that Cider is 're-inventing' an IDE inside Emacs. If you want a full Clojure/IDE experience with all the bells and whistles, check out [Cursive Clojure](https://cursiveclojure.com), its great.

In this post I'll describe a simpler Emacs/Clojure setup that I've been using for the last couple of weeks. It's much closer to 'vanilla Emacs' and thus have much fewer features. On the flip side, it's very fast and super stable.

It's based on Emacs standard way to talk to Lisp REPLs, `inferior-lisp-mode`. This setup bypasses nREPL completely, it simply launches `lein repl` in a buffer and communicates via stdin/stdout.

The setup consists of the following emacs modes (all available on [Melpa](http://melpa.milkbox.net/#/));

- [clojure-mode](https://github.com/clojure-emacs/clojure-mode)
- paredit
- [projectile](https://github.com/bbatsov/projectile)
- [company-etags](https://github.com/company-mode/company-mode)
- [clj-refactor](https://github.com/clojure-emacs/clj-refactor.el)
- [clojure-snippets](https://github.com/mpenet/clojure-snippets)
- [align-cljlet](https://github.com/gstamp/align-cljlet)

## init.el
Here's some relevant snippets from my `init.el`, the full file can be found [here](https://github.com/martintrojer/dotfiles/blob/master/.emacs.d/full-init.el);

```el
;; Clojure
(require 'clojure-mode)
(setq auto-mode-alist (cons '("\\.cljs$" . clojure-mode) auto-mode-alist))
(setq inferior-lisp-program "lein repl")

;; clj-refactor
(require 'clj-refactor)
(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
                               (cljr-add-keybindings-with-prefix "C-c C-o")))

;; align-cljlet
(require 'align-cljlet)
(global-set-key (kbd "C-c C-a") 'align-cljlet)

;; paredit
(require 'paredit)
(add-hook 'clojure-mode-hook 'paredit-mode)

;; projectile
(require 'projectile)
(add-hook 'clojure-mode-hook 'projectile-mode)

;; company-mode
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(require 'company-etags)
(add-to-list 'company-etags-modes 'clojure-mode)

(defun get-clj-completions (prefix)
  (let* ((proc (inferior-lisp-proc))
         (comint-filt (process-filter proc))
         (kept ""))
    (set-process-filter proc (lambda (proc string) (setq kept (concat kept string))))
    (process-send-string proc (format "(complete.core/completions \"%s\")\n"
                                      (substring-no-properties prefix)))
    (while (accept-process-output proc 0.1))
    (setq completions (read kept))
    (set-process-filter proc comint-filt)
    completions))

(defun company-infclj (command &optional arg &rest ignored)
  (interactive (list 'interactive))

  (cl-case command
    (interactive (company-begin-backend 'company-infclj))
    (prefix (and (eq major-mode 'inferior-lisp-mode)
                 (company-grab-symbol)))
    (candidates (get-clj-completions arg))))

(add-to-list 'company-backends 'company-infclj)

;; yasnippet
(require 'yasnippet)
(require 'clojure-snippets)
(yas-global-mode 1)
(add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
(yas-load-directory "~/.emacs.d/snippets")

;; Some handly key bindings

(global-set-key (kbd "C-c C-s") 'clojure-toggle-keyword-string)

(defun reload-current-clj-ns ()
  (interactive)
  (let ((current-point (point)))
    (goto-char (point-min))
    (let ((ns-idx (re-search-forward clojure-namespace-name-regex nil t)))
      (when ns-idx
        (goto-char ns-idx)
        (let ((sym (symbol-at-point)))
          (message (format "Loading %s ..." sym))
          (lisp-eval-string (format "(require '%s :reload)" sym))
          (lisp-eval-string (format "(in-ns '%s)" sym)))))
    (goto-char current-point)))

(defun find-tag-without-ns (next-p)
  (interactive "P")
  (find-tag (first (last (split-string (symbol-name (symbol-at-point)) "/")))
            next-p))

(defun erase-inf-buffer ()
  (interactive)
  (erase-buffer)
  (lisp-eval-string ""))

(add-hook 'clojure-mode-hook
          '(lambda ()
             (define-key clojure-mode-map "\C-c\C-k" 'reload-current-clj-ns)
             (define-key clojure-mode-map "\M-." 'find-tag-without-ns)))
(add-hook 'inferior-lisp-mode-hook
          '(lambda ()
             (define-key inferior-lisp-mode-map "\C-cl" 'erase-inf-buffer)))
```

## A repl session with this setup
I typically start with loading the `project.clj` file of the project I want to work on. Then I'll do a `M-x run-lisp`, this will launch a repl in the `*inferior-lisp*` buffer. Now you can go ahead and type what you like in that buffer. Typically I would do `(load-dev)` and `(reset)` to start my [component](https://github.com/stuartsierra/component) system.

I also have a growing number of snippets for REPL convenience, see [here](https://github.com/martintrojer/dotfiles/tree/master/.emacs.d/snippets).

Edit text like normal, `C-c C-e` to eval sexpr under point and `C-c C-k` to eval a file (see above).

Running tests are done manually in the REPL buffer. I typically do `(run-tests)` or `(test-vars [...])`. I strongly recommend having [humane test output](https://github.com/pjstadig/humane-test-output) enabled.

<div id="navigate"></div>
## Code navigation and auto-complete
Make sure you have [Exuberant ctags](http://ctags.sourceforge.net) installed on your system; `apt-get install exuberant-ctags` or `brew install ctags`.

You will also need to add `--langmap=Lisp:+.clj.cljs` into `~/.ctags`; [see here](https://github.com/martintrojer/dotfiles/blob/master/.ctags).

Then use `C-c p R` to rebuild your TAGS file (this works when you're in projectile mode). After that just can either do `M-.` to jump to definition (and `C-u M-.` for next match), remember that `M-*` takes you back. One great thing about tags is that you don't have to be 'jacked in' to use them! That goes for both navigation and auto-complete.

That's it really, nice and simple! If you have any additions to make this setup even better I'd love to hear about them.
