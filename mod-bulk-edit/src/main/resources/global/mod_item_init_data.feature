Feature: init data for mod-users

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)' }
    * configure retry = { interval: 3000, count: 10 }

  Scenario: setup test data for invenory
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

