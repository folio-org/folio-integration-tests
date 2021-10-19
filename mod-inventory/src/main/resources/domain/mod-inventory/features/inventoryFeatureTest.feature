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














