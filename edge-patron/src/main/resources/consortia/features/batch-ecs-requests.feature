@parallel=false
Feature: ECS Batch Request creation

  Background:
    * url baseUrl

    * call eurekaLogin { username: '#(centralUser.username)', password: '#(centralUser.password)', tenant: '#(centralTenantName)' }
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }

    * configure headers = headersConsortia

    * callonce variablesCentral
    * callonce variablesUniversity

  Scenario: Create batch ECS request
    And path 'users', centralUserId
    When method GET
    Then status 200
    * def extternalSystemId = response.externalSystemId

    * def itemId1 = universityItemId1
    * def itemId2 = universityItemId2
    * def itemId3 = universityItemId3
    * def servicePointId = centralServicePointsId
    * def batchRequestEntity = read('classpath:consortia/samples/ecs-batch-request-entity.json')

    # create batch request
    Given url edgeUrl
    And path 'patron/account/', extternalSystemId, 'instance', universityInstanceId, 'batch-request'
    And param apikey = apikey
    And request batchRequestEntity
    And method POST
    Then status 200
    And match response.mediatedRequestStatus == 'Pending'
    And match response.batchId == '#notnull'
    * print 'POST batch response:', response

    * def batchId = response.batchId

    # verify batch request status until it becomes 'Completed'
    Given url edgeUrl
    And path 'patron/account/', extternalSystemId, 'instance', universityInstanceId, 'batch-request', batchId, 'status'
    And param apikey = apikey
    * retry until response.status == 'Completed'
    When method GET
    Then status 200
    * def batchStatusResult = response
    * print 'batchStatusResult:', batchStatusResult

    And match batchStatusResult.batchRequestId == batchId
    And match batchStatusResult.itemsTotal == 3
    And match batchStatusResult.itemsRequested == 3
    And match batchStatusResult.itemsPending == 0
    And match batchStatusResult.itemsFailed == 0
    And match each batchStatusResult.itemsRequestedDetails[*].instanceId == universityInstanceId
    And match batchStatusResult.itemsRequestedDetails[*].itemId contains only ['#(itemId1)', '#(itemId2)', '#(itemId3)']
    And match each batchStatusResult.itemsRequestedDetails[*].pickUpLocationId == servicePointId
    And match batchStatusResult.itemsRequestedDetails[0].confirmedRequestId == '#notnull'
    And match batchStatusResult.itemsRequestedDetails[1].confirmedRequestId == '#notnull'
    And match batchStatusResult.itemsRequestedDetails[2].confirmedRequestId == '#notnull'

    # verify the created circulation requests
    * def circulationRequestId1 = batchStatusResult.itemsRequestedDetails[0].confirmedRequestId
    * def circulationRequestId2 = batchStatusResult.itemsRequestedDetails[1].confirmedRequestId
    * def circulationRequestId3 = batchStatusResult.itemsRequestedDetails[2].confirmedRequestId
    Given url baseUrl
    And path 'circulation/requests'
    And param query = '(id=="' + circulationRequestId1 + '" or id=="' + circulationRequestId2 + '" or id=="' + circulationRequestId3 + '")'
    When method GET
    Then status 200
    And assert response.requests.length == 3

    # verify batchRequestInfo record in holds and batches section from patron/account response
    Given url edgeUrl
    And path 'patron/account/', extternalSystemId
    And param apikey = apikey
    And param includeHolds = true
    And param includeBatches = true
    When method GET
    Then status 200
    And match karate.sizeOf(response.holds) == 3
    And match karate.sizeOf(response.batches) == 1
    And match each response.holds[*].batchRequestInfo.batchRequestId == batchId
    And match response.batches[0].status == 'Completed'
    And match response.batches[0].itemsTotal == 3
    And match response.batches[0].itemsRequested == 3
    And match karate.sizeOf(response.batches[0].itemsRequestedDetails) == 3
    And match response.batches[0].itemsRequestedDetails[*].itemId contains only ['#(itemId1)', '#(itemId2)', '#(itemId3)']
    And match response.batches[0].itemsRequestedDetails[*].confirmedRequestId contains only ['#(circulationRequestId1)', '#(circulationRequestId2)', '#(circulationRequestId3)']

    # verify circulation request are created in secondary/university tenant
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    Given url baseUrl
    And path 'circulation/requests'
    And param query = '(id=="' + circulationRequestId1 + '" or id=="' + circulationRequestId2 + '" or id=="' + circulationRequestId3 + '")'
    When method GET
    Then status 200
    And assert response.requests.length == 3