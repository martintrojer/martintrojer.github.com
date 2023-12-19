---
categories:
- clojure
date: "2016-06-14T00:00:00Z"
description: ""
tags:
- clojure
- racket
- contracts
- test.check
- quickcheck
title: Some thoughts on clojure.spec
---
Some of the readers of my [Beyond Clojure](/categories/beyond-clojure/) blog series have asked about my opinion on clojure.spec, and if it solves Clojure's 'type problem'. Implying whether its presence makes me look more favorably on Clojure. Here are some of my thoughts.

<!--more-->

### Runtime contracts vs Types

[Clojure.spec](https://clojure.org/about/spec) (and [Prismatic/Schema](https://github.com/plumatic/schema)) are what I like to call 'runtime contracts' or just contracts. This means they are assertions that validate data at runtime. Spec (and Schema) gives you a declarative way to defining these contracts, which at the end of the day boils down to something like `{:pre [(integer? x)]}`.

To summarize the key differences between contracts and types;

* Contracts operates at run-time and do a 'there-exists' proof on sample data.
* Types operates at compile-time and do a 'for-all' proof on all possible data.

You need to feed data through a contract for it be of any value, it can't do anything at compile time (except generating more contracts). Types on the other hand are only checked at compile time, and in most cases don't even exist at runtime. Think of contracts as auditing data as it passes through the system and types are proving ahead of time that data can't be invalid (you might object here, see input valdation below).

Contracts always have a negative impact on the performance of your code. Types have AT WORST no performance impact, and in most cases positive impact on performance, since the compiler can generate more efficient code.

Even though contracts are just a there-exists check, they give you higher confidence in your code, which in practice can be similar to the benefits of type checking. This confidence is only as high as how much (and different) data you are feeding through the contracts. This means that contracts have to be coupled with (exhaustive) tests to give this boost in confidence, the same is not true for type checking.

### Property based testing

The need for exhaustive tests is why contracts and property based testing (PBT) is such a good combination, since PBT will generate thousands of test cases (that you don't have to write down nor have come up with in the first place). Spec and Schema allow you to automatically generate [test.check](https://github.com/clojure/test.check) generators directly from the contract definitions. This is analogous to how Haskell / [QuickCheck](https://hackage.haskell.org/package/QuickCheck) uses its types and type-classes to automatically generate test cases. This is very powerful, but there are plenty of cases IMHO where PBT is not practical and you're better off with hand-written unit tests. Any non-pure function is problematic, since you're immediately into the world of mocking. If you look at a typical web app, there are lots of non-pure functions around. For instance, all database-interaction 'model' functions plus all the functions (like the handlers) that use those models. Typically, these are the functions (models and handlers) that I really care about testing in a web app. None of them are a great fit for PBT.

The alternative to hand-written unit tests in these cases are complicated PBT generators, which is far beyond what clojure.spec can auto-generate from a definition. In my experience hand-written examples are easier to read and maintain than fancy PBT generators.

### Input validation

What I've been talking about so far is the type of contracts you would typically turn off in production, and only have on while developing and running tests. Checking the shape of maps going in / out of functions etc. They serve as documentation and confidence boosters that you haven't messed up things terribly in your latest diff. There are however another side to contracts, which you really need in production code, input validation. Schema neatly combines these two worlds in one model and super-charges it with [coercions](https://github.com/plumatic/schema#transformations-and-coercion), which I'm a big fan of. Spec does something similar, with very nice destructuring enhancements but somewhat worse coercion features than Schema.

Types alone doesn't help you with input validation, you need something (like a parser) that maps the input data to the types the rest of your code relies on.

### Summary

I've been a heavy user of Prismatic/Schema since it was released. Contracts are very useful, I simply can't imagine writing any Clojure code without them. Spec is a nice addition with some good ideas and has the chance to gain more adoption than Schema given it's bundled into clojure.core. If popular libraries adopt Spec it can lead to higher confidence / better testing / fewer bugs in your Clojure code. However, it doesn't solve the Clojure 'type problem' anymore than Schema did. Contracts are essential for dynamic languages where 'there-exists' proofs is the best you can do. With Spec Clojure is playing the cards it was dealt the best it can but there are plenty of royal flushes on the other side of the fence.

Ps. If you're interested on how far runtime contracts can be taken, I strongly recommend you to checkout [Racket's](https://racket-lang.org/) excellent [contracts system](https://docs.racket-lang.org/guide/contracts.html). Great documentation too! The authors of Racket are the true pioneers in the field of runtime contracts. Ds.
