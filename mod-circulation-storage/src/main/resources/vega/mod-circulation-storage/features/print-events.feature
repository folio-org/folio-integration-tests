Feature: Tests For Print Events

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')

  Scenario: Save print events logs
    * print 'Save print events logs'
    * def requestIds = ['1135727e-f42d-4d61-8e5f-a0aa0a65c88b', '20ae18e3-c349-4ac5-b676-c0d5b090c0be']
    * def requesterId = call uuid1
    * def requesterName = call random_string

    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 201

  Scenario:  print events logs with in invalid request Ids
    * print 'invalid request Ids'
    * def requestIds = ['request1', 'request2']
    * def requesterId = call uuid1
    * def requesterName = call random_string

    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422

  Scenario:  print events logs with in invalid requester Ids
    * print 'invalid requester Ids'
    * def requestIds = ['1135727e-f42d-4d61-8e5f-a0aa0a65c88b', '20ae18e3-c349-4ac5-b676-c0d5b090c0be']
    * def requesterId = '12345'
    * def requesterName = call random_string

    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422

  Scenario:  print events logs with null feild
    * print 'null feild'
    * def requestIds = ['1135727e-f42d-4d61-8e5f-a0aa0a65c88b', '20ae18e3-c349-4ac5-b676-c0d5b090c0be']
    * def requesterId = call uuid1
    * def requesterName = null
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422

  Scenario:  print events logs with more than 10000 records
    * print 'more than 10000 records'
    * def requesterId = call uuid1
    * def requesterName = call random_string
    * def generateUuids =
      """
      function(num) {
        var uuids = [];
        for (var i = 0; i < num; i++) {
          uuids.push(java.util.UUID.randomUUID().toString());
        }
        return uuids;
      }
      """
    * def requestIds = generateUuids(10009)
    * def printEventsRequest = read('samples/print-events/print-events-request.json')
    Given path 'print-events-storage', 'print-events-entry'
    And request printEventsRequest
    When method POST
    Then status 422


