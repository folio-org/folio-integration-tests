Feature: inventory

  Background:
    * url baseUrl
    * callonce login testUser
    * configure driver = { type: 'chrome', , executable: 'C:/Program Files/Google/Chrome/Application/chrome.exe'  }
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

    Scenario: duplicate Items creation

#     Instance
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

#     Holdings
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
#     If an item is associated with Holdings then holdings can't be deleted.
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
      * def precedingInstancelocation = responseHeaders['Location'][0]
      * def precedingInstanceId = precedingInstancelocation.substring(precedingInstancelocation.lastIndexOf('/') + 1)

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.succeedingTitles[0].succeedingInstanceId == precedingInstanceId

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
      * def succeedingInstancelocation = responseHeaders['Location'][0]
      * def succeedingInstanceId = succeedingInstancelocation.substring(succeedingInstancelocation.lastIndexOf('/') + 1)

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.precedingTitles[0].precedingInstanceId == succeedingInstanceId

    Scenario: Parent & Child instance creation
#     Instance
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

#     Parent Instance
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "childInstances":[{
        "subInstanceId":"#(instanceId)",
        "instanceRelationshipTypeId":"30773a27-b485-4dab-aeb6-b8c04fa3cb17"
        }]
      }
      """
      When method POST
      Then status 201
      * def parentInstancelocation = responseHeaders['Location'][0]
      * def parentInstanceId = parentInstancelocation.substring(parentInstancelocation.lastIndexOf('/') + 1)

#     ParentId should match
      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      * match response.parentInstances[0].superInstanceId == parentInstanceId
#     ChildId should match
      Given path 'inventory/instances/' + parentInstanceId
      When method GET
      Then status 200
      * match response.childInstances[0].subInstanceId == instanceId

    Scenario: Permanent & Temporary Location creation
#     Permanent Location
      Given path '/locations?limit=1000&query=cql.allRecords%3D1%20sortby%20name'
      And request
      """
      {
      "isActive":true,
      "institutionId":"40ee00ca-a518-4b49-be01-0638d0a4ac57",
      "campusId":"470ff1dd-937a-4195-bf9e-06bcfcd135df",
      "libraryId":"c2549bb4-19c7-4fcc-8b52-39e612fb7dbe",
      "servicePointIds":["3a40852d-49fd-4df2-a1f9-6e2641a6e91f"],
      "name":"Test-FOLIO","code":"123456",
      "discoveryDisplayName":"Test-Discovery",
      "details":{},
      "primaryServicePoint":"3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
      }
      """
      When method POST
      Then status 201
      * def permanentLocationId = response.id
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
#     Holding with above permanent location
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "instanceId":"#(instanceId)",
        "permanentLocationId":"#(permanentLocationId)"
      }
      """
      When method POST
      Then status 201
#     Holding with above permanent location as temporary location
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "instanceId":"#(instanceId)",
        "temporaryLocationId":"#(permanentLocationId)",
        "permanentLocationId":"#(permanentLocationId)"
      }
      """
      When method POST
      Then status 201
      * def holdingsId = response.id
#     Item with permanent location
      Given path 'inventory/items'
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"},
        "permanentLocation":{"id":"#(permanentLocationId)"}
      }
      """
      When method POST
      Then status 201
#     barcode should be unique
      * def expectedResponse = 'Barcode must be unique, 12345678 is already assigned to another item'
      Given path 'inventory/items'
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"},
        "barcode":"12345678"
      }
      """
      When method POST
      Then status 201

      Given path 'inventory/items'
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(holdingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"},
        "barcode":"12345678"
      }
      """
      When method POST
      Then status 400
      And match response == expectedResponse

    Scenario: Move of a Holdings & Items
#     Instance1
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance1",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f"
      }
      """
      When method POST
      Then status 201
      * def firstInstancelocation = responseHeaders['Location'][0]
      * def firstInstanceId = firstInstancelocation.substring(firstInstancelocation.lastIndexOf('/') + 1)

#     Instance2
      Given path 'inventory/instances'
      And request
      """
      {
        "source":"FOLIO",
        "title":"TestInstance2",
        "instanceTypeId":"6312d172-f0cf-40f6-b27d-9fa8feaf332f"
      }
      """
      When method POST
      Then status 201
      * def secondInstancelocation = responseHeaders['Location'][0]
      * def secondInstanceId = secondInstancelocation.substring(secondInstancelocation.lastIndexOf('/') + 1)
#     First Holding
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "instanceId":"#(secondInstanceId)",
        "permanentLocationId":"184aae84-a5bf-4c6a-85ba-4a7c73026cd5"
      }
      """
      When method POST
      Then status 201
      * def firstHoldingsId = response.id

#     Second Holdings
      Given path 'holdings-storage/holdings'
      And request
      """
      {
        "instanceId":"#(secondInstanceId)",
        "permanentLocationId":"184aae84-a5bf-4c6a-85ba-4a7c73026cd5"
      }
      """
      When method POST
      Then status 201
      * def secondHoldingsId = response.id

      Given path 'inventory/items'
      And request
      """
      {
        "status":{"name":"Available"},
        "holdingsRecordId":"#(firstHoldingsId)",
        "materialType":{"id":"d9acad2f-2aac-4b48-9097-e6ab85906b25"},
        "permanentLoanType":{"id":"2e48e713-17f3-4c13-a9f8-23845bb210a4"},
      }
      """
      When method POST
      Then status 201
      * def itemId = response.id

      Given path 'inventory/holdings/move'
      And request
      """
      {
      "toInstanceId":"#(firstInstanceId)",
      "holdingsRecordIds":["#(firstHoldingsId)"],
      }
      """
      When method POST
      Then status 200


      Given path 'inventory/items/move'
      And request
      """
      {
      "toHoldingsRecordId":"#(secondHoldingsId)",
      "itemIds":["#(itemId)"]
      }
      """
      When method POST
      Then status 200
