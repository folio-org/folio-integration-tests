Feature: create srs record

  Background:
    * url baseUrl
    * callonce login testUser

  Scenario: create snapshot and post record
    Given path 'source-storage/snapshots'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "jobExecutionId": "#(jobExecutionId)",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    Given path 'source-storage/records'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def record = read('classpath:samples/marc_record.json')
    * set record.snapshotId = jobExecutionId
    * set record.externalIdsHolder.instanceId = instanceId
    * set record.id = recordId
    * set record.matchedId = matchedId
    And request record
    When method POST
    Then status 201