---
categories:
- clojure
date: "2013-07-05T00:00:00Z"
description: ""
tags:
- clojure
- datomic
title: Datomic Bootstrap
---

A simple SQL scenario;

<!--more-->

```clojure
(ns dbtest.h2
  (:use [korma.core]
        [korma.db])
  (:require [clojure.string :refer [lower-case upper-case]]))

(defdb korma-db (h2 {:db "h2test"
                 :naming {:keys lower-case
                          :fields upper-case}}))

;; --- schema creation ---

(exec-raw ["DROP TABLE IF EXISTS users"])
(exec-raw ["CREATE TABLE users (id INT PRIMARY KEY AUTO_INCREMENT NOT NULL, name VARCHAR, email VARCHAR, address VARCHAR)"])

(exec-raw ["DROP TABLE IF EXISTS items"])
(exec-raw ["CREATE TABLE items (id INT PRIMARY KEY AUTO_INCREMENT NOT NULL, name VARCHAR, price FLOAT)"])

(exec-raw ["DROP TABLE IF EXISTS orders"])
(exec-raw ["CREATE TABLE orders (id INT PRIMARY KEY AUTO_INCREMENT NOT NULL, items_id INT, users_id INT, date DATE, price FLOAT, FOREIGN KEY (items_id) REFERENCES items(id), FOREIGN KEY (users_id) REFERENCES users(id))"])

;; --- korma schema definition ---

(defentity orders
  (entity-fields :items_id :users_id :date :price))
(defentity users
  (entity-fields :name :email :address)
  (has-many orders))
(defentity items
  (entity-fields :name :price)
  (has-many orders))

;; --- inserts ---

(transaction
 (insert users (values {:name "kalle" :email "kalle@hotmail.com" :address "12 high street"}))
 (insert users (values {:name "olle" :email "olle@gmail.com" :address "132 in-the-sticks street"}))
 (insert users (values {:name "lisa" :email "lisa77@yahoo.com" :address "4 belgrave square"})))

(insert items (values {:name "Olympus OM-D" :price 523.32}))
(insert items (values {:name "Pana 20mm/1.7" :price 250}))
(insert items (values {:name "Oly 45mm/2.4" :price 261.2}))

(insert orders (values {:items_id 1 :users_id 1 :date (java.util.Date.) :price 510}))

;; --- queries ---

(select users
        (fields :name :email))

(select users
        (with orders))

(select items
        (with orders))
```

Translated to datomic;

```clojure
(ns dbtest.datomic
  (:require [datomic.api :as d]))

(def uri "datomic:mem://test")
(d/delete-database uri)
(d/create-database uri)
(def conn (d/connect uri))

(def urif "datomic:free://localhost:4334/test")
(d/delete-database urif)
(d/create-database urif)
(def connf (d/connect urif))

;; --- schema creation ---

(def schema
  [
   {:db/ident :user/name
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   {:db/ident :user/email
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   {:db/ident :user/address
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}

   {:db/ident :item/name
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   {:db/ident :item/price
    :db/valueType :db.type/double
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}

   {:db/ident :order/price
    :db/valueType :db.type/double
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   {:db/ident :order/date
    :db/valueType :db.type/instant
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   {:db/ident :order/user
    :db/valueType :db.type/ref
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   {:db/ident :order/item
    :db/valueType :db.type/ref
    :db/cardinality :db.cardinality/one
    :db/id #db/id [:db.part/db]
    :db.install/_attribute :db.part/db}
   ])

(d/transact conn schema)

;; --- inserts ---

(def data
  [
   {:db/id #db/id [:db.part/user -100]
    :user/name "kalle"
    :user/email "kalle@hotmail.com"
    :user/address "12 high street"}
   {:db/id #db/id [:db.part/user -101]
    :user/name "olle"
    :user/email "olle@gmail.com"
    :user/address "132 in-the-sticks street"}
   {:db/id #db/id [:db.part/user -102]
    :user/name "lisa"
    :user/email "lisa77@yahoo.com"
    :user/address "4 belgrave square"}

   {:db/id #db/id [:db.part/user -200]
    :item/name "Olympus OM-D"
    :item/price 523.32}
   {:db/id #db/id [:db.part/user -201]
    :item/name "Pana 20mm/1.7"
    :item/price 250.0}
   {:db/id #db/id [:db.part/user -202]
    :item/name "Oly 45mm/2.4"
    :item/price 261.2}

   {:db/id #db/id [:db.part/user -300]
    :order/price 510.0
    :order/date (java.util.Date.)
    :order/user #db/id [:db.part/user -100]
    :order/item #db/id [:db.part/user -200]}

   {:db/id #db/id [:db.part/user -301]
    :order/price 123.2
    :order/date (java.util.Date.)
    :order/user #db/id [:db.part/user -100]
    :order/item #db/id [:db.part/user -201]}

   ])

(d/transact conn data)

;; --- queries ---

(d/q '[:find ?n ?m
       :where
       [?e :user/name ?n]
       [?e :user/email ?m]]
     (d/db conn))

(group-by first
          (d/q '[:find ?n ?in ?op ?od
                 :where
                 [?e :user/name ?n]
                 [?e :user/address ?a]
                 [?oe :order/user ?e]
                 [?oe :order/item ?ie]
                 [?oe :order/price ?op]
                 [?oe :order/date ?od]
                 [?ie :item/name ?in]]
               (d/db conn)))

(group-by second
          (d/q '[:find ?n ?u ?p ?d
                 :where
                 [?e :item/name ?n]
                 [?oe :order/item ?e]
                 [?oe :order/user ?ue]
                 [?ue :user/name ?u]
                 [?oe :order/price ?p]
                 [?oe :order/date ?d]]
               (d/db conn)))
```
