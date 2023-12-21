---
categories:
- clojure
date: "2014-10-18T00:00:00Z"
description: ""
tags:
- clojure
title: Kebab-case keywords in nested Clojure data structures
---

<!--more-->

```clojure
(ns kebab
  (:require [camel-snake-kebab :as kebab]
            [schema.coerce :as c]
            [schema.core :as s]))

(def Data (s/either s/Keyword
                    {(s/recursive #'Data) (s/recursive #'Data)}
                    [(s/recursive #'Data)]
                    #{(s/recursive #'Data)}
                    s/Any))

(def ->kebab-keys-coercer
  (c/coercer Data {s/Keyword (coerce/safe #(kebab/->kebab-case %))}))

(def ->snake-keys-coercer
  (c/coercer Data {s/Keyword (coerce/safe #(kebab/->snake_case %))}))



(->kebab-keys-coercer {[:f_o_o] :a_b :b_a_r {:b_a_z {:y_z #{'([:y_e_s])}}}})
;; => {[:f-o-o] :a-b :b-a-r {:b-a-z {:y-z #{[[:y-e-s]]}}}}
```
