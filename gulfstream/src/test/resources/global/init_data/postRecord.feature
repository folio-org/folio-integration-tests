Feature: postRecord

  Background:
    * url baseUrl

  Scenario:
    Given path 'source-storage/records'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = id
    * set record.externalIdsHolder.instanceId = instanceId
    * set record.matchedId = matchedId
    And request record
    When method POST
    Then status 201
