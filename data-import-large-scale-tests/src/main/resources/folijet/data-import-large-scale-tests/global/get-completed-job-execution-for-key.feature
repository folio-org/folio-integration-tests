@ignore
Feature: Util feature to get job executions by S3 key with retries
  # parameters: key

  Background:
    # do this again since, while waiting, the access token can time out
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }

    * url baseUrl
    * configure retry = { interval: 5000, count: 30 }

  @getJobsByKeyWhenStatusCompleted
  Scenario: Get child jobs by S3 key and wait until jobs status will be 'completed'

    # splitting process creates additional job executions for parent/child
    # so we need to query to get the correct job execution ID
    Given path 'metadata-provider/jobExecutions'
    And param limit = 10000
    And param sortBy = 'started_date,desc'
    And param subordinationTypeNotAny = ['COMPOSITE_CHILD', 'PARENT_SINGLE']
    And headers headersUser
    And retry until response.jobExecutions[0].status == 'COMMITTED' || response.jobExecutions[0].status == 'ERROR' || response.jobExecutions[0].status == 'DISCARDED'
    When method get
    Then status 200

    * def parentJobExecutionId = response.jobExecutions.find(exec => exec.sourcePath == key).id

    # get children-jobs where each of them corresponds to part of the split original file
    Given path 'change-manager/jobExecutions', parentJobExecutionId, 'children'
    And headers headersUser
    And retry until response.jobExecutions.length > 0
    When method get
    Then status 200
    And def jobExecutions = $.jobExecutions

    # Wait till entire job finishes
    Given path 'change-manager/jobExecutions', parentJobExecutionId
    And headers headersUser
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method get
    Then status 200
    And print response.status

