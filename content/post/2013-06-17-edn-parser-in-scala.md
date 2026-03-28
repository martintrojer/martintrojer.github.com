---
categories:
- scala
date: "2013-06-17T00:00:00Z"
description: ""
tags:
- scala
title: EDN Parser in Scala
---

Taken from [edn-scala](https://github.com/martintrojer/edn-scala)

<!--more-->

```scala
// EDN-ish parser
// https://github.com/edn-format/edn

import scala.util.parsing.combinator._
import java.util.UUID
import java.text.DateFormat

class EDN extends JavaTokenParsers {
  val set: Parser[Set[Any]] = "#{" ~> rep(elem) <~ "}" ^^ (Set() ++ _)
  val map: Parser[Map[Any, Any]] = "{" ~> rep(pair) <~ "}" ^^ (Map() ++ _)
  val vector: Parser[Vector[Any]] = "[" ~> rep(elem) <~ "]" ^^ (Vector() ++ _)
  val list: Parser[List[Any]] = "(" ~> rep(elem) <~ ")"
  val keyword: Parser[String] = """:[^,#\{\}\[\]\s]+""".r
  lazy val pair: Parser[(Any, Any)] = elem ~ elem ^^ {
    case key ~ value => (key, value)
  }
  lazy val tagElem: Parser[Any] = """#[^,#\{\}\[\]\s]+""".r ~ elem ^^ {
    case "#uuid" ~ (value: String) => UUID.fromString(value.tail.init)
    case "#inst" ~ (value: String) => DateFormat.getDateInstance(DateFormat.SHORT)
                                     .parse(value.tail.init)
    case name ~ value => (name, value)
  }
  val ednElem: Parser[Any] =  set | map | vector | list | keyword | tagElem |
                              floatingPointNumber ^^ (_.toDouble) |
                              "nil"               ^^ (_ => null)  |
                              "true"              ^^ (_ => true)  |
                              "false"             ^^ (_ => false) |
                              stringLiteral
  val elem: Parser[Any] = ednElem | "," ~> elem
 }
```
