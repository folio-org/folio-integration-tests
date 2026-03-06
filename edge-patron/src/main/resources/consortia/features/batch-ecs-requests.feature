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
    Then status 201
    And martch response.mediatedRequestStatus = 'Pending'
    And match response.batchId == '#notnull'

    * def batchId = response.batchId

    # verify batch request status until it becomes 'Completed'
    Given url edgeUrl
    And path 'patron/account/', extternalSystemId, 'instance', universityInstanceId, 'batch-request', batchId, 'status'
    And param apikey = apikey
    And request batchRequestEntity
    And retry until response.status == 'Completed'
    And method GET
    Then status 200
    And match response.batchRequestId == batchId
    And match response.itemsTotal == 3
    And match response.itemsRequested == 3
    And match response.itemsPending == 0
    And match response.itemsFailed == 0
    And match response.itemsRequestedDetails[*].instanceId == [universityInstanceId, universityInstanceId, universityInstanceId]
    And match response.itemsRequestedDetails[*].itemId contains [itemId1, itemId2, itemId3]
    And match response.itemsRequestedDetails[*].pickUpLocationId == [servicePointId, servicePointId, servicePointId]
    And match response.itemsRequestedDetails[0].confirmedRequestId == '#notnull'
    And match response.itemsRequestedDetails[1].confirmedRequestId == '#notnull'
    And match response.itemsRequestedDetails[2].confirmedRequestId == '#notnull'

    # verify the created circulation requests
    * def circulationRequestId1 = response.itemsRequestedDetails[0].confirmedRequestId
    * def circulationRequestId2 = response.itemsRequestedDetails[0].confirmedRequestId
    * def circulationRequestId3 = response.itemsRequestedDetails[0].confirmedRequestId
    Given path 'circulation/requests'
    And param query = '(id=="' + circulationRequestId1 + '" or id=="' + circulationRequestId2 + '" or id=="' + circulationRequestId3 + '")'
    And retry until response.itemId == newItemId
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
    And match response.holds[*].batchRequestInfo.batchRequestId == [batchId, batchId, batchId]
    And match response.batches[0].status == 'Completed'
    And match response.batches[0].itemsTotal == 3
    And match response.batches[0].itemsRequested == 3
    And match karate.sizeOf(response.batches[0].itemsRequestedDetails) == 3
    And match response.batches[0].itemsRequestedDetails[*].itemId contains [itemId1, itemId2, itemId3]
    And match response.batches[0].itemsRequestedDetails[*].confirmedRequestId contains [circulationRequestId1, circulationRequestId2, circulationRequestId3]