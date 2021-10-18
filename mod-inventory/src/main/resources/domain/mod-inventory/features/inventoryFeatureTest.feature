Feature: inventory sample

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }


    Scenario: Instance creating Test
    * print 'Hello undefined'
    * def createInstanceRequest = read('samples/createInstance.json')
      Given path 'inventory/instances'
      And request createInstanceRequest
      When method POST
      Then status 201










