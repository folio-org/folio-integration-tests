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

    Scenario: duplicate Instance,Holdings,Item creation
#     First Instance
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f"
      }
      """
      When method POST
      Then status 201
      * def instancelocation = responseHeaders['Location'][0]
      * def instanceId = instancelocation.substring(instancelocation.lastIndexOf('/') + 1)

#     Duplicate Instance
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f"
      }
      """
      When method POST
      Then status 201
      * def dupInstancelocation = responseHeaders['Location'][0]
      * def dupInstanceId = dupInstancelocation.substring(dupInstancelocation.lastIndexOf('/') + 1)
#     Both instances ids should not match
      * match dupInstanceId != instanceId

#     First Holdings
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "instanceId":"#(instanceId)",
        "permanentLocationId":"184aae84-a5bf-4c6a-85ba-4a7c73026cd5"
      }
      """
      When method POST
      Then status 201
      * def holdingsId = response.id
      * def hrId = response.hrid
#     Duplicate Holdings
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "instanceId":"#(instanceId)",
        "permanentLocationId":"184aae84-a5bf-4c6a-85ba-4a7c73026cd5"
      }
      """
      When method POST
      Then status 201
      * def dupHoldingsId = response.id
      * def dupHrId = response.hrid
#     Both Holdings ids & hrid's should not match
      * match dupHoldingsId != holdingsId
      * match dupHrId != hrId

#     First Item
      Given path 'inventory/items'
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"}
      }
      """
      When method POST
      Then status 201
      * def itemId = response.id
      * def itemHrId = response.hrid
#     Duplicate Item
      Given path 'inventory/items'
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"}
      }
      """
      When method POST
      Then status 201
      * def dupItemHrId = response.id
      * def dupItemHrId = response.hrid
#     Both Items id's & hrId's should not match
      * match dupItemHrId != itemId
      * match dupItemHrId != itemHrId

#     Deletion check
      * def expected_response = 'Cannot delete holdings_record.id = ' + holdingsId + ' because id is still referenced from table item.'
      Given path '/holdings-storage/holdings/' + holdingsId
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"}
      }
      """
      When method DELETE
      Then status 400
      * match expected_response == response

    Scenario: Preceding & Succeeding instance title creation
#     Preceding Instance
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f"
      }
      """
      When method POST
      Then status 201
      * def instancelocation = responseHeaders['Location'][0]
      * def instanceId = instancelocation.substring(instancelocation.lastIndexOf('/') + 1)
#     Instance
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"Test_Instance",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "precedingTitles":[{"precedingInstanceId":"#(instanceId)"}]
      }
      """
      When method POST
      Then status 201
      * def pInstancelocation = responseHeaders['Location'][0]
      * def pInstanceId = pInstancelocation.substring(pInstancelocation.lastIndexOf('/') + 1)

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.succeedingTitles[0].succeedingInstanceId == pInstanceId

      #     Instance
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"Test_Instance",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "succeedingTitles":[{"succeedingInstanceId":"#(instanceId)"}]
      }
      """
      When method POST
      Then status 201
      * def sInstancelocation = responseHeaders['Location'][0]
      * def sInstanceId = sInstancelocation.substring(sInstancelocation.lastIndexOf('/') + 1)

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.precedingTitles[0].precedingInstanceId == sInstanceId







