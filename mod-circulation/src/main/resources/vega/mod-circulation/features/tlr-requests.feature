Feature: Title level request tests

  Background:
    * url baseUrl
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@EnableTlrFeature')

  Scenario: Create title level request
    * def extUserId = call uuid
    * def extRequestId = call uuid
    * def extItemId = call uuid
    * def extConfigId = call uuid1

    # post item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1505IBC') }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #('FAT-1505UBC'), extGroupId: #(fourthUserGroupId) }

    # post a title level request
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId), requesterId: #(extUserId), extInstanceId: #(instanceId), extRequestLevel: #(extRequestLevel), extRequestType: "Page" }

  Scenario: Cancel a title level request
    * def extUserId = call uuid1
    * def extItemId = call uuid1

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #('FAT-1511UBC'), extGroupId: #(fourthUserGroupId) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1511IBC') }

    # post a page tlr
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId), requesterId: #(extUserId), extInstanceId: #(instanceId) }

    # cancel the request
    * def cancelRequestEntityRequest = read('classpath:vega/mod-circulation/features/samples/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = extUserId
    * cancelRequestEntityRequest.requesterId = extUserId
    * cancelRequestEntityRequest.requestLevel = 'Title'
    * cancelRequestEntityRequest.requestType = 'Page'
    * cancelRequestEntityRequest.instanceId = instanceId
    * cancelRequestEntityRequest.itemId = extItemId
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId

    Given path 'circulation', 'requests', extRequestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', extRequestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

  Scenario: Reorder the request queue for an instance
    * def extUserId1 = call uuid
    * def extUserId2 = call uuid
    * def extUserId3 = call uuid
    * def extItemId = call uuid
    * def extInstanceId = call uuid
    * def extHoldingId = call uuid
    * def extConfigId = call uuid1

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #('FAT-1510UBC-1'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #('FAT-1510UBC-2'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #('FAT-1510UBC-3'), extGroupId: #(fourthUserGroupId) }

    # post an instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId)}

    # post a holding
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingId)  }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1510IBC') }

    # post three requests in order to create queue
    * def extRequestId1 = call uuid
    * def extRequestId2 = call uuid
    * def extRequestId3 = call uuid
    * def postRequestResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId1), itemId: #(extItemId), requesterId: #(extUserId1), extRequestType: "Page", extInstanceId: #(extInstanceId) }
    * def postRequestResponse2 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId2), requesterId: #(extUserId2), extRequestType: "Hold", extInstanceId: #(extInstanceId) }
    * def postRequestResponse3 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId3), requesterId: #(extUserId3), extRequestType: "Hold", extInstanceId: #(extInstanceId) }

    # reorder the request queue
    * def reorderQueueRequest = read('classpath:vega/mod-circulation/features/samples/request/reorder-tlr-queue-entity-request.json')
    * reorderQueueRequest.reorderedQueue[0].id = extRequestId1
    * reorderQueueRequest.reorderedQueue[0].newPosition = postRequestResponse1.response.position
    * reorderQueueRequest.reorderedQueue[1].id = extRequestId3
    * reorderQueueRequest.reorderedQueue[1].newPosition = postRequestResponse2.response.position
    * reorderQueueRequest.reorderedQueue[2].id = extRequestId2
    * reorderQueueRequest.reorderedQueue[2].newPosition = postRequestResponse3.response.position
    Given path 'circulation/requests/queue/instance', extInstanceId, 'reorder'
    And request reorderQueueRequest
    When method POST
    Then status 200

    Given path 'circulation', 'requests', extRequestId1
    When method GET
    Then status 200
    And match $.position == postRequestResponse1.response.position

    Given path 'circulation', 'requests', extRequestId2
    When method GET
    Then status 200
    And match $.position == postRequestResponse3.response.position

    Given path 'circulation', 'requests', extRequestId3
    When method GET
    Then status 200
    And match $.position == postRequestResponse2.response.position

  Scenario: Ensure request queue containing item and title requests is ordered correctly
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extUserId3 = call uuid1
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingId = call uuid1
    * def extConfigId = call uuid1

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #('FAT-1508UBC-1'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #('FAT-1508UBC-2'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #('FAT-1508UBC-3'), extGroupId: #(fourthUserGroupId) }

    # post an instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }

    # post a holding
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId), extInstanceId: #(extInstanceId) }

    # post the first item and a page tlr
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #('FAT-1508IBC-1'), extHoldingsRecordId: #(extHoldingId) }
    * def extRequestId1 = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId1), requesterId: #(extUserId1), extInstanceId: #(extInstanceId) }

    # post the second item, a page ilr and a hold tlr
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: #('FAT-1508IBC-2'), extHoldingsRecordId: #(extHoldingId) }
    * def extRequestId2 = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId2), itemId: #(extItemId2), requesterId: #(extUserId2), extRequestType: #('Page'), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingId) }
    * def extRequestId3 = call uuid2
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId3), requesterId: #(extUserId3), extInstanceId: #(extInstanceId), extRequestType: #('Hold') }

    # get request queue for the instance and verify that request orders are correct
    Given path 'circulation', 'requests', 'queue', 'instance', extInstanceId
    When method GET
    Then status 200
    And match $.requests[0].id == extRequestId1
    And match $.requests[0].requesterId == extUserId1
    And match $.requests[0].instanceId == extInstanceId
    And match $.requests[0].position == 1
    And match $.requests[1].id == extRequestId2
    And match $.requests[1].requesterId == extUserId2
    And match $.requests[1].instanceId == extInstanceId
    And match $.requests[1].position == 2
    And match $.requests[2].id == extRequestId3
    And match $.requests[2].requesterId == extUserId3
    And match $.requests[2].instanceId == extInstanceId
    And match $.requests[2].position == 3

