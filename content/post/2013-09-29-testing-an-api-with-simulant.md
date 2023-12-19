---
categories:
- clojure
date: "2013-09-29T00:00:00Z"
description: ""
tags:
- clojure
title: Testing an API with Simulant
---

tl;dr I present a new [Simulant example project](https://github.com/martintrojer/simulant-bootstrap), testing a simple web API.

> All programs are simulation tested, atleast once.
> --- Stu Halloway

Simulating testing is an interesting field that has a lot going for it. While most web site/api developers write many tests at the unit level (an old Rails habit) testing and understanding a whole system is often not done. Most systems we build nowadays consists of many (mega/micro) services/databases glued together. Getting a deeper understanding on how a system actually works and being able to simulate production like scenarios is very useful.

While you can (quite easily) write some code that stress test your system, libraries like [simulant](https://github.com/Datomic/simulant)/[datomic](http://www.datomic.com) gives you much more. By recording all tests/configurations/results in a database and separating the concerns of running the simulation and asserting the results new opportunities arise.

The basic workflow is to create a schema for your test scenarios, code that populate that schema with tests given to configuration parameters (also in the db), then running the simulation on multiple threads/processes/machines, and finally running queries against the results and finding potential issues. If you work against a persistent database, you are building up a corpus of test data, that you can later go and mine for additional information that you didn't think of when you ran them. Lets say a new issue presents itself in production, now you can go back an check how a potential fix would behave in previous test runs.

## Testing a site

This brings us to simulant, which is a datomic schema and some code to run simulations. It was created by the datomic team. Simulant comes with a example project, which is quite meta since it's using datomic to test datomic, and quite hard to wrap your head around. Recently I wanted to try simulant on a system I was building. I'll post of some of my learnings here, and present a simplified example that is hopefully easier to relate to than the simulant example project. Basic datomic knowledge is required in order to follow along.

The example project I've set up on github consists of 2 sub projects; the [site](https://github.com/martintrojer/simulant-bootstrap/tree/master/site) and the [sim](https://github.com/martintrojer/simulant-bootstrap/tree/master/sim). The site is a very simple CRUD API for EDN data, which we will use simulant to test. Here is the routes;

```clojure
(defroutes app-routes
  (GET "/" [] (generate-response :ok))
  (GET "/liveids" [] (generate-response (live-ids)))
  (GET "/data" {params :params} (get-data params))
  (PUT "/data" {params :params} (store-data params))
  (DELETE "/data" {params :params} (remove-data params))
  (route/not-found (generate-response :not-found)))
```

You can put, get and delete data, and get a list of all live Ids.

## Hand-rolled simulations

Your first attempt to 'simulate' usage (or stress test) this api would probably be to just write some functions. Let's start there and then see how we can convert those functions into a simulant simulation.

```clojure

(def url "http://localhost:3000/data")

(defn post-some-data [test]
  (let [data (zipmap (clojure.data.generators/vec clojure.data.generators/scalar)
                     (clojure.data.generators/vec clojure.data.generators/scalar))]
    [(clj-http.client/put url {:body (pr-str data) :content-type :edn :throw-entire-message? true})
     data]))

(defn get-data [id]
  (update-in
   (clj-http.client/get url {:query-params {:id id}})
   [:body] read-string))

(defn post-and-get-data [my-ids]
  (let [[{:keys [body status]} data] (post-some-data test)
        id (-> body read-string :id)
        {:keys [body]} (get-data id)]
    (when-not (= (:body data) (:body body))
      (log/error "Data mismatch!"))
    (conj my-ids id)))

(defn run-some-tests [cnt]
  (loop [ctr cnt, my-ids #{}]
    (when-not (zero? ctr)
      (recur
       (dec ctr)
       (post-and-get-data remove-data my-ids)))))

(defn test-site
  (dotimes [_ 10]
    (future run-some-tests)))
```

This is straight forward code to post some data, make sure we get the same data back. We can then "stress" our API but running this in many simultaneous futures. So this tests the basic functionality, and we could add logging of the access times to see how our site behaves under load. How would we do this (and more) in simulant?

## Setting up our schema

It's helpful to familiarize yourself with the [Simulant schema](https://github.com/Datomic/simulant/wiki/Schema-diagram) first, and then think about what extra attributes you'll need. Lets start with the model of the simulation (all schemas below are abbreviated -- datomic schemas are very noisy);

```clojure
[[;; We are modelling site usage simulation
   {:db/ident :model.type/siteUsage}
   ;; Configuration parameters for the model
   {:db/ident :model/userCount
    :db/doc "Number of API users"}
   {:db/ident :model/meanPayloadSize
    :db/doc "Mean size of payload (geometric distribution)."}
   {:db/ident :model/meanSecsBetweenHits
    :db/doc "Mean time between api hits in seconds (geometric distribution)"}]]
```

As you can see, the model contains basic configuration for a simulation. Next we define the type of tests (and agents running them);

```clojure
[[ ;; One type of test
   {:db/ident :test.type/putGetDelte}
   ;; One type of agent (simulating a user)
   {:db/ident :agent.type/apiUser}
   ;; Three type of actions
   {:db/ident :action.type/put}
   {:db/ident :action.type/get}
   {:db/ident :action.type/delete}]]
```

In this case we are going to test put/get/delete operations of the API. Finally some attributes used to store data used by the tests and agents;

```clojure
[[;; The set of Ids a agent have gotten back from the site
   {:db/ident :agent/siteIds
    :db/cardinality :db.cardinality/many}
   ;; The payload to be sent TO the site in a put action
   {:db/ident :action/payload}
   ;; The payload returned FROM the site in a get action
   {:db/ident :action/sitePayload}
   ;; The Id returned FROM the site in a put action, and send TO the site
   ;; in a get/delete action
   {:db/ident :action/siteId}]]
```

`:action/payload` is input to the `:action.type/get` tests, the rest of these attributes are outputs from the tests. For instance `:action/siteId` will be the id returned by a put action or the id picked (at random) by the get/delete actions. Please note that for the get/delete actions, these Ids can't be populated up-front (like the `:action/payload`) since we only know what they are after we have run put tests. The `:agent/siteIds` is also worth mentioning, this encapsulates the local state of an agent. As you can see the in the "raw" stress code above, the agent needs to remember which Ids it has created `my-ids`, so it can do get/delete tests.

We are exploiting the great flexibility of datomic schemas here, since we are extending the standard simulant schema with new attributes. Here's a pretty picture with what's added to the simulant schema (please compare this to the simulant standard schema);

```
 ;; +-------------------+
 ;; | agent             |*----- 1 to N ---+
 ;; +-------------------+                 |
 ;; | actions           |                \|/
 ;; | type              |           +--------------------+
 ;; | errorDescription  |           | action             |
 ;; +-------------------+           +--------------------+
 ;; | siteIds           |           | atTime             |
 ;; +-------------------+           | type               |
 ;;                                 +--------------------+
 ;;                                 | payload            |
 ;;                                 | sitePayload        |
 ;;                                 | siteId             |
 ;;                                 +--------------------+
```

## Creating the test, agents and test data
In simulant, all data goes into the database, including the agents and the actions they should perform (and the data they should use). So before we run a simulation we need to create all that data and put it into the database.

First we create an instance of a test, which will hold the references to all the agents, and all the agents actions. A test also have references to all sims that has been run. This is handled by a multimethod in simulant, and if you follow the code below you can see the outline of how the test, agents and actions are created.

```clojure
(defmethod sim/create-test :model.type/siteUsage
  [conn model test]
  (let [test (create-test conn model test)
        api-users (create-api-users conn test)]
    (util/transact-batch conn (mapcat #(generate-api-user-usage test %) api-users) 1000)
    (d/entity (d/db conn) (util/e test))))
```

Please note that the `create-test` and `create-api-users` functions also create transactions. More details in the [api_user_sim.clj](https://github.com/martintrojer/simulant-bootstrap/blob/master/sim/src/api_user_sim.clj) file.

## Performing actions

Once nice effect of keeping all the test data in a database is that the [code required to perform the actions](https://github.com/martintrojer/simulant-bootstrap/blob/master/sim/src/api_user_agent.clj) (in this case hitting the API) becomes trivial. The only caveat in this particular case is that the state of a particular agent (the Ids it has created in the API) is stored in the database, so it needs to look them up to perform the get and delete actions. While this is perhaps a little bit awkward it's also powerful, since we now have detailed record in datomic of what each agent did. This can be very useful in analysis we want to do further down the line.

Here's some code for the post and get actions, and a helper function `get-an-id` that given an action, get the siteId attributes associated with it's agent and picks one at random.

```clojure
(defn- get-an-id [action]
  (let [latest-action (d/entity (d/db db/sim-conn) (:db/id action))]
    (-> latest-action :agent/_actions first :agent/siteIds seq rand-nth)))

(defn post-some-data [action]
  (let [{:keys [body status]} (post-data (:action/payload action))]
    (-> body read-string :id)))

(defn get-some-data [action]
  (when-let [id (get-an-id action)]
    [id (get-data id)]))
```

These functions are in turn called by another simulant multimethod (dispatched on the action type). This is the place from which the siteIds are added or retracted from the database. For instance the delete action, which adds the siteId picked by the agent (the ids used for the delete action against the API) for the action and removes the siteId for the agent (since it can no longer be picked in any subsequent action).

```clojure
(defmethod sim/perform-action :action.type/delete
  [action process]
  (let [site-id (do-action action process remove-some-data)
        agents (-> action :agent/_actions)]
    (when site-id
      @(d/transact db/sim-conn [[:db/add (:db/id action) :action/siteId site-id]
                                [:db/retract (:db/id (first agents)) :agent/siteIds site-id]]))))
```

## Creating an instance of a simulation

Ok, we have now set up the schema, written code to create a test, agents and actions and finally written code perform these actions and record the results.

To set up an instance of a simulation, once again we are going to put data in the database to describe the it.

```clojure

(def site-user-model-data
  [{:db/id model-id
    :model/type :model.type/siteUsage
    :model/userCount 100
    :model/meanPayloadSize 2
    :model/meanSecsBetweenHits 10}])

(def site-user-model
  (-> @(d/transact db/sim-conn site-user-model-data)
      (util/tx-ent model-id)))

;; activity for this sim
(def site-usage-test
  (sim/create-test db/sim-conn site-user-model
                   {:db/id (d/tempid :test)
                    :test/duration (util/hours->msec 1)
                    }))

;; sim
(def site-usage-sim
  (sim/create-sim db/sim-conn site-usage-test {:db/id (d/tempid :sim)
                                               :sim/processCount 10}))
```

The `sim/create-test` function triggers the multimethod with the same name mentioned above.

You might have notice that we're about to run a pretty long simulation, luckily simulant can run with a faster running clock. We can configure a clock multiplier with the `sim/create-fixed-clock` function.

## Running the simulation

The next step is to run the simulation instance we just created. Please note that we just run them, we are not asserting the results (yet).

```clojure
(def pruns
  (->> #(sim/run-sim-process db/sim-uri (:db/id site-usage-sim))
       (repeatedly (:sim/processCount site-usage-sim))
       (into [])))

;; wait for sim to finish
(time
 (mapv (fn [prun] @(:runner prun)) pruns))
```

Here we are kicking off the sim run (of several different threads) and waiting for them all to finish.

## Looking at the results

After a sim is run, we have a lot of (hopefully) useful data in our database. Now comes the payoff of all the setup described above, we can use all the power of datomic queries to look at this data and find potential issues. Here's a simple example (there are more in the example project) -- we want to make sure the payload we got back from the get actions are the same we sent in the put actions.

```clojure
(defn- get-payload-map [action-type payload-attribute]
  (->> (d/q '[:find ?id ?payload
              :in $ ?action-type ?payload-attribute
              :where
              [?e :action/type ?action-type]
              [?e :action/siteId ?id]
              [?e ?payload-attribute ?payload]]
            simdb action-type payload-attribute)
       (map (fn [[id payload]] [id (read-string payload)]))
       (into {})))

(let [posted-payloads (get-payload-map :action.type/put :action/payload)
      received-payloads (get-payload-map :action.type/get :action/sitePayload)]
  (doseq [[id payload] received-payloads]
    (assert (= payload (posted-payloads id)))))
```

Please note that this query extracts the payloads from all simulations (in case you've run more than one). Once again, have a look at the example project for how to restrict your queries to a single sim.

## Conclusion and some perf considerations

This is pretty cool right? So is simulant the silver bullet for all system testing? Well no, it is certainly capable of replacing many system test frameworks, but for extreme use-cases some of the inherent limitations of datomic will become a problem. One of these limitations are write throughput. Datomic only have one write path (one transactor) and if you are thinking about replacing a hardcore stress testing environment using something like [Gatling](http://gatling-tool.org/) you might be out of luck.

However, it is not necessarily is huge problem, I see tools like simulant and gatling complementing each other, they solve different problems. Simulant is more about simulating real usage, run in 'moderate' pace collecting all kinds of system information, and later analyzing it.

Having said this, Datomic certainly have a bunch of options to improve its write throughput by using different database backends (like in-memory, dynamodb) -- some more expensive than others. One quite clever way is to run the simulation with against a in-memory database and then (as a batch job) dump all the data into another db-backed datomic instance.
