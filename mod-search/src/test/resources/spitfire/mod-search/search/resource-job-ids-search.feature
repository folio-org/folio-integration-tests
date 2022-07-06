Feature: Tests for streaming resource ids by cql query

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'x-okapi-token': #(okapitoken)}

  @Positive
  Scenario: Can retrieve all records ids
    Given path '/search/resources/jobs'
    And def query = 'cql.allRecords=1'
    And def entityType = 'AUTHORITY'
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 200
    Then match response.status == 'IN_PROGRESS'

    * def jobId = response.id

    ## Should complete the job
    Given path '/search/resources/jobs', jobId
    And retry until response.status != 'IN_PROGRESS'
    When method GET
    Then status 200

    ## Should contains all records ids
    Given path '/search/resources/jobs', jobId, 'ids'
    When method GET
    Then status 200
    And match response.totalRecord == 3
    And match response.ids contains 'cd3eee4e-5edd-11ec-bf63-0242ac130002'
    And match response.ids contains 'fd0b6ed1-d6af-4738-ac44-e99dbf561720'
    And match response.ids contains 'c73e6f60-5edd-11ec-bf63-0242ac130002'

    ## Job status should be DEPRECATED
    Given path '/search/resources/jobs', jobId
    When method GET
    Then status 200
    Then match response.status == 'DEPRECATED'

    ## Can't retrieve DEPRECATED job ids
    Given path '/search/resources/jobs', jobId, 'ids'
    When method GET
    Then status 400
    Then match response.errors[0].code == 'service_error'
    Then match response.errors[0].message == 'Completed async job with query=[cql.allRecords=1] was not found.'

  @Negative
  Scenario: Should return 400 if entity type is invalid
    Given path '/search/resources/jobs'
    And def query = 'cql.allRecords=1'
    And def entityType = 'invalidType'
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 400
    Then match response.errors[0].code == 'validation_error'
    Then match response.errors[0].message == 'Unexpected value \'' + entityType + '\''

  @Negative
  Scenario: Should return 400 if query is not present
    Given path '/search/resources/jobs'
    And def job = read('classpath:samples/resourceIdsSearch.json')
    Then remove job.query
    And request job
    When method POST
    Then status 400
    Then match response.errors[0].code == 'validation_error'
    Then match response.errors[0].message == 'must not be null'

  @Negative
  Scenario: Job should failed with ERROR if query is invalid
    Given path '/search/resources/jobs'
    And def query = 'invalid query'
    And def entityType = 'AUTHORITY'
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 200
    Then match response.status == 'IN_PROGRESS'
    * def jobId = response.id

    Given path '/search/resources/jobs', jobId
    When method GET
    Then status 200
    Then match response.status == 'ERROR'

  @Negative
  Scenario: Job should failed with ERROR if query is blank
    Given path '/search/resources/jobs'
    And def query = ' '
    And def entityType = 'AUTHORITY'
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 200
    Then match response.status == 'IN_PROGRESS'
    * def jobId = response.id

    Given path '/search/resources/jobs', jobId
    When method GET
    Then status 200
    Then match response.status == 'ERROR'

