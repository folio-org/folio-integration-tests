Feature: inventory

  Background:
    * url baseUrl
    * callonce login testUser
    * configure driver = { type: 'chrome', executable: 'C:/Program Files/Google/Chrome/Application/chrome.exe'}
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def utilsPath = 'classpath:prokopovych/mod-inventory/features/utils.feature'

    Scenario: new Instance, Holdings, Item creation
      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      * def instanceId = instance.id

      * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
      * def holdingsId = holdings.id

      * def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)' }

    Scenario: Holding deletion
#     Instance
      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      * def instanceId = instance.id

#     Holdings
      * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
      * def holdingsId = holdings.id
      * def hrId = holdings.hrid

#     Item
      * def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)' }

#     If an item is associated with Holdings then holdings can't be deleted.
      * def expected_response = 'Cannot delete holdings_record.id = ' + holdingsId + ' because id is still referenced from table item.'
      Given path '/holdings-storage/holdings/' + holdingsId
      When method DELETE
      Then status 400
      * match expected_response == response

    Scenario: Preceding & Succeeding instance title creation
#     Preceding Instance
      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      * def instanceId = instance.id

#     Instance with preceding title
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
      * def precedingInstanceLocation = responseHeaders['Location'][0]
      * def precedingInstanceId = precedingInstanceLocation.substring(precedingInstanceLocation.lastIndexOf('/') + 1)

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.succeedingTitles[0].succeedingInstanceId == precedingInstanceId

#     Instance with succeeding title
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
      * def succeedingInstanceLocation = responseHeaders['Location'][0]
      * def succeedingInstanceId = succeedingInstanceLocation.substring(succeedingInstanceLocation.lastIndexOf('/') + 1)

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.precedingTitles[0].precedingInstanceId == succeedingInstanceId

    Scenario: Parent & Child instance creation
#     Instance
      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      * def instanceId = instance.id

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

      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      * def instanceId = instance.id

#     Holdings with above permanent location
      * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)', permanentLocationId:'#(permanentLocationId)' }

#     Holdings with above permanent location as temporary location
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
      * def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)', permanentLocationId:'#(permanentLocationId)' }

    Scenario: Unique Item barcode creation

      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      * def instanceId = instance.id

      * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
      * def holdingsId = holdings.id

#     barcode should be unique
      * def expectedResponse = 'Barcode must be unique, 12345678 is already assigned to another item'
      * def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)', barcode:'12345678' }

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
#     first Instance
      * def firstInstance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance1' }
      * def firstInstanceId = firstInstance.id

      * def secondInstance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance2' }
      * def secondInstanceId = secondInstance.id

#     First Holdings
      * def firstHoldings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(secondInstanceId)' }
      * def firstHoldingsId = firstHoldings.id

#     Second Holdings
      * def secondHoldings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(secondInstanceId)' }
      * def secondHoldingsId = secondHoldings.id

      * def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(firstHoldingsId)' }
      * def itemsId = items.id

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
      "itemIds":["#(itemsId)"]
      }
      """
      When method POST
      Then status 200

    Scenario: Holdings & Item effective location
#     Instance
      * def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance2' }
      * def instanceId = instance.id

#     Holdings
      * def permanentLocationId = '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
      * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)', permanentLocationId:'#(permanentLocationId)' }
      * match holdings.effectiveLocationId == permanentLocationId
      * def holdingsId = holdings.id

#     Items
      * def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)', permanentLocationId:'#(permanentLocationId)' }
      * match items.effectiveLocationId == permanentLocationId

  Scenario: Holdings should have valid Instance HRID and
#     Instance
    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given path 'inventory/instances'
    When method GET
    Then status 200
    And def totalRecords = response.totalRecords

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    Then match response.hrid contains any 'in'
    Then match response.hrid contains any totalRecords.toString()

#     Holdings
    Given path 'holdings-storage/holdings'
    When method GET
    Then status 200
    And def totalHoldings = response.totalRecords

    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    Then match holdings.hrid contains 'ho'
    Then match holdings.hrid contains (totalHoldings + 1).toString()

