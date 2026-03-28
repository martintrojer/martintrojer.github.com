---
categories:
- fsharp
date: "2011-11-02T00:00:00Z"
description: ""
tags:
- fsharp
- sicp
title: Scheming in F#
---

Given the fact that I worship at the [SICP](https://web.mit.edu/6.001/6.037/sicp.pdf) altar, it should come as no surprise that I follow the recipe outlined in chapter 4 of said book; implementing a [Scheme](http://en.wikipedia.org/wiki/Scheme_(programming_language)) interpreter in every language I am trying to learn. Over the years it has turned out to be a very useful exercise, since the problem is just "big enough" to force me to drill into what the languages have to offer.

I'll post the source of the interpreters on [github](https://github.com/martintrojer/) in this and future posts and highlight some of my findings in more detail in the posts. I am not going to write and explain too much about the languages themselves, there are plenty of books and tutorials for that purpose, just highlights :)

F# is part of the [ML](http://en.wikipedia.org/wiki/ML_(programming_language)) family and largely compatible with OCaml. It's one of the new hybrid functional / OO languages (like Scala, Clojure etc) that the kids are raving about these days. This means it can expose and interact with .NET libraries and objets code seamlessly. It also have a whole host of other functionality like active patterns, asynchronous workflows and (soon) type providers that I will get back to in future posts.

Let's start with discriminated unions which is a very powerful way of concisely describing (in this case) the syntax of the language;

```fsharp
type Expression =
| NullExpr
| Combination of Expression list
| List of ListType list
| Function of ListType list * Expression list
...
```

This is means what it reads, "a scheme expression is either empty or a list of expressions or a list of listtypes or ...". It really can't be any clearer than that now can it?

ML's pattern matching is just fantastic when writing parsers, well any code really. This is how the evaluator of Expressions look like;

```fsharp
let rec eval (env:Map<string,expression> list) expr =
  match expr with
  | NullExpr              ->  failwith "invalid interpreter state"
  | Combination([])       ->  failwith "invalid combination"
  | Combination(h::t)     ->
     match eval env h with
     | (nenv, Procedure(f))          -> apply f t env
     | (nenv, Function(args, code))  ->
        let newenv =
           try List.fold2 bindArg (expandEnv nenv) args t
           with ex -> failwith "invalid number of arguments"
        evalExprs newenv code
     | (nenv, expr)                  -> (nenv, expr)
  | Procedure(f)          -> (env, Procedure(f))
  | Function(args, code)  -> failwith "invalid function call"
  | Value(v)              -> (env, Value(v))
  | List(v)               -> (env, List(v))
  | Symbol(s)             ->
     match lookup env s with
     | Some(e)   -> (env, e)
     | None      -> failwith (sprintf "unbound symbol '%A'" s)

and apply f args env = f env args
```

This is the famous recursive eval/appy loop as described in SICP. Of all the languages I've written this in, nothing is as concise and readable as ML. The main match statement is basically a switch, but there are a few subtleties here. For instance the Combination matches have a nested pattern separating the empty (\[\]) case and list (head::tail) case.

The interactive Read-Eval-Print-Loop (REPL) also deserves a shout out, this is using the F# pipe operator that passes the result of a function to the (last) parameter of another.

```fsharp
let rec commandLoop (env, res) =
   match res with
   | Value(Number(v))  -> printfn "%4.2f\n> " v
   | Value(Name(v))    -> printfn "%s\n> " v
   | Value(Boolean(v)) -> printfn "%b\n> " v
   | List(l)           -> printfn "%s" (listToStr l)
   | _                 -> printfn "null\n> "
   try Console.ReadLine()
      |> List.ofSeq
      |> parse
      |> List.head
      |> (eval env)
      |> commandLoop
   with ex -> commandLoop (env, Value(Name(ex.Message)))
```

So that try/catch is basically saying;

1. read a line from the console
2. convert it to a list
3. parse that list
4. take the head (first element) of the list (this is the expression)
5. evaluate it
6. call itself recursively

Please note that the new environment map is passed as parameter in the loop, meaning it can be immutable!

All the code can be found [here](https://github.com/martintrojer/scheme-fsharp), there are few bugs (see failing tests) that I might fix later, or maybe you are up for it! :)

```
mtscheme v0.1
null
> (define (factorial x) (if (= x 0) 1 (* x (factorial (- x 1)))))
null
> (factorial 9)
362880.00
>
```
