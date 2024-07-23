Feature: Tests For Print Events

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * def requesterId = call uuid1
    * def requesterName = call random_string

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


