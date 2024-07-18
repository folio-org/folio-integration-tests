Feature: Print events tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = headersUser
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')

  Scenario: Save a print events log with invalid request data[EMPTY_REQUEST_LIST]
    * print 'Save a print events log with EMPTY_REQUEST_LIST'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = []
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    Given path 'circulation', 'print-events-entry'
    When method POST
    Then status 422
    And match $.errors[0].message == 'Print Event Request  JSON is invalid'

  Scenario: Save a print events invalid request data[INVALID_UUID]
    * print 'Save a print events invalid request data[INVALID_UUID]'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
    * printEventsRequest.requesterId = 'invalid'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    Given path 'circulation', 'print-events-entry'
    When method POST
    Then status 422
    And match $.errors[0].message == 'No configuration found for print event feature'

  Scenario: Save a print events with invalid request data[NULL_VALUE]
    * print 'Save a print events with invalid request data[NULL_VALUE]'
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
    * print 'Save a print events log when no circulation setting found'
    * def printEventsRequest = read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6146']
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    Given path 'circulation', 'print-events-entry'
    When method POST
    Then status 422
    And match $.errors[0].message == 'No configuration found for print event feature'

    Scenario: Save a print events log
      * print 'Save a print events log '
      Given path 'circulation', 'settings'
      * def id = call uuid1
      * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
      * circulationSettingRequest.id = id
      * circulationSettingRequest.name = 'printEventLogFeature'
      * circulationSettingRequest.value.enablePrintLog = 'true'
      And request circulationSettingRequest
      When method POST
      Then status 201

      * def requestResponse = call read('classpath:vega/mod-circulation/features/requests.feature@PostRequest')
      * def requestId1 = requestResponse.response.id
      * print requestId1

      Given path 'circulation', 'print-events-entry'
      * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
      * printEventsRequest.requestIds = [requestId1]
      * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
      * printEventsRequest.requesterName = 'sreeja'
      And request printEventsRequest
      When method POST
      Then status 201

      Given path 'circulation/' + 'settings/' + id
      When method DELETE
      Then status 204

  Scenario: Save a print events log when duplicate circulation setting found
    * print 'Save a print events log when duplicate circulation setting found'
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
    * print response

    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
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
    * print response

  Scenario: Save a print events log when printevent setting flag is disabled
    * print 'Save a print events log when printevent setting flag is disabled'
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
    * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
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
    * print 'Save a print events log when printevent with invalid request'
    * def id = call uuid1
    Given path 'circulation', 'settings'
    * def circulationSettingRequest = read('classpath:vega/mod-circulation/features/samples/circulation-settings/circulation-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    And request circulationSettingRequest
    When method POST
    Then status 201

#    * def requestResponse = call read('classpath:vega/mod-circulation/features/requests.feature@PostRequest')
#    * def requestId1 = requestResponse.response.id
#    * print requestId1

    Given path 'circulation', 'print-events-entry'
    * def printEventsRequest =  read('classpath:vega/mod-circulation/features/samples/print-events/print-events-request.json')
    * printEventsRequest.requestIds = ['3940b663-1ea4-4be6-a0cd-ffd8c2db6147']
    * printEventsRequest.requesterId = '3940b663-1ea4-4be6-a0cd-ffd8c2db6146'
    * printEventsRequest.requesterName = 'sreeja'
    And request printEventsRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'invalid request found'

















