Feature: inventory sample

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: new Instance, Holdings, Item creation
    * def createInstanceRequest = read('samples/createInstance.json')
      Given path 'inventory/instances'
      And request createInstanceRequest
      When method POST
      Then status 201
      * def location = responseHeaders['Location'][0]
      * def instanceId = location.substring(location.lastIndexOf('/') + 1)

    * def createHoldingsRequest = read('samples/createHoldings.json')
      Given path 'holdings-storage/holdings'
      And request createHoldingsRequest
      When method POST
      Then status 201
      * def holdingsId = response.id

    * def createItemRequest = read('samples/createItem.json')
      Given path 'inventory/items'
      And request createItemRequest
      When method POST
      Then status 201
