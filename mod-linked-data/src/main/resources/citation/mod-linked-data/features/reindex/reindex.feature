Feature: Reindex resources in linked-data search index

  Background:
    * url baseUrl
    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Incremental reindex skips already-indexed resources; full reindex restores search indexing
    # Step 1: Create a Work resource
    * def workRequest = read('samples/work-request.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id

    # Step 2: Verify the work is initially searchable (index_date is set in DB after creation)
    * def query = 'title all "Reindex test work"'
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * match response.totalRecords == 1

    # Step 3: Drop the linked-data-work search index to simulate a stale/missing index
    * configure headers = testAdminHeaders
    Given path 'search/index/inventory/reindex'
    And request { recreateIndex: true, resourceName: 'linked-data-work' }
    When method POST
    Then status 200
    * configure headers = testUserHeaders

    # Step 4: Run incremental reindex - skips resources where index_date is already set in DB
    Given path 'linked-data/reindex/incremental'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 5: Poll batch job status until terminal state
    Given path 'linked-data/batch/status'
    And param jobExecutionId = jobExecutionId
    And retry until response.status == 'COMPLETED' || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail('Incremental reindex job failed. jobExecutionId=' + jobExecutionId)
    * match response.status == 'COMPLETED'
    * match response.jobName == 'reindexJob'
    * match response.reindexType == 'INCREMENTAL'

    # Step 6: Verify work is still NOT searchable - incremental skipped it because index_date was set
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 7: Run full reindex - drops index and re-indexes all resources regardless of index_date
    Given path 'linked-data/reindex/full'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 8: Poll batch job status until terminal state
    Given path 'linked-data/batch/status'
    And param jobExecutionId = jobExecutionId
    And retry until response.status == 'COMPLETED' || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail('Full reindex job failed. jobExecutionId=' + jobExecutionId)
    * match response.status == 'COMPLETED'
    * match response.jobName == 'reindexJob'
    * match response.reindexType == 'FULL'

    # Step 9: Verify the work is searchable again after full reindex
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * match response.totalRecords == 1

