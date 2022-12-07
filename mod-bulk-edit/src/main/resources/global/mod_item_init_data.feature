Feature: init data for mod-users

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)' }
    * configure retry = { interval: 3000, count: 10 }

  Scenario: setup service point test data
    * def servicePoint = karate.read('classpath:samples/item/service-point-cd3.json')
    * call read('classpath:global/util/mod-item-util.feature@PostServicePoint') servicePoint

  Scenario: setup institution test data
    * def institution = karate.read('classpath:samples/item/institution-ku.json')
    * call read('classpath:global/util/mod-item-util.feature@PostInstitution') institution

  Scenario: setup campus test data
    * def campus = karate.read('classpath:samples/item/campus-city.json')
    * call read('classpath:global/util/mod-item-util.feature@PostCampus') campus

  Scenario: setup library test data
    * def library = karate.read('classpath:samples/item/library-diku.json')
    * call read('classpath:global/util/mod-item-util.feature@PostLibrary') library

  Scenario: setup location test data
    * def location = karate.read('classpath:samples/item/location-main-library.json')
    * call read('classpath:global/util/mod-item-util.feature@PostLocation') location
    * def location = karate.read('classpath:samples/item/location-annex.json')
    * call read('classpath:global/util/mod-item-util.feature@PostLocation') location
    * def location = karate.read('classpath:samples/item/location-online.json')
    * call read('classpath:global/util/mod-item-util.feature@PostLocation') location

  Scenario: setup test data for instance
    #setup inventory
    * def instance = karate.read('classpath:samples/item/inventory_instance.json')
    * call read('classpath:global/util/mod-item-util.feature@PostInstance') instance

  Scenario: setup test data for holdings
    #setup holdings
    * def holdings_list = karate.read('classpath:samples/item/holding_storage.json')
    * def fun = function(i) { karate.call('classpath:global/util/mod-item-util.feature@PostHoldings', { holdings: holdings_list[i] }); }
    * def holdings = karate.repeat(2, fun)

  Scenario: setup test data for items
    #setup item
    * def items = karate.read('classpath:samples/item/item_storage.json')
    * def fun = function(i) { karate.call('classpath:global/util/mod-item-util.feature@PostItems', { item: items[i] }); }
    * def item = karate.repeat(14, fun)

