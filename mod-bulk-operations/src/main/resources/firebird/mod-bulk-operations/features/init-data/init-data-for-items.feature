Feature: init data for items

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testAdmin

  Scenario: setup service point test data
    * def servicePoint = karate.read('classpath:samples/items/service-point-cd3.json')
    * call read('init-data/mod-items-util.feature@PostServicePoint') servicePoint

  Scenario: setup institution test data
    * def institution = karate.read('classpath:samples/items/institution-ku.json')
    * call read('init-data/mod-items-util.feature@PostInstitution') institution

  Scenario: setup campus test data
    * def campus = karate.read('classpath:samples/items/campus-city.json')
    * call read('init-data/mod-items-util.feature@PostCampus') campus

  Scenario: setup library test data
    * def library = karate.read('classpath:samples/items/library-diku.json')
    * call read('init-data/mod-items-util.feature@PostLibrary') library

  Scenario: setup location test data
    * def location = karate.read('classpath:samples/items/location-main-library.json')
    * call read('init-data/mod-items-util.feature@PostLocation') location
    * def location = karate.read('classpath:samples/items/location-annex.json')
    * call read('init-data/mod-items-util.feature@PostLocation') location

  Scenario: setup test data for instance
    #setup instance
    * def instance = karate.read('classpath:samples/items/inventory-instance.json')
    * call read('init-data/mod-items-util.feature@PostInstance') instance

  Scenario: setup test data for holdings
    #setup holdings
    * def holdings = karate.read('classpath:samples/items/holding-storage.json')
    * call read('init-data/mod-items-util.feature@PostHoldings') holdings

  Scenario: setup test data for items
    #setup item
    * def item = karate.read('classpath:samples/items/item-storage.json')
    * call read('init-data/mod-items-util.feature@PostItems') item