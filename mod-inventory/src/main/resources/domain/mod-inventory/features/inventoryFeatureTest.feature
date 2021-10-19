Feature: inventory sample

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }


    Scenario: new Instance creation
    * def createInstanceRequest = read('samples/createInstance.json')
      Given path 'inventory/instances'
      And request createInstanceRequest
      When method POST
      Then status 201

    Scenario: new Holding creation inside Instance
    * def createHoldingRequest = read('samples/createHoldings.json')
      Given path 'holdings-storage/holdings'
      And request createHoldingRequest
      When method POST
      Then status 201
      And match $.instanceId == '3117b5cc-7e29-4636-ae39-6075addd479f'

    Scenario: new Item creation inside Holding
    * def createItemRequest = read('samples/createItem.json')
      Given path 'inventory/items'
      And request createItemRequest
      When method POST
      Then status 201
      And match $.holdingsRecordId == '830afa6d-1ed9-4f70-91d3-f42e0b85a611'












