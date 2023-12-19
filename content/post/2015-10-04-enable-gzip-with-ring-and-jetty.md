---
categories:
- clojure
date: "2015-10-04T00:00:00Z"
description: ""
tags:
- ring
title: Enable gzip with Ring and Jetty
---
<!--more-->

Use a newer version of Jetty

{{< gist martintrojer 841d6712a432380fe97c project.clj >}}

Add a `:configurator` key to to jetty config

{{< gist martintrojer 841d6712a432380fe97c app.clj >}}
