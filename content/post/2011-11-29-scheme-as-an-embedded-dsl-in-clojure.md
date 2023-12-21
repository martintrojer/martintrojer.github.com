---
categories:
- clojure
date: "2011-11-29T00:00:00Z"
description: ""
tags:
- clojure
- jvm
- lisp
- sicp
title: Scheme as an embedded DSL in Clojure
---

> If you give someone Fortran, he has Fortran.

> If you give someone Lisp, he has any language he pleases.

> -- Guy Steele

Replace Fortran with whatever language you are currently using, and the quote still holds true today. Lisp has been around for a long time, and it's built in flexibility is still unmatched by other languages. In this post we will look at key Lisp concepts such as code-is-data and powerful macro semantics.

When you write programs in Lisp, you tend to solve problems very differently from how you would solve them with OO languages, and also different how you would in other functional languages. Where in ML you would write a set of types and functions to operate (match) on them, in Lisp and Clojure specifically you are more likely to stick to the core data types and write functions and macros that make up a Domain Specific Language (DSL) for the problem at hand. More specifically, an internal/embedded DSL using the Lisp syntax but with new functionality that makes the solution or logic simple and clear. The ability to transform code in Lisp is very powerful indeed, and makes you think of code in a different way.

One big benefit of internal DSLs are the speed of execution. Since we map to Clojures native constructs, the examples below will run at the same speed as one defined directly in Clojure (they are infact the same!). In future posts, when we look at external DSLs using interpreters which are much slower.

So here's an example of how (a subset of) Scheme can be written as an internal DSL in Clojure. The full code is [available on github](https://github.com/martintrojer/scheme-clojure).

As you might suspect, this is pretty simple since a lot of functions are exactly the same in Scheme and Clojure.

```clojure
; addition
(+ 1 2)
(+ 1)
; division
(/ 9 3)
(/ 2)
; equality
(= 2 2)
(= 1)
(= 1 (+ 1 1) 1)
```

Some Scheme functions simply has a different name in Clojure, and can be bound to a new var like so;

```clojure
(def display println)
```

Scheme's define form is called def in Clojure, and since def is a special form, we can't use the same strategy as with display, rather we need a macro to transform define code to use def;

{{< highlight clojure >}}
(defmacro define [& args]
  `(def ~@args))
{{< /highlight >}}

This uses syntax quotes to get a new list and unquote slicing to get back to the argument list that def requires. Note that this example ignores the fact that in Scheme "define" is used for simple var bindings and function definitions [see full source code](https://github.com/martintrojer/scheme-clojure/blob/master/internal/src/mtscheme/core.clj#L38) for a macro that handles both cases.

A slightly more involved example is Scheme's cond form which uses a extra pair of parens for each case;

```clojure
;Scheme
(cond ((> 3 2) 'greater)
      ((< 3 2) 'less)
      (else equal))
;Clojure
(cond (> 3 2) :greater
      (< 3 2) :less)
      :else :equal)
```

In Clojure cond is a macro that transforms the code to a list of nested if statements. So we can write a macro for the Scheme-cond that loops over the list of cases and transforms them directly to nested ifs.

{{< highlight clojure >}}
(defmacro cond [& args]
  (when args
    (let [fst# (ffirst args)]
     (list `if (if (= fst# (symbol "else")) :else fst#)
           (second (first args))
           (cons 'cond (next args))))))
{{< /highlight >}}

As you can see we also replace the "else" symbol with a Clojure keyword (which actually can be any keyword since they are all "true", :else is used to clarity).

Clojure provides a simple but powerful "debug" functionality for macros, macroexpand. It returns the expanded code for each step in the recursion like so;

```clojure
(macroexpand-1
  '(cond ((< x 0) (- 0 x)) ((= x 0) 100) (else x)))
=> (if (< x 0) (- 0 x) (cond ((= x 0) 100) (else x)))
(clojure.walk/macroexpand-all
  '(cond ((< x 0) (- 0 x)) ((= x 0) 100) (else x)))
=> (if (< x 0) (- 0 x) (if (= x 0) 100 (if :else x nil)))
```

Here we can observe the recursive nature of the macro, any errors in the macro will be clear.

One note on this cond macro in particular is that replacing build-in function in the "host language" is a bad idea for an internal DSL. The user of the DSL expects to use the power of that host language and the extra functionality provided by the DSL. Replacing Clojure's cond can be very confusing!

Not everything is a macro, if we look at the cons funcion, there is a subtle difference between Scheme and Clojure;

```clojure
;Scheme
(cons 1 2)
;Clojure
(cons 1 [2])
```

The second parameter in clojure is a sequence. A function is more suited than a macro to translate this;

```clojure
(defn cons [fst snd]
  (clojure.core/cons fst (if (seq? snd) snd [snd])))
```

We put the second parameter in a vector unless it's already a collection. The trick here is the recursive nature of cons; (cons 1 (cons 2 3)).

This will call our new cons function twice, from the "inside out". The number 3 will be put in a vector, but the result of the nested cons will not.

Finally the read-eval-print-loop is very simple;

```clojure
(ns mtscheme-repl
  (:refer-clojure :exclude [cond cons let])   ; our DSL re-defines these
  (:use mtscheme))

(defn repl [res]
  (println res)
  (print "=> ")
  (flush)
  (clojure.core/let [l (read-line)]
                    (recur (eval (read-string l)))))

(repl "mtscheme 0.1")
```

Since our DSL have name clashes with Clojure, we need to exclude those when defining the repl namespace. The REPL itself is a simple recursive loop that reads a line, evals it and prints the result. That's it!

```clojure
mtscheme v0.1
=> (define (factorial x) (if (= x 0) 1 (* x (factorial (- x 1)))))
#'mtscheme-repl/factorial
=> (factorial 9)
362880.00
=>
```
