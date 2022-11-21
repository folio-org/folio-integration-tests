Feature: inventory

  Background:
    * url baseUrl
    * callonce login testUser
    * configure driver = { type: 'chrome', executable: 'C:/Program Files/Google/Chrome/Application/chrome.exe'}
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def utilsPath = 'classpath:prokopovych/mod-inventory/features/utils.feature'

    Scenario: new Instance, Holdings, Item creation
      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      And def instanceId = instance.id

      Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
      And def holdingsId = holdings.id

      Given call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)' }

    Scenario: Holding deletion
#     Instance
      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      And def instanceId = instance.id

#     Holdings
      Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
      And def holdingsId = holdings.id
      And def hrId = holdings.hrid

#     Item
      Given call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)' }

#     If an item is associated with Holdings then holdings can't be deleted.
      * def expected_response = 'Cannot delete holdings_record.id = ' + holdingsId + ' because id is still referenced from table item.'
      Given path '/holdings-storage/holdings/' + holdingsId
      When method DELETE
      Then status 400
      * match expected_response == response

    Scenario: Preceding & Succeeding instance title creation
#     Preceding Instance
      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      And def instanceId = instance.id

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
      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      And def instanceId = instance.id

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
      Given path '/locations'
      And param limit = 1000
      And param query = 'cql.allRecords=1 sortby name'
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

      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      And def instanceId = instance.id

#     Holdings with above permanent location
      Given call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)', permanentLocationId:'#(permanentLocationId)' }

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
      Given call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)', permanentLocationId:'#(permanentLocationId)' }

    Scenario: Unique Item barcode creation
      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
      And def instanceId = instance.id

      Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
      And def holdingsId = holdings.id

#     barcode should be unique
      * def expectedResponse = 'Barcode must be unique, 12345678 is already assigned to another item'

      Given call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)', barcode:'12345678' }

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
      Given def firstInstance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance1' }
      And def firstInstanceId = firstInstance.id

      Given def secondInstance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance2' }
      And def secondInstanceId = secondInstance.id

#     First Holdings
      Given def firstHoldings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(secondInstanceId)' }
      And def firstHoldingsId = firstHoldings.id

#     Second Holdings
      Given def secondHoldings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(secondInstanceId)' }
      And def secondHoldingsId = secondHoldings.id

      Given def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(firstHoldingsId)' }
      And def itemsId = items.id

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
      Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance2' }
      Then def instanceId = instance.id

#     Holdings
      * def permanentLocationId = '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
      Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)', permanentLocationId:'#(permanentLocationId)' }
      Then match holdings.effectiveLocationId == permanentLocationId
      And def holdingsId = holdings.id

#     Items
      Given def items = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId)', permanentLocationId:'#(permanentLocationId)' }
      Then match items.effectiveLocationId == permanentLocationId
