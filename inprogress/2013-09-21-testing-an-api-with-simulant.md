---
layout: post
title: "Testing an API with Simulant"
description: ""
category: clojure
tags: [clojure]
---
{% include JB/setup %}

> All programs are simulation tested, atleast once.
> --- Stu Halloway

Simulating testing is an interesting field that has a lot going for it. While most web site/api developers write many tests at the unit level (an old Rails habit) testing and understanding a whole system is often not done. Most systems we build nowadays consists of many (mega/micro) services/databases glued together. Getting a deeper understanding on how your system actually works and being able to simulate production like scenarios is very useful.

While you can (quite easily) write some code that stress test your system, libraries like simulant/datomic gives you much more. By recording all tests/configurations/results in a database and separating the concerns of running the simulation and asserting the results new opportunities arise.

The basic workflow is to create a schema for your test scenarios, code that populate that schema with tests given to configuration parameters (also in the db), the running the simulation on multiple threads/processes/machines, and finally running queries against the results and finding potential issues. If you work against a persistent database, you are building up a corpus of test data, that you can later go and mine for additional information that you didn't think of when you ran them. Lets say a new issue presents itself in production, now you can go back an check how a potential fix would behave in previous test runs.

## Testing a site

This brings us to simulant, which is a datomic schema and some code to run simulations. It was created by the datomic team, to test datomic. This is quite meta, since simulant exploits many datomic features. Simulant comes with a example project, which is just a meta 'using datomic to test datmoic', and quite hard to wrap your head around. Recently I wanted to try simulant on a system I was building. I'll post of some of my learnings here, and present an simplified example that is hopefully easier to relate to than the simulant example project. Basic datomic knowledge is required in order to follow along.

The example project I've set up on github consists of 2 sub projects; the site and the sim. The site is a very simple CRUD API for Edn data. This is the site we want to test. Here is the routes;
<script src="https://gist.github.com/martintrojer/6657390.js?file=routes.clj"> </script>

You can put, get and delete data, and get a list of all live Ids.

## Hand-rolled simulations

Your first attempt to 'simulate' usage (or stress test) this api would probably be to just write some functions. Let's start there and then see how we can convert those functions into a simulant simulation.
<script src="https://gist.github.com/martintrojer/6657390.js?file=api-tester.clj"> </script>

This is straight forward code to post some data, make sure we get the same data back. We can the "stress" our API but running this in many simultaneous futures. So this tests the basic functionality, and we could add logging of the access times to see how our site behaves under load.

## Setting up our schema

It's helpful to familiarize yourself with the Simulant schema first, and then think about what extra attributes you'll need. Lets start with the model of the simulation (abbreviated -- datomic schemas are very noisy);
<script src="https://gist.github.com/martintrojer/6657390.js?file=model.edn"> </script>

As you can see, the model contains basic configuration for a simulation. Next we define the type of tests (and agents running them);
<script src="https://gist.github.com/martintrojer/6657390.js?file=test.edn"> </script>

In this case we are going to test put/get/delete operations of the API. Finally some attributes used to store data used by the tests and agents;
<script src="https://gist.github.com/martintrojer/6657390.js?file=api-user-data.edn"> </script>

`:action/payload` is input to the `:action.type/get` tests, the rest of these attributes are outputs from the tests. For instance `:action/siteId` will be the id returned by a put action or the id picked (at random) by the get/delete actions. Please note that for the get/delete actions, these Ids can't be populated up-front (like the `:action/payload`) since we only know what they are after we have run put tests. The `:agent/siteIds` is also worth mentioning, this encapsulates the local state of an agent. As you can see the in the "raw" stress code above, the agent needs to remember which Ids it has created `my-ids`, so it can do get/delete tests.

We are exploiting the great flexibility of Datomic schemas here, you can extend the standard simulant schema as you wish. Here's a pretty picture with what's added to the simulant schema (please reference this to the simulant schema);
<script src="https://gist.github.com/martintrojer/6657390.js?file=schema.org"> </script>

## Creating the test, agents and test data

In simulant, all data goes into the database, including the agents and the actions they should perform (and the data they should use). So before we run a simulation we need to create all that data and put it into the database.


## The agents

## Perf

Gatlin
datomic write perf
