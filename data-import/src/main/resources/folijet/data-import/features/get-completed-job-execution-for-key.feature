Feature: Get job execution by S3 key (maps to job execution)

  Background:
    # do this again since, while waiting, the access token can time out :(
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * url baseUrl
    * configure retry = { interval: 1000, count: 600 }

  @getJobWhenJobStatusCompleted
  Scenario: wait until job status will be 'completed'

    # splitting process creates additional job executions for parent/child
    # so we need to query to get the correct job execution ID
    Given path 'metadata-provider/jobExecutions'
    And param subordinationTypeNotAny = ['COMPOSITE_CHILD', 'PARENT_SINGLE']
    And param sortBy = 'started_date,desc'
    And headers headersUser
    When method get
    Then status 200

    * def parentJobExecutionId = response.jobExecutions.find(exec => exec.sourcePath == key).id

    Given path 'change-manager/jobExecutions', parentJobExecutionId, 'children'
    And headers headersUser
    When method get
    Then status 200
    And def childJobExecutionIds = $.jobExecutions[*].id

    # Wait till entire job finishes
    Given path 'change-manager/jobExecutions', parentJobExecutionId
    And headers headersUser
    And print response.status
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method get
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
