---
layout: post
title: "Testing an API with Simulant"
description: ""
category: clojure
tags: [clojure]
---
{% include JB/setup %}

tl;dr I present a new [Simulant example project](https://github.com/martintrojer/simulant-bootstrap), testing a simple web API.

> All programs are simulation tested, atleast once.
> --- Stu Halloway

Simulating testing is an interesting field that has a lot going for it. While most web site/api developers write many tests at the unit level (an old Rails habit) testing and understanding a whole system is often not done. Most systems we build nowadays consists of many (mega/micro) services/databases glued together. Getting a deeper understanding on how a system actually works and being able to simulate production like scenarios is very useful.

While you can (quite easily) write some code that stress test your system, libraries like [simulant](https://github.com/Datomic/simulant)/[datomic](http://www.datomic.com) gives you much more. By recording all tests/configurations/results in a database and separating the concerns of running the simulation and asserting the results new opportunities arise.

The basic workflow is to create a schema for your test scenarios, code that populate that schema with tests given to configuration parameters (also in the db), then running the simulation on multiple threads/processes/machines, and finally running queries against the results and finding potential issues. If you work against a persistent database, you are building up a corpus of test data, that you can later go and mine for additional information that you didn't think of when you ran them. Lets say a new issue presents itself in production, now you can go back an check how a potential fix would behave in previous test runs.

## Testing a site

This brings us to simulant, which is a datomic schema and some code to run simulations. It was created by the datomic team. Simulant comes with a example project, which is quite meta since it's using datomic to test datomic, and quite hard to wrap your head around. Recently I wanted to try simulant on a system I was building. I'll post of some of my learnings here, and present a simplified example that is hopefully easier to relate to than the simulant example project. Basic datomic knowledge is required in order to follow along.

The example project I've set up on github consists of 2 sub projects; the [site](https://github.com/martintrojer/simulant-bootstrap/tree/master/site) and the [sim](https://github.com/martintrojer/simulant-bootstrap/tree/master/sim). The site is a very simple CRUD API for EDN data, which we will use simulant to test. Here is the routes;
<script src="https://gist.github.com/martintrojer/6657390.js?file=routes.clj"> </script>

You can put, get and delete data, and get a list of all live Ids.

## Hand-rolled simulations

Your first attempt to 'simulate' usage (or stress test) this api would probably be to just write some functions. Let's start there and then see how we can convert those functions into a simulant simulation.
<script src="https://gist.github.com/martintrojer/6657390.js?file=api-tester.clj"> </script>

This is straight forward code to post some data, make sure we get the same data back. We can then "stress" our API but running this in many simultaneous futures. So this tests the basic functionality, and we could add logging of the access times to see how our site behaves under load. How would we do this (and more) in simulant?

## Setting up our schema

It's helpful to familiarize yourself with the [Simulant schema](https://github.com/Datomic/simulant/wiki/Schema-diagram) first, and then think about what extra attributes you'll need. Lets start with the model of the simulation (all schemas below are abbreviated -- datomic schemas are very noisy);
<script src="https://gist.github.com/martintrojer/6657390.js?file=model.edn"> </script>

As you can see, the model contains basic configuration for a simulation. Next we define the type of tests (and agents running them);
<script src="https://gist.github.com/martintrojer/6657390.js?file=test.edn"> </script>

In this case we are going to test put/get/delete operations of the API. Finally some attributes used to store data used by the tests and agents;
<script src="https://gist.github.com/martintrojer/6657390.js?file=api-user-data.edn"> </script>

`:action/payload` is input to the `:action.type/get` tests, the rest of these attributes are outputs from the tests. For instance `:action/siteId` will be the id returned by a put action or the id picked (at random) by the get/delete actions. Please note that for the get/delete actions, these Ids can't be populated up-front (like the `:action/payload`) since we only know what they are after we have run put tests. The `:agent/siteIds` is also worth mentioning, this encapsulates the local state of an agent. As you can see the in the "raw" stress code above, the agent needs to remember which Ids it has created `my-ids`, so it can do get/delete tests.

We are exploiting the great flexibility of datomic schemas here, since we are extending the standard simulant schema with new attributes. Here's a pretty picture with what's added to the simulant schema (please compare this to the simulant standard schema);
<script src="https://gist.github.com/martintrojer/6657390.js?file=schema.org"> </script>

## Creating the test, agents and test data
In simulant, all data goes into the database, including the agents and the actions they should perform (and the data they should use). So before we run a simulation we need to create all that data and put it into the database.

First we create an instance of a test, which will hold the references to all the agents, and all the agents actions. A test also have references to all sims that has been run. This is handled by a multimethod in simulant, and if you follow the code below you can see the outline of how the test, agents and actions are created.
<script src="https://gist.github.com/martintrojer/6657390.js?file=create-test.clj"> </script>

Please note that the `create-test` and `create-api-users` functions also create transactions. More details in the [api_user_sim.clj](https://github.com/martintrojer/simulant-bootstrap/blob/master/sim/src/api_user_sim.clj) file.

## Performing actions

Once nice effect of keeping all the test data in a database is that the [code required to perform the actions](https://github.com/martintrojer/simulant-bootstrap/blob/master/sim/src/api_user_agent.clj) (in this case hitting the API) becomes trivial. The only caveat in this particular case is that the state of a particular agent (the Ids it has created in the API) is stored in the database, so it needs to look them up to perform the get and remote actions. While this is perhaps a little bit awkward it's also powerful, since we now have detailed record in datomic of what each agent did. This can be very useful in analysis we want to do further down the line.

Here's some code for the post and get actions, and a helper function `get-an-id` that given an action, get the siteId attributes associated with it's agent and picks one at random.
<script src="https://gist.github.com/martintrojer/6657390.js?file=api-user-agent.clj"> </script>

These functions are in turn called by another simulant multimethod (dispatched on the action type). This is the place from which the siteIds are added or retracted from the database. For instance the delete action, which adds the siteId picked by the agent (the ids used for the delete action against the API) for the action and removes the siteId for the agent (since it can no longer be picked in any subsequent action).
<script src="https://gist.github.com/martintrojer/6657390.js?file=delete-action.clj"> </script>

## Creating an instance of a simulation

Ok, we have now set up the schema, written code to create a test, agents and actions and finally written code perform these actions and record the results.

To set up an instance of a simulation, once again we are going to put data in the database to describe the it.
<script src="https://gist.github.com/martintrojer/6657390.js?file=create-sim-instance.clj"> </script>

The `sim/create-test` function triggers the multimethod with the same name mentioned above.

You might have notice that we're about to run a pretty long simulation, luckily simulant can run with a faster running clock. We can configure a clock multiplier with the `sim/create-fixed-clock` function.

## Running the simulation

The next step is to run the simulation instance we just created. Please note that we just run them, we are not asserting the results (yet).
<script src="https://gist.github.com/martintrojer/6657390.js?file=runs.clj"> </script>

Here we are kicking off the sim run (of several different threads) and waiting for them all to finish.

## Looking at the results

After a sim is run, we have a lot of (hopefully) useful data in our database. Now comes the payoff of all the setup described above, we can use all the power of datomic queries to look at this data and find potential issues. Here's a simple example (there are more in the example project) -- we want to make sure the payload we got back from the get actions are the same we sent in the put actions.
<script src="https://gist.github.com/martintrojer/6657390.js?file=payload-assert.clj"> </script>

## Conclusion and some perf considerations

This is pretty cool right? So is simulant the silver bullet for all system testing? Well no, it is certainly capable of replacing many system test frameworks, but for extreme use-cases some of the inherent limitations of datomic will become a problem. One of these limitations are write throughput. Datomic only have one write path (one transactor) and if you are thinking about replacing a hardcore stress testing environment using something like [Gatling](http://gatling-tool.org/) you might be out of luck.

However, it is not necessarily is huge problem, I see tools like simulant and gatling complementing each other, they solve different problems. Simulant is more about simulating real usage, run in 'moderate' pace collecting all kinds of system information, and later analyzing it.

Having said this, Datomic certainly have a bunch of options to improve its write throughput by using different database backends (like in-memory, dynamodb) -- some more expensive than others. One quite clever way is to run the simulation with against a in-memory database and then (as a batch job) dump all the data into another db-backed datomic instance.
