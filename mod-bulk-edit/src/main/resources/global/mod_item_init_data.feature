Feature: init data for mod-users

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)' }
    * configure retry = { interval: 3000, count: 10 }

  Scenario: setup test data for invenory
    #setup address types
    * def instance = karate.read('classpath:samples/item/inventory_instance.json')
#    * def fun = function(i) { return { addressType: addressTypes[i]}; }
#    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-item-util.feature@PostInstance') instance

  Scenario: setup test data for holdings
    #setup address types
    * def holdings = karate.read('classpath:samples/item/holding_storage.json')
#    * def fun = function(i) { return { addressType: addressTypes[i]}; }
#    * def data = karate.repeat(2, fun)
    * call read('classpath:global/util/mod-item-util.feature@PostHoldings') holdings

  Scenario: setup test data for items
    #setup item types
    * def item = karate.read('classpath:samples/item/item_storage.json')
    * call read('classpath:global/util/mod-item-util.feature@PostItems') item

