---
layout: post
title: "Datomic Do's and Don'ts"
description: ""
category: clojure
tags: [clojure, datomic]
---
{% include JB/setup %}

I recently tried to use Datomic in anger in a project, here are some things I learned.

<!--more-->

# Do

#### Keep metrics on your query times

Datomic lacks query planning. Queries that look harmless can be real hogs. The solution is usually blindly swapping lines in your query until you get an order of magnitude speedup.

#### Always use memcached with Datomic

When new peers connect, a fair bit of data needs to be transferred to them. If you don't use memcached this data needs to be queried from the store and will slow down the 'peer connect time' (among other things).

#### Give your peers nodes plenty of heap

To fully benefit from Datomic you want to have plenty of heap for the peers to cache data.

#### Datomic was designed with AWS/Dynamo in mind, use it

It will perform best with this backend, its also the most used (and thus most polished).

#### Do your `project.clj` chores

Datomic brings in lots of maven dependencies. Make sure you don't suffer from clashes, spend time solving the '`:exclusions` puzzle'.

#### Prefer dropping databases to excising data

If you want to keep logs, or other data with short lifespan in Datomic, put them in a different database and rotate the databases on a daily / weekly basis.

#### Use migrators for your attributes, and consider squashing unused attributes before going to prod

Don't be afraid to rev the schemas, you will end up with quite a few unused attributes. It's OK, but squash them before its too late.

#### Trigger transactor GCs periodically when load is low

If you are churning many datoms, the transactor is going have to GC. When this happens writes will be very slow.

#### Consider introducing a Datomic/peer tier in your infrastructure

Since Datomic's licensing is peer-count limited, you might have to start putting your precious peers together in a Datomic-tier which the webserver nodes (etc) queries via the Datomic REST API.

# Don't

#### Don't put big strings into Datomic

If your strings are bigger than 1kb put them somewhere else (and keep a link to them in Datomic). Datomic's storage model is optimized for small datoms, so if you put big stuff in there perf will drop dramatically.

#### Don't load huge datasets into Datomic

It will take forever, with plenty transactor GCs. If you are using Dynamo, keep an eye on the write throughput since it might bankrupt you. Also, there is a limit to the number of datoms Datomic can handle.

#### Don't auto-scale nodes with Datomic peers

Datomic's licensing is peer-count limited. If you have a peer on your webserver node you have to be very careful with your auto-scale settings. See above for a potential solution.

#### Don't use Datomic for stuff it wasn't intended to do

Don't run your geospatial queries or query-with-aggregations in Datomic, it's OK to have multiple datastores in your system.

#### Don't run Datomic on a SQL backend if you want perf

The transactor (writes) and peers (reads) are competing for the same resource. This is no different from having many services using the same SQL store. See AWS/Dynamo notes above.

#### Don't read the license text

[dpp](http://blog.goodstuff.im/datomic_license)
