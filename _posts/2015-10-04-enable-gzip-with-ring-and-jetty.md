---
layout: post
title: "Enable gzip with Ring and Jetty"
description: ""
category: clojure
tags: [ring]
---
{% include JB/setup %}

<!--more-->

Use a newer version of Jetty

<script src="https://gist.github.com/841d6712a432380fe97c.js?file=project.clj"> </script>

Add a :configurator key to to jetty config

<script src="https://gist.github.com/841d6712a432380fe97c.js?file=app.clj"> </script>
