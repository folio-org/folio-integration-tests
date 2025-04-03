Feature: postRecord

  Background:
    * url baseUrl

  Scenario:
    Given path 'source-storage/records'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = id
    * set record.matchedId = id
    * set record.externalIdsHolder.instanceId = instanceId
    And request record
    When method POST
    Then status 201
