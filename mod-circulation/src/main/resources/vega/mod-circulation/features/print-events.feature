Feature: Print events tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
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
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(servicePointId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')

  Scenario: Save a print events log with invalid request data[EMPTY_REQUEST_LIST]

    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = []
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    Given path 'circulation', 'print-events-entry'
    When method POST
    Then status 422
    And match $.errors[0].message == 'Print Event Request  JSON is invalid'

  Scenario: Save a print events with invalid request data[NULL_VALUE]

    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
    * printEventsRequest.requesterId = null
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    Given path 'circulation', 'print-events-entry'
    When method POST
    Then status 422
    And match $.errors[0].message == 'Print Event Request  JSON is invalid'

  Scenario: Save a print events log when no circulation setting found

    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    Given path 'circulation', 'print-events-entry'
    When method POST
    Then status 422
    And match $.errors[0].message == 'No configuration found for print event feature'

  Scenario: Save a print event log

    * def extMaterialTypeId = call uuid1
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: 'test1' }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: 'itemBarcode1', extStatusName: 'Available', extMaterialTypeId: #(extMaterialTypeId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: 'itemBarcode2', extStatusName: 'Available', extMaterialTypeId: #(extMaterialTypeId) }


    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: 'userBarcode', extGroupId: #(fourthUserGroupId) }

    # post a request
    * def requestId1 = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId1
    * requestEntityRequest.itemId = extItemId1
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # post a another request
    * def requestId2 = call uuid1
    * requestEntityRequest.id = requestId2
    * requestEntityRequest.itemId = extItemId2
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # post a circulation setting
    * def id = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    And request circulationSettingRequest
    When method POST
    Then status 201

    # post a print event log
    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = [requestId1, requestId2]
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    When method POST
    Then status 204

    Given path 'circulation/' + 'settings/' + id
    When method DELETE
    Then status 204

  Scenario: Save a print events log when duplicate circulation setting found

    * def id1 = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id1
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    And request circulationSettingRequest
    When method POST
    Then status 201

    * def id2 = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id2
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'false'
    And request circulationSettingRequest
    When method POST
    Then status 201

    Given path 'circulation', 'settings'
    When method GET
    Then status 200

    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Multiple configurations found for print event feature'

    Given path 'circulation/' + 'settings/' + id1
    When method DELETE
    Then status 204

    Given path 'circulation/' + 'settings/' + id2
    When method DELETE
    Then status 204

    Given path 'circulation', 'settings'
    When method GET
    Then status 200

  Scenario: Save a print events log when printevent setting flag is disabled

    * def id = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'false'
    And request circulationSettingRequest
    When method POST
    Then status 201

    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'print event feature is disabled for this tenant'

    Given path 'circulation/' + 'settings/' + id
    When method DELETE
    Then status 204

  Scenario: Save a print events log when printevent with invalid request

    * def id = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    And request circulationSettingRequest
    When method POST
    Then status 201

    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6147']
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'invalid request found'

    Given path 'circulation/' + 'settings/' + id
    When method DELETE
    Then status 204

  Scenario: print and fetch details with printEventFeature enabled

    * def id = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    And request circulationSettingRequest
    When method POST
    Then status 201

    * def extMaterialTypeId = call uuid1
    * def extItemId1 = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: 'book' }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: 'itemBarcode3', extStatusName: 'Available', extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: 'userBarcode3', extGroupId: #(fourthUserGroupId) }

    # post a request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.itemId = extItemId1
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # print the request for the first time
    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = [requestId]

    * def requesterId = call uuid1
    * def requesterFirstName = 'sreeja'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: 'damon', extGroupId: #(fourthUserGroupId), firstName: #(requesterFirstName)}

    * printEventsRequest.requesterId = requesterId
    * printEventsRequest.requesterName = requesterFirstName
    * printEventsRequest.printEventDate = '2024-08-05T14:10:00.000+00:00'
    And request printEventsRequest
    When method POST
    Then status 204

    # print the request for the second time
    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = [requestId]

    * def requesterId = call uuid1
    * def requesterFirstName = 'sreeja mangarapu'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: 'Stefen', extGroupId: #(fourthUserGroupId), firstName: #(requesterFirstName)}

    * printEventsRequest.requesterId = requesterId
    * printEventsRequest.requesterName = requesterFirstName
    * printEventsRequest.printEventDate = '2024-08-06T14:10:00.000+00:00'
    And request printEventsRequest
    When method POST
    Then status 204

    Given path 'circulation', 'requests'
    And param query = 'id==' + requestId
    When method GET
    Then status 200
    And match response.requests[0].printDetails.count == 2
    And match response.requests[0].printDetails.lastPrintRequester.firstName == 'sreeja mangarapu'

    Given path 'circulation/' + 'settings/' + id
    When method DELETE
    Then status 204

  Scenario: print and fetch details when printEventLogFeature circulation setting is not present

    * def extMaterialTypeId = call uuid1
    * def extItemId1 = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: 'dvd' }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: 'itemBarcode4', extStatusName: 'Available', extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: 'userBarcode4', extGroupId: #(fourthUserGroupId) }

    # post a request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.itemId = extItemId1
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    Given path 'circulation', 'requests'
    And param query = 'id==' + requestId
    When method GET
    Then status 200
    And match response.requests[0].printDetails == '#notpresent'


  Scenario: print and fetch details when printEventLogFeature circulation setting is disabled

    * def id = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'false'
    And request circulationSettingRequest
    When method POST
    Then status 201

    * def extMaterialTypeId = call uuid1
    * def extItemId1 = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: 'cd' }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: 'itemBarcode5', extStatusName: 'Available', extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: 'userBarcode5', extGroupId: #(fourthUserGroupId) }

    # post a request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.itemId = extItemId1
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # post a print event log for first time
    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = [requestId]

    * def requesterId = call uuid1
    * def requesterFirstName = 'sreeja'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: 'elena', extGroupId: #(fourthUserGroupId), firstName: #(requesterFirstName)}

    * printEventsRequest.requesterId = requesterId
    * printEventsRequest.requesterName = requesterFirstName
    * printEventsRequest.printEventDate = '2024-08-05T14:10:00.000+00:00'
    And request printEventsRequest
    When method POST
    Then status 422

    Given path 'circulation', 'requests'
    And param query = 'id==' + requestId
    When method GET
    Then status 200
    And match response.requests[0].printDetails == '#notpresent'

