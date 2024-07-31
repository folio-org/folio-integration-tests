Feature: Tests For Print Events

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * def requesterId = call uuid1
    * def requesterName = call random_string
    * def printEventDate = "2024-06-25T20:00:00+05:30"

  Scenario: Save print events logs

    * def requestIds = ['1135727e-f42d-4d61-8e5f-a0aa0a65c88b', '20ae18e3-c349-4ac5-b676-c0d5b090c0be']
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 201

  Scenario:  print events logs with in invalid request Ids

    * def requestIds = ['request1', 'request2']
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'elements in list must match pattern'

  Scenario:  print events logs with empty request Id list

    * def requestIds = []
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'size must be between 1 and 2147483647'

  Scenario:  print events logs with in invalid requester Ids

    * def requestIds = ['1135727e-f42d-4d61-8e5f-a0aa0a65c88b', '20ae18e3-c349-4ac5-b676-c0d5b090c0be']
    * def requesterId = '12345'
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'must match \"^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[1-5][a-fA-F0-9]{3}-[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$\"'

  Scenario:  print events logs with null field

    * def requestIds = ['1135727e-f42d-4d61-8e5f-a0aa0a65c88b', '20ae18e3-c349-4ac5-b676-c0d5b090c0be']
    * def requesterName = null
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'must not be null'

  Scenario: get print event logs when no print events are present

    * def requestIds = ['fbbbe691-d6c6-4f40-b9dd-7364ccb1518a', 'fd831be3-f05f-4b6f-b68f-1a976ea1ab0f']
    * def printEventsStatusRequest = read('samples/print-events/print-events-status-request.json')
    * printEventsStatusRequest.requestIds = requestIds

    Given path 'print-events-storage', 'print-events-status'
    And request printEventsStatusRequest
    When method POST
    Then status 200
    And match response.totalRecords == 0

  Scenario: get print event logs with count and lastprinted details

    # save print details for the first time with requester1
    * def requestIds = ['fbbbe691-d6c6-4f40-b9dd-7364ccb1518a', 'fd831be3-f05f-4b6f-b68f-1a976ea1ab0f']
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    * printEventsRequest.requesterName = 'requester1'
    * printEventsRequest.printEventDate = '2024-07-30T14:10:00.000+00:00'

    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 201

    # get the print details of a request for the first time"
    * def requestIds = ['fbbbe691-d6c6-4f40-b9dd-7364ccb1518a']
    * def printEventsStatusRequest = read('samples/print-events/print-events-status-request.json')
    * printEventsStatusRequest.requestIds = requestIds

    Given path 'print-events-storage', 'print-events-status'
    And request printEventsStatusRequest
    When method POST
    Then status 200
    And match response.printEventsStatusResponses[0].requesterName == 'requester1'
    And match response.printEventsStatusResponses[0].count == 1

    # print the request for the 2 nd time with requester2
    * def requestIds = ['fbbbe691-d6c6-4f40-b9dd-7364ccb1518a','0a941419-1bc0-4e8b-960f-d0b7bc4fc6e3']
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    * printEventsRequest.requesterName = 'requester2'
    * printEventsRequest.printEventDate = '2024-07-31T14:10:00.000+00:00'

    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 201

    # get the last print details of request with the count
    * def requestIds = ['fbbbe691-d6c6-4f40-b9dd-7364ccb1518a']
    * def printEventsStatusRequest = read('samples/print-events/print-events-status-request.json')
    * printEventsStatusRequest.requestIds = requestIds
    Given path 'print-events-storage', 'print-events-status'
    And request printEventsStatusRequest
    When method POST
    Then status 200
    And match response.printEventsStatusResponses[0].requesterName == 'requester2'
    And match response.printEventsStatusResponses[0].count == 2

  Scenario: get print event status with empty request list

    * def requestIds = []
    * def printEventsStatusRequest = read('samples/print-events/print-events-status-request.json')
    * printEventsStatusRequest.requestIds = requestIds
    Given path 'print-events-storage', 'print-events-status'
    And request printEventsStatusRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'size must be between 1 and 2147483647'

  Scenario: get print event status with invalid request list

    * def requestIds = ['invalid_request']
    * def printEventsStatusRequest = read('samples/print-events/print-events-status-request.json')
    * printEventsStatusRequest.requestIds = requestIds
    Given path 'print-events-storage', 'print-events-status'
    And request printEventsStatusRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'elements in list must match pattern'




