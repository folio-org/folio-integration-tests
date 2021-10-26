Feature: inventory sample

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    Scenario: new Instance, Holdings, Item creation
      * def testInstanceId = callonce uuid
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance",
        "id":"#(testInstanceId)",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f"
      }
      """
      When method POST
      Then status 201
      * def location = responseHeaders['Location'][0]
      * def instanceId = location.substring(location.lastIndexOf('/') + 1)

      * def testHoldingsId = callonce uuid
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "id":"#(testHoldingsId)",
        "instanceId":"#(instanceId)",
        "permanentLocationId":"184aae84-a5bf-4c6a-85ba-4a7c73026cd5"
      }
      """
      When method POST
      Then status 201
      * def holdingsId = response.id

      * def testItemId = callonce uuid
      Given path 'inventory/items'
      And request
      """
      {
        "id":"#(testItemId)",
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"}
      }
      """
      When method POST
      Then status 201
