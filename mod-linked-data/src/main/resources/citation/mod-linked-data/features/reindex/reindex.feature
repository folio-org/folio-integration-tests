Feature: Reindex resources in linked-data search index

  Background:
    * url baseUrl
    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Incremental reindex skips already-indexed work; full reindex with resourceType=WORK restores search indexing
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
    * call dropSearchIndex { resourceName: 'linked-data-work' }
    * configure headers = testUserHeaders

    # Step 4: Run incremental reindex for WORK - skips resources where index_date is already set in DB
    Given path 'linked-data/reindex/incremental'
    And param resourceType = 'WORK'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 5: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'INCREMENTAL' }

    # Step 6: Verify work is still NOT searchable - incremental skipped it because index_date was set
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 7: Run full reindex for WORK
    Given path 'linked-data/reindex/full'
    And param resourceType = 'WORK'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 8: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'FULL' }

    # Step 9: Verify the work is searchable again after full reindex
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * match response.totalRecords == 1

  @Positive
  Scenario: Incremental reindex skips already-indexed hub; full reindex with resourceType=HUB restores search indexing
    # Step 1: Import a Hub resource
    * def hubUri = 'https://id.loc.gov/resources/hubs/0f11341f-5bb5-9e64-110f-6bb4782fc615.json'
    * call importHub { hubUri: '#(hubUri)' }

    # Step 2: Verify the hub is initially searchable (index_date is set in DB after import)
    * def query = 'label="Eckardt, Jason, 1971-. Pulse-echo"'
    * def searchHubResult = call searchLinkedDataHub
    * match searchHubResult.response.totalRecords == 1

    # Step 3: Drop the linked-data-hub search index to simulate a stale/missing index
    * configure headers = testAdminHeaders
    * call dropSearchIndex { resourceName: 'linked-data-hub' }
    * configure headers = testUserHeaders

    # Step 4: Run incremental reindex for HUB - skips resources where index_date is already set in DB
    Given path 'linked-data/reindex/incremental'
    And param resourceType = 'HUB'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 5: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'INCREMENTAL' }

    # Step 6: Verify hub is still NOT searchable - incremental skipped it because index_date was set
    Given path 'search/linked-data/hubs'
    And param query = query
    And param limit = 10
    And param offset = 0
    When method GET
    Then status 200
    * match response.totalRecords == 0

    # Step 7: Run full reindex for HUB
    Given path 'linked-data/reindex/full'
    And param resourceType = 'HUB'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 8: Poll batch job status until terminal state
    * call assertReindexJobCompleted { jobExecutionId: '#(jobExecutionId)', expectedReindexType: 'FULL' }

    # Step 9: Verify the hub is searchable again after full reindex
    * def searchHubResult = call searchLinkedDataHub
    * match searchHubResult.response.totalRecords == 1
