Feature: Graph cleaning removes orphaned sub-resources from the linked-data graph

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Orphaned sub-resources are removed after graph cleaning job completes
    # Step 1: Create a Work resource - produces sub-nodes (Title, etc.) connected via resource_edges
    * def workRequest = read('samples/work-request.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id
    * def titleNodeId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']['http://bibfra.me/vocab/library/title'][0]['http://bibfra.me/vocab/library/Title'].id

    # Step 2: Delete the Work - its sub-nodes lose all incoming edges and become orphaned
    * call deleteResource { id: '#(workId)' }

    # Step 4: Trigger the graph cleaning batch job
    Given path 'linked-data/graphCleaning'
    When method POST
    Then status 200
    * def jobExecutionId = response

    # Step 5: Poll batch job status until terminal state
    Given path 'linked-data/batch/status'
    And param jobExecutionId = jobExecutionId
    And retry until response.status == 'COMPLETED' || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail('Graph cleaning job failed. jobExecutionId=' + jobExecutionId)
    * match response.status == 'COMPLETED'
    * match response.jobName == 'graphCleaningJob'

    # Step 6: Verify the orphaned title sub-node has been removed
    Given path 'linked-data/resource/' + titleNodeId
    When method GET
    Then status 404
