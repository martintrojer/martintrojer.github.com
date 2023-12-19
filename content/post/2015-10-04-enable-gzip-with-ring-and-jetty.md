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

```clojure
(defproject smaller-resources "0.1.0-SNAPSHOT"
  :dependencies [
                 ;;; ...
                 [ring/ring-jetty-adapter "1.4.0" :exlcusions [org.eclipse.jetty/jetty-server]]
                 [org.eclipse.jetty/jetty-server "9.3.3.v20150827"]])
```

Add a `:configurator` key to to jetty config

```clojure
(ns http-server
  (:require [ring.adapter.jetty :as jetty])
  (:import [org.eclipse.jetty.server.handler.gzip GzipHandler]))

(defn- add-gzip-handler [server]
  (.setHandler server
               (doto (GzipHandler.)
                 (.setIncludedMimeTypes (into-array ["text/css"
                                                     "text/plain"
                                                     "text/javascript"
                                                     "application/javascript"
                                                     "application/json"
                                                     "image/svg+xml"]))
                 (.setMinGzipSize 1024)
                 (.setHandler (.getHandler server)))))

(defn start-server [app]
  (let [server (jetty/run-jetty
```
