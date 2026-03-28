---
categories:
- scala
date: "2013-06-06T00:00:00Z"
description: ""
tags:
- scala
- lisp
title: Scheme in Scala
---
In this post, I present some of my experiences writing a [Scheme interpreter in Scala](https://github.com/martintrojer/scheme-scala) (as an external DSL) and compare it with my recent similar experiences in Clojure and F#.

Overall, the Scala solution is very similar to the [F# one](https://github.com/martintrojer/scheme-fsharp). Not very surprising, since the problem lends itself well to case classes / discriminated union types and pattern matching. One difference is more type declarations in Scala, due to the lack of Hindley-Milner type inference. Scala uses a "flow-based" type inferrer, which is less powerful than ML but apparently works better for OO subclasses, etc. I will look into this in a future blog post.

Here's the eval/apply function:

{{< highlight scala >}}
def eval(env: Env, expr: ExprT): (Env, ExprT) = expr match {
  case NullExpr()       => throw new IllegalStateException("invalid interpreter state")
  case Comb(List())     => throw new IllegalStateException("invalid combination")
  case Comb(h :: t)     =>
    eval(env, h) match {
      case (_, Proc(f))             => apply(f, t, env)
      case (nEnv, Func(args, body)) => {
        if (args.length != t.length) throw new IllegalArgumentException("invalid number or arguments")
        val newEnv = (args zip t).foldLeft(nEnv.expand())((acc, av) => bindArg(acc, av._1, av._2))
        evalAll(newEnv, body)
      }
      case (nEnv, expr)             => (nEnv, expr)
    }
  case Proc(f)          => (env, Proc(f))
  case Func(args, body) => throw new IllegalArgumentException("invalid function call")
  case v @ Value(_)     => (env, v)
  case l @ List(_)      => (env, l)
  case Symbol(s)        =>
    env.lookUp(s) match {
      case Some(e)  => (env, e)
      case None     => throw new IllegalArgumentException("unbound symbol '" + s +"'")
  }
}

private def apply(f: ((Env, List[ExprT]) => (Env, ExprT)),
                  args: List[ExprT], env: Env) =
  f(env, args)
{{< /highlight >}}

## OO vs. FP

Scala feels like an OO language with FP features, whereas Clojure and F# appear the other way around. In Clojure and F#, you typically group functions that somehow "belong together" in namespaces/modules; in Scala, you put them in classes and objects (Scala speak for singletons). You can treat these objects like namespaces if you want, but that doesn't feel like idiomatic Scala. One example of this, in this particular case, is the environment (or stack) functions that sat quite happily in the interpreter namespace in F#/Clojure. In Scala, that felt awkward, so I ended up creating an [Env class](https://github.com/martintrojer/scheme-scala/blob/master/src/main/scala/mtscheme/Env.scala) with some methods to model this better.

This Scheme implementation is still very FP, and I don't really feel the OO parts get in the way. But it highlights the issue that Scala isn't a very opinionated language. Many paradigms are supported: old-school OO with mutable variables/collections is idiomatic just as strict immutable, function-oriented code. Discipline is needed if a codebase of any size, worked on by many individuals, is to be kept coherent.

Scala tries to fix some of the common problems found in popular OO languages with features like [abstract types](http://www.scala-lang.org/node/105), [implicits](http://blog.joa-ebert.com/2010/12/26/understanding-scala-implicits/), [co/contra-variance](http://blogs.atlassian.com/2013/01/covariance-and-contravariance-in-scala/), and more. It's all very clever stuff, but be prepared to spend quite a bit of time getting the type declarations right if you want to leverage all this.

It can be argued that time is better spent working on the problems/functions themselves instead of messing about with clever type annotations ([speaking to the problem vs. speaking to the compiler](http://vimeo.com/16753929#)). The just as valid counter-argument is that once you've gotten your types and model right, the type system will help you drive your code and eliminate many logical errors early. I do enjoy that warm fuzzy feeling you get when the compiler tells you about forgotten pattern match cases, and the "if it compiles, it works" experience.

## Parsing

I'm really impressed by [scala.util.parsing.combinator](http://www.scala-lang.org/api/current/index.html#scala.util.parsing.combinator.Parsers). The code below is the entire parser, both readable (once you get the hang of it) and powerful.

{{< highlight scala >}}

import scala.util.parsing.combinator._

object Parser extends JavaTokenParsers {
  def value: Parser[ValueT] = stringLiteral ^^ (x => Name(x.tail.init)) |
                              floatingPointNumber ^^ (x => Num(BigDecimal(x)))
  def expression: Parser[ExprT] = value ^^ (x => Value(x)) |
                                  """[^()\s]+""".r ^^ (x => Symbol(x)) |
                                  combination
  def combination: Parser[Comb] = "(" ~> rep(expression) <~ ")" ^^ (x => Comb(x))
  def program: Parser[List[ExprT]] = rep(expression)

  // ---

  def parse(source: String) = parseAll(program, source).get
}
{{< /highlight >}}

The way you map the parse results onto your own type domain is fantastic. Contrast this is an example of a [hand rolled parser](https://github.com/martintrojer/scheme-scala/blob/master/src/main/scala/mtscheme/HandRolledParser.scala), which still is pretty neat if you ask me, but much more code.

## IDE vs Emacs and REPLs

I decided to use IntelliJ for this project, and the experience was much better than when I used the abysmal [Eclipse/Scala](http://scala-ide.org/index.html) package 4-5 months ago. Maybe the Eclipse integration is better now, but I've been scarred for life. I have no complaints really, all the IntelliJ goodness and a pretty rock solid compile/debug/run tests work flow. You can also drop into the [SBT](http://www.scala-sbt.org/) console, which is similar to the F# interactive stuff in Visual Studio -- which give you a REPL-like shell where you can get to your objects that your currently writing.

I did quickly fall into the old trodden tracks of writing unit test to drive my coding. Coming from Clojure this is a bit of a change where work is much more interactive, in the REPL, and unit tests feels more like an afterthought. The compiler is also more apparent working with Scala, while is pretty well hidden in the Clojure flow. One of the reasons it's more in your face is because it's a lot slower, which is understandable since it's doing a lot more. That fact that there is an obvious compile step also drives you towards "old" work flows.

Scala [Emacs integration](https://github.com/aemoncannon/ensime) looks promising, but I didn't use it enough to give a verdict. However, I do feel that due to the OO aspects of Scala, an traditional IDE is probably a better fit. I used the refactor functions in IntelliJ frequently. I also used the debugger on occasion, and it's hard to beat an IDE in that area. Dropping stack frames in the debugger and running again etc is powerful stuff.

Finally, JVM hot-swapping is less useful in Scala than Java, due to how many classes etc is generated under the covers even for quite small changes. It's a bit sad, since it's a real time saver working with Java, maybe this is better with JRebel?

## Speed

Let's compare the execution speed (using a silly little benchmark) of these interpreters I've written (and a native scheme implementation). All run on Linux, JDK1.7.0_21 x64, Mono 2.10.8.1. Results in milliseconds.

| (fact 50)                                                          |        | 100x | 10000x |
|--------------------------------------------------------------------|--------|:----:|:------:|
| [Scala](https://github.com/martintrojer/scheme-scala)              | 2.10.1 | 580  | 58800  |
| [Clojure](https://github.com/martintrojer/scheme-clojure)          | 1.5.1  | 300  | 29700  |
| [F#](https://github.com/martintrojer/scheme-fsharp)                | 3.0    | 80   | 6600   |
| [Python](https://github.com/martintrojer/scheme-python)            | 2.7.4  | 420  | 40500  |
| [Chicken Scheme](http://www.call-cc.org/)                          | 4.8.0  | 4    | 150    |
| [Clojure embedded](https://github.com/martintrojer/scheme-clojure) | 1.5.1  | 1    | 40     |

I'm a bit surprised with the results here, Scala is quite slow and F# is very fast. If you consider that the F# and Scala implementations are fundamentally identical, my only conclusion can be that Scala pattern matching is slow. Daniel Spiewak alluded to this in a [recent talk](http://2013.flatmap.no/spiewak.html), if I understand him correctly, it is much faster (in Scala) to replace pattern matches with 'polymorphic operators' -- [here's an example](https://gist.github.com/martintrojer/5646283).

If you watch that talk, it boils down to different ways to tackle the expression problem, where pattern matches and 'polymorphic operators' are on different extremes on the spectrum. However, it doesn't explain why pattern matching in Scala is so much slower than F#.

If you are interested how these benchmarks were run, here's some [snippets](https://gist.github.com/martintrojer/5719803).
