Feature: Print events tests - extended

  Background:
    * url baseUrl
    * configure headers = null
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)','Accept': '*/*' }
    * configure headers = headersUser
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * def servicePointId = call uuid1
    * def groupId = call uuid1
    * def instanceId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def cancellationReasonId = call uuid1
    * def printEventDate = "2024-06-25T20:00:00+05:30"
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(servicePointId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(locationId), extServicePointId: #(servicePointId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingId), extInstanceId: #(instanceId) }

  @C784480
  Scenario: Requests can be exported to CSV if user last printed request was deleted
    * def extMaterialTypeId = call uuid1
    * def extItemId = call uuid1
    * def extUser1Id = call uuid1
    * def extUser2Id = call uuid1
    * def requestId = call uuid1
    * def settingId = call uuid1
    * def extServicePointId = call uuid1
    * def extLocationId = call uuid1
    * def extHoldingId = call uuid1
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()

    # set up dedicated service point, location and holdings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId) }

    # post material type and item
    * def extMaterialTypeName = 'print-deleted-user-type-' + java.util.UUID.randomUUID()
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: '#(extMaterialTypeName)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: 'FAT-1305IBC', extStatusName: 'Available', extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingId) }

    # create User 1 (requester)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUser1Id), extUserBarcode: 'FAT-1305UBC', extGroupId: #(fourthUserGroupId) }

    # enable print event log feature (precondition step 1)
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = settingId
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    Given path 'circulation', 'settings'
    And request circulationSettingRequest
    When method POST
    Then status 201

    # create a Page request for User 1 (precondition step 2)
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requesterId = extUser1Id
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = extHoldingId
    * requestEntityRequest.requestLevel = 'Item'
    * requestEntityRequest.pickupServicePointId = extServicePointId
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # Verify pick slip is generated at the correct service point
    Given path 'circulation', 'pick-slips', extServicePointId
    When method GET
    Then status 200
    And match $.pickSlips[0].request.requestID == requestId

    # create User 2 (the printer, precondition step 3)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUser2Id), extUserBarcode: 'FAT-1306UBC', extGroupId: #(fourthUserGroupId), firstName: 'PrinterUser' }

    # User 2 prints pick slip for the request (precondition step 3)
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = [requestId]
    * printEventsRequest.requesterId = extUser2Id
    * printEventsRequest.requesterName = 'PrinterUser'
    * printEventsRequest.printEventDate = '2024-08-06T14:10:00.000+00:00'
    Given path 'circulation', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 204

    # delete User 2 (precondition step 4)
    Given path 'users', extUser2Id
    When method DELETE
    Then status 204

    # Step 1: Page request is present in results, only print date is shown (no user name)
    Given path 'circulation', 'requests'
    And param query = 'id==' + requestId
    When method GET
    Then status 200
    And match response.requests[0].id == requestId
    And match response.requests[0].requestType == 'Page'
    And match response.requests[0].printDetails.printCount == 1
    And match response.requests[0].printDetails.printEventDate == '#present'
    And match response.requests[0].printDetails.lastPrintRequester == '#notpresent'

    # Steps 3/4: Export search results (CSV) — GET /circulation/requests succeeds with print date only
    Given path 'circulation', 'requests'
    And param query = 'id==' + requestId
    And param limit = 100
    When method GET
    Then status 200
    And assert response.totalRecords >= 1
    And match response.requests[0].printDetails.printCount == 1
    And match response.requests[0].printDetails.printEventDate == '#present'
    And match response.requests[0].printDetails.lastPrintRequester == '#notpresent'

    # cleanup circulation setting
    Given path 'circulation/' + 'settings/' + settingId
    When method DELETE
    Then status 204

    * def extMaterialTypeName = null

