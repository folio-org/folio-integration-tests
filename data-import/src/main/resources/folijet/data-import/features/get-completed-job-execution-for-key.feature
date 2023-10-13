Feature: Get job execution by S3 key (maps to job execution)

  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 60000 }

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

    # Backwards-compatibility with tests that expect information from this, rather than the meta-parent job
    * def jobExecutionId = childJobExecutionIds[0]
