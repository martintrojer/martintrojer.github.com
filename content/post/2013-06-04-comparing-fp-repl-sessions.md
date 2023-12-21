---
categories:
- fsharp
date: "2013-06-04T00:00:00Z"
description: ""
tags:
- scala
- clojure
- f#
title: Comparing FP REPL Sessions
---
{% include JB/setup %}

Functional programming is great; higher-order functions, closures, immutable data-structures, lazy sequences etc.

Most languages comes with a REPL (or 'interactive' prompt), where you can play with these features at your leisure. Dynamically typed languages are a bit more convenient in the REPL, but not by as much as you might think. Also, F# type providers closes the gap even further.

Here's a typical, hit-a-JSON-endpoint-and-look-at-the-data session in Clojure;

```clojure
$ lein repl

user=> (def res (slurp "http://www.bbc.co.uk/tv/programmes/genres/drama/scifiandfantasy/schedules/upcoming.json"))

user=> (require 'clojure.data.json 'clojure.walk)
user=> (def json (->> res clojure.data.json/read-str
                      clojure.walk/keywordize-keys))

user=> (->> json :broadcasts (filter #(>= (:duration %) 6300))
            (map :programme) (map (juxt :title :pid)))
(["Lady in the Water" "b00l5wdn"] ["Lady in the Water" "b00l5wdn"] ["Lady in the Water" "b00l5wdn"] ["Lady in the Water" "b00l5wdn"])
```

Nice, clean and very powerful, virtually zero ceremony. Doing the same in Scala, is just a little bit more awkward;

```scala
$ scala

scala> val res = scala.io.Source.fromURL("http://www.bbc.co.uk/tv/programmes/genres/drama/scifiandfantasy/schedules/upcoming.json").mkString
res: String = Option = "{ ... }"

scala> import scala.util.parsing.json._
scala> val json = JSON.parseFull(res)
json: Option[Any] = Some(Map( ... ))

scala> val broadcasts = json match { case Some(m: Map[String,List[Map[String,Any]]]) => m("broadcasts") }
// warnings...
broadcasts: List[Map[String,Any]] = List(Map( ... ))

scala> broadcasts filter (_("duration").asInstanceOf[Double] >= 6300 )
                  map (_("programme").asInstanceOf[Map[String,Any]])
                  map (m => (m("title"),m("pid")))
res47: List[(Any, Any)] = List((Lady in the Water,b00l5wdn), (Lady in the Water,b00l5wdn), (Lady in the Water,b00l5wdn), (Lady in the Water,b00l5wdn))
```

Similar to Clojure but a bit more ceremony and type annotations.

Now, can we get closer to the ease of dynamic languages while staying strongly typed? What if the types sprinkled evenly in the Scala example could be inferred? Enter F# type providers;

```fsharp
$ fsharpi

> #r "FSharp.Data.dll";;

> type Data = JsonProvider<"http://www.bbc.co.uk/tv/programmes/genres/drama/scifiandfantasy/schedules/upcoming.json">;;
type Data = JsonProvider<...>

> let json = Data.GetSample();;
val json : JsonProvider<...>.DomainTypes.Entity =
  {JsonValue = ... }

> json.Broadcasts |> Seq.filter (fun m -> m.Duration >= 6300)
                  |> Seq.map (fun m -> m.Programme)
                  |> Seq.map (fun m -> [ m.Title; m.Pid ]);;
val it : seq<string list> =
  seq [["b0015wdn"; "Lady in the Water"]; ["b0015wdn"; "Lady in the Water"]; ["b0015wdn"; "Lady in the Water"]]
```

There you have it; the simplicity and succinctness of a dynamic language plus type safety with inferred types. Please note that the correct types are inferred in the final result.
