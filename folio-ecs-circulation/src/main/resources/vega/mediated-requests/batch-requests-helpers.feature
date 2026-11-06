@ignore
Feature: Setup and assertions for batch request queues

  Background:
    * url baseUrl

  @CreateItem
  Scenario: create another item on the shared instance's college holding
    * configure headers = headersCollege
    Given path 'inventory/items'
    And request
      """
      {
        "id": "#(itemId)",
        "holdingsRecordId": "#(inventory.holdingId)",
        "barcode": "#(itemId)",
        "status": { "name": "Available" },
        "materialType": { "id": "#(mrMaterialTypeId)" },
        "permanentLoanType": { "id": "#(mrLoanTypeId)" },
        "permanentLocation": { "id": "#(mrCollegeLocationId)" }
      }
      """
    When method POST
    Then status 201

  @CreateBatch
  Scenario: submit a batch and wait for all three circulation requests
    * configure headers = headersCentral
    Given path 'requests-mediated/batch-mediated-requests'
    And request { requesterId: '#(requesterId)', patronComments: 'FAT-29135 queue regression', mediatedWorkflow: 'Multi-Item request', itemRequests: '#(itemRequests)' }
    When method POST
    Then status 201
    And match response.batchId == '#uuid'
    And match response.requesterId == requesterId
    * def batchId = response.batchId

    * configure retry = { count: 40, interval: 15000 }
    Given path 'requests-mediated/batch-mediated-requests', batchId
    And retry until responseStatus == 200 && (response.mediatedRequestStatus == 'Completed' || response.mediatedRequestStatus == 'Failed')
    When method GET
    Then status 200
    And match response.mediatedRequestStatus == 'Completed'

    Given path 'requests-mediated/batch-mediated-requests', batchId, 'details'
    And param limit = 100
    When method GET
    Then status 200
    And match response.totalRecords == 3
    And match each response.mediatedBatchRequestDetails contains { batchId: '#(batchId)', requesterId: '#(requesterId)', mediatedRequestStatus: 'Completed', confirmedRequestId: '#uuid' }
    * def details = response.mediatedBatchRequestDetails
    * def requestedItems = karate.map(details, function(d) { return { itemId: d.itemId, pickupServicePointId: d.pickupServicePointId } })
    And match requestedItems contains only itemRequests
    * def requestIds = karate.jsonPath(details, '$[*].confirmedRequestId')
    And match karate.distinct(requestIds) == '#[3]'

  @VerifyQueue
  Scenario: verify unique contiguous positions and batch ordering in a tenant
    * configure headers = tenantHeaders
    * def expectedRequestIds = firstRequestIds.concat(secondRequestIds)
    * def expectedPositions = karate.range(1, expectedRequestIds.length)
    * def firstPositions = karate.range(1, firstRequestIds.length)
    * def secondPositions = karate.range(firstRequestIds.length + 1, expectedRequestIds.length)
    * def positionsFor = function(requests, ids) { return karate.map(karate.filter(requests, function(r) { return ids.indexOf(r.id) != -1 }), function(r) { return r.position }) }
    # Queue changes propagate between tenants asynchronously. Wait for the complete expected queue.
    * def queueReady =
      """
      function(body) {
        if (!body || body.totalRecords != expectedRequestIds.length) return false;
        var requests = body.requests;
        return karate.match(karate.sort(karate.map(requests, function(r) { return r.id })), karate.sort(expectedRequestIds)).pass
          && karate.match(karate.map(requests, function(r) { return r.position }), expectedPositions).pass
          && karate.match(positionsFor(requests, firstRequestIds), firstPositions).pass
          && karate.match(positionsFor(requests, secondRequestIds), secondPositions).pass;
      }
      """
    * configure retry = { count: 40, interval: 15000 }
    Given path 'request-storage/requests'
    And param query = 'instanceId=="' + inventory.instanceId + '" and status=="Open*" sortby position'
    And param limit = 100
    And retry until responseStatus == 200 && queueReady(response)
    When method GET
    Then status 200
    And match response.totalRecords == expectedRequestIds.length
    And match response.requests[*].id contains only expectedRequestIds
    And match response.requests[*].position == expectedPositions
    And match positionsFor(response.requests, firstRequestIds) == firstPositions
    And match positionsFor(response.requests, secondRequestIds) == secondPositions
    * def firstRequests = karate.filter(response.requests, function(r) { return firstRequestIds.indexOf(r.id) != -1 })
    And match each firstRequests[*].requestType == 'Page'
