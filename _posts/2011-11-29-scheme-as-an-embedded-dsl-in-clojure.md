---
layout: post
title: "Scheme as an embedded DSL in Clojure"
description: ""
category:
tags: [clojure, jvm, lisp, sicp]
---
{% include JB/setup %}

<blockquote class="tr_bq">
If you give someone Fortran, he has Fortran.<br />
If you give someone Lisp, he has any language he pleases.<br />
-- Guy Steele</blockquote>

Replace Fortran with whatever language you are currently using, and the quote still holds true today. Lisp has been around for a long time, and it's built in flexibility is still unmatched by other languages. In this post we will look at key Lisp concepts such as code-is-data and powerful macro semantics.

When you write programs in Lisp, you tend to solve problems very differently from how you would solve them with OO languages, and also different how you would in other functional languages. Where in ML you would write a set of types and functions to operate (match) on them, in Lisp and Clojure specifically you are more likely to stick to the core data types and write functions and macros that make up a Domain Specific Language (DSL) for the problem at hand. More specifically, an internal/embedded DSL using the Lisp syntax but with new functionality that makes the solution or logic simple and clear.&nbsp;The ability to transform code in Lisp is very powerful indeed, and makes you think of code in a different way.

One big benefit of internal DSLs are the speed of execution. Since we map to Clojures native constructs, the examples below will run at the same speed as one defined directly in Clojure (they are infact the same!). In future posts, when we look at external DSLs using interpreters which are much slower.

So here's an example of how (a subset of) Scheme can be written as an internal DSL in Clojure. The full code is <a href="https://github.com/martintrojer/scheme-clojure">available on github</a>.

As you might suspect, this is pretty simple since a lot of functions are exactly the same in Scheme and Clojure.
<script src="https://gist.github.com/1695041.js?file=scheme-example.clj"> </script>

Some Scheme functions simply has a different name in Clojure, and can be bound to a new var like so;
<script src="https://gist.github.com/1695041.js?file=display.clj"> </script>

Scheme's define form is called def in Clojure, and since def is a special form, we can't use the same strategy as with display, rather we need a macro to transform define code to use def;
<script src="https://gist.github.com/1695041.js?file=define.clj"> </script>

This uses syntax quotes to get a new list and unquote slicing to get back to the argument list that def requires. Note that this example ignores the fact that in Scheme "define" is used for simple var bindings and function definitions <a href="https://github.com/martintrojer/scheme-clojure/blob/master/internal/mtscheme.clj#L42">see full source code</a> for a macro that handles both cases.

A slightly more involved example is Scheme's cond form which uses a extra pair of parens for each case;
<script src="https://gist.github.com/1695041.js?file=cond-example.clj"> </script>
In Clojure cond is a macro that transforms the code to a list of nested if statements. So we can write a macro for the Scheme-cond that loops over the list of cases and transforms them directly to nested ifs.
<script src="https://gist.github.com/1695041.js?file=cond.clj"> </script>
As you can see we also replace the "else" symbol with a Clojure keyword (which actually can be any keyword since they are all "true", :else is used to clarity).

Clojure provides a simple but powerful "debug" functionality for macros, macroexpand. It returns the expanded code for each step in the recursion like so;
<script src="https://gist.github.com/1695041.js?file=macroexpand.clj"> </script>
Here we can observe the recursive nature of the macro, any errors in the macro will be clear.

One note on this cond macro in particular is that replacing build-in function in the "host language" is a bad idea for an internal DSL. The user of the DSL expects to use the power of that host language and the extra functionality provided by the DSL. Replacing Clojure's cond can be very confusing!

Not everything is a macro, if we look at the cons funcion, there is a subtle difference between Scheme and Clojure;
<script src="https://gist.github.com/1695041.js?file=cons-example.clj"> </script>
The second parameter in clojure is a sequence. A function is more suited than a macro to translate this;
<script src="https://gist.github.com/1695041.js?file=cons.clj"> </script>
We put the second parameter in a vector unless it's already a collection. The trick here is the recursive nature of cons; (cons 1 (cons 2 3)).

This will call our new cons function twice, from the "inside out". The number 3 will be put in a vector, but the result of the nested cons will not.

Finally the read-eval-print-loop is very simple;
<script src="https://gist.github.com/1695041.js?file=repl.clj"> </script>

Since our DSL have name clashes with Clojure, we need to exclude those when defining the repl namespace. The REPL itself is a simple recursive loop that reads a line, evals it and prints the result. That's it!
<script src="https://gist.github.com/1695041.js?file=repl-example"> </script>