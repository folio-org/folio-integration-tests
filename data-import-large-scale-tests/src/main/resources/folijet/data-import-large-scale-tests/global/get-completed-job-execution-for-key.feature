@ignore
Feature: Util feature to get job executions by S3 key with retries
  # parameters: key

  Background:
    # do this again since, while waiting, the access token can time out
    * configure headers = null
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
    * configure headers = headersUser

    * url baseUrl
    * configure retry = { interval: 30000, count: 50 }

  @getJobsByKeyWhenStatusCompleted
  Scenario: Get child jobs by S3 key and wait until jobs status will be 'completed'

    * def retryLogic =
      """
      function(){
        if (responseStatus == 401) {
          karate.log('ERROR: 401 Unauthorized detected. Refreshing token...');
          var loginResult = karate.call('classpath:common/login.feature');
          karate.configure('headers', { 'Content-Type': 'application/json', 'x-okapi-token': loginResult.okapitoken, 'x-okapi-tenant': tenant, 'Accept': '*/*' });
          karate.log('Token refreshed. Continuing retry.');
          return false;
        }

        if (responseStatus == 200 && response.jobExecutions && response.jobExecutions.length > 0) {
          var status = response.jobExecutions[0].status;
          var isCompleted = status == 'COMMITTED' || status == 'ERROR' || status == 'DISCARDED';
          if (isCompleted) {
            karate.log('*** Final status found: ' + status + '. Exiting retry loop. ***');
          }
          return isCompleted;
        }
        return false;
      }
      """

    # splitting process creates additional job executions for parent/child
    # so we need to query to get the correct job execution ID
    Given path 'metadata-provider/jobExecutions'
    And param limit = 10000
    And param sortBy = 'started_date,desc'
    And param subordinationTypeNotAny = ['COMPOSITE_CHILD', 'PARENT_SINGLE']
    And retry until retryLogic()
    When method get
    Then status 200

    * def parentJobExecutionId = response.jobExecutions.find(exec => exec.sourcePath == key).id

    # get children-jobs where each of them corresponds to part of the split original file
    Given path 'change-manager/jobExecutions', parentJobExecutionId, 'children'
    And retry until response.jobExecutions.length > 0
    When method get
    Then status 200
    And def jobExecutions = response.jobExecutions

    # Wait till entire job finishes
    Given path 'change-manager/jobExecutions', parentJobExecutionId
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method get
    And print response.status
    Then status 200

