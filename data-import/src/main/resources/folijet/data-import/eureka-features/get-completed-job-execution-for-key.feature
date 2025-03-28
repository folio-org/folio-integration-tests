Feature: Get job execution by S3 key with retries (maps to job execution)

  Background:
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * url baseUrl
    * configure retry = { interval: 2000, count: 30 }

  @getJobWhenJobStatusCompleted
  Scenario: wait until job status will be 'completed'

    # splitting process creates additional job executions for parent/child
    # so we need to query to get the correct job execution ID
    Given path 'metadata-provider/jobExecutions'
    And headers headersUser
    And param limit = 10000
    And param sortBy = 'started_date,desc'
    And param subordinationTypeNotAny = ['COMPOSITE_CHILD', 'PARENT_SINGLE']
    And retry until response.jobExecutions[0].status == 'COMMITTED' && response.jobExecutions[0].uiStatus == 'RUNNING_COMPLETE'
    When method get
    Then status 200

    * def parentJobExecutionId = response.jobExecutions.find(exec => exec.sourcePath == key).id

    Given path 'change-manager/jobExecutions', parentJobExecutionId, 'children'
    And headers headersUser
    And retry until response.jobExecutions.length > 0
    When method get
    Then status 200
    And def childJobExecutionIds = $.jobExecutions[*].id

    # Wait till entire job finishes
    Given path 'change-manager/jobExecutions', parentJobExecutionId
    And headers headersUser
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method get
    And print response.status
    Then status 200
    And def status = response.status

    # Backwards-compatibility with tests that expect the child, rather than the meta-parent job
    * def jobExecutionId = childJobExecutionIds[0]

    # Backwards-compatibility with tests that expect the child's execution contents in `response`
    Given path 'change-manager/jobExecutions', jobExecutionId
    And headers headersUser
    When method get
    Then status 200

    * def jobExecution = response
