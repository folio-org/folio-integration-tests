Feature: Reindex resources in linked-data search index

  Background:
    * url baseUrl
    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

    * def setup = callonce read('setup.feature')
    * def workQuery = setup.workQuery
    * def hubQuery = setup.hubQuery

  @Positive
  Scenario: Incremental reindex skips already-indexed work; full reindex with resourceType=WORK restores search indexing
    # Step 1: Drop the linked-data-work search index to simulate a stale/missing index
    * configure headers = testAdminHeaders
    * call dropSearchIndex { resourceName: 'linked-data-work' }
    * configure headers = testUserHeaders

    # Step 2: Run incremental reindex for WORK - skips resources where index_date is already set in DB
    Given path 'linked-data/reindex/incremental'
    And param resourceType = 'WORK'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 3: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'INCREMENTAL' }

    # Step 4: Verify work is still NOT searchable - incremental skipped it because index_date was set
    Given path 'search/linked-data/works'
    And param query = workQuery
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 5: Run full reindex for WORK
    Given path 'linked-data/reindex/full'
    And param resourceType = 'WORK'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 6: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'FULL' }

    # Step 7: Verify the work is searchable again after full reindex
    Given path 'search/linked-data/works'
    And param query = workQuery
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * match response.totalRecords == 1

  @Positive
  Scenario: Incremental reindex skips already-indexed hub; full reindex with resourceType=HUB restores search indexing
    # Step 1: Drop the linked-data-hub search index to simulate a stale/missing index
    * configure headers = testAdminHeaders
    * call dropSearchIndex { resourceName: 'linked-data-hub' }
    * configure headers = testUserHeaders

    # Step 2: Run incremental reindex for HUB - skips resources where index_date is already set in DB
    Given path 'linked-data/reindex/incremental'
    And param resourceType = 'HUB'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 3: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'INCREMENTAL' }

    # Step 4: Verify hub is still NOT searchable - incremental skipped it because index_date was set
    Given path 'search/linked-data/hubs'
    And param query = hubQuery
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 5: Run full reindex for HUB
    Given path 'linked-data/reindex/full'
    And param resourceType = 'HUB'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 6: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'FULL' }

    # Step 7: Verify the hub is searchable again after full reindex
    * def query = hubQuery
    * call searchLinkedDataHub

  @Positive
  Scenario: Incremental reindex skips all already-indexed resources; full reindex without resourceType restores all search indexing
    # Step 1: Drop both search indexes to simulate a stale/missing state
    * configure headers = testAdminHeaders
    * call dropSearchIndex { resourceName: 'linked-data-work' }
    * call dropSearchIndex { resourceName: 'linked-data-hub' }
    * configure headers = testUserHeaders

    # Step 2: Run incremental reindex without resourceType - skips all already-indexed resources
    Given path 'linked-data/reindex/incremental'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 3: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'INCREMENTAL' }

    # Step 4: Verify work is still NOT searchable
    Given path 'search/linked-data/works'
    And param query = workQuery
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 5: Verify hub is still NOT searchable
    Given path 'search/linked-data/hubs'
    And param query = hubQuery
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 6: Run full reindex without resourceType - reindexes all resource types
    Given path 'linked-data/reindex/full'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 7: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'FULL' }

    # Step 8: Verify work is searchable again
    Given path 'search/linked-data/works'
    And param query = workQuery
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * match response.totalRecords == 1

    # Step 9: Verify hub is searchable again
    * def query = hubQuery
    * call searchLinkedDataHub
