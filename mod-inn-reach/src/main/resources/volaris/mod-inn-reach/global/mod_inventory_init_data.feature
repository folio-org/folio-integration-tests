Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * print 'proxyCall', proxyCall
    * def user = proxyCall == false ? testUser : testUserEdge
    * print 'user', user
    * callonce login user
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)' }
    * configure retry = { interval: 3000, count: 10 }


  Scenario: setup test data for inventory
    #setup inventory
    * def instanceObj = karate.read(samplesPath + 'inventory/inventory_instance.json')
    * def fun = function(i) { karate.call(globalPath + 'mod-item-util.feature@PostInstance', { instance : instanceObj[i] }); }
    * def instance = karate.repeat(2, fun)

  Scenario: setup test data for holdings
    #setup holdings
    * def holdings_list = karate.read(samplesPath + 'holding/holding_storage.json')
    * def fun = function(i) { karate.call(globalPath + 'mod-item-util.feature@PostHoldings', { holdings: holdings_list[i] }); }
    * def holdings = karate.repeat(1, fun)

  Scenario: setup test data for items
    #setup item
    * def items = karate.read(samplesPath + 'item/item_storage.json')
    * def fun = function(i) { karate.call(globalPath + 'mod-item-util.feature@PostItems', { item: items[i] }); }
    * def item = karate.repeat(2, fun)

