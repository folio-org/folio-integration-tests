Feature: Tests for streaming resource ids by cql query

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  @Positive
  Scenario Outline: Can retrieve all records ids
    Given path '/search/resources/jobs'
    And def query = 'cql.allRecords=1'
    And def entityType = <entityType>
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 200

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
    And match response.totalRecords == <totalRecords>

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

    Examples:
      | entityType  | totalRecords |
      | 'INSTANCE'  | 17           |
      | 'HOLDINGS'  | 16           |
      | 'AUTHORITY' | 3            |

  @Positive
  Scenario Outline: Can retrieve single record ids
    Given path '/search/resources/jobs'
    And def query = <searchQuery> + <expectedId>
    And def entityType = <entityType>
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 200

    * def jobId = response.id

    ## Should complete the job
    Given path '/search/resources/jobs', jobId
    And retry until response.status != 'IN_PROGRESS'
    When method GET
    Then status 200

    ## Should contains expected id
    Given path '/search/resources/jobs', jobId, 'ids'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.ids[0].id == <expectedId>

    ## Job status should be DEPRECATED
    Given path '/search/resources/jobs', jobId
    When method GET
    Then status 200
    Then match response.status == 'DEPRECATED'

    Examples:
      | entityType  | expectedId                             | searchQuery    |
      | 'INSTANCE'  | '7e18b615-0e44-4307-ba78-76f3f447041c' | 'id='          |
      | 'HOLDINGS'  | 'e3ff6133-b9a2-4d4c-a1c9-dc1867d4df19' | 'holdings.id=' |
      | 'AUTHORITY' | 'cd3eee4e-5edd-11ec-bf63-0242ac130002' | 'id='          |

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
    And def entityType = 'INSTANCE'
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
    And def entityType = 'HOLDINGS'
    And request read('classpath:samples/resourceIdsSearch.json')
    When method POST
    Then status 200
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
    * def jobId = response.id

    Given path '/search/resources/jobs', jobId
    When method GET
    Then status 200
    Then match response.status == 'ERROR'

