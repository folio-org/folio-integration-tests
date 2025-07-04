Feature: Title level request tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = headersUser
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig')
    * def instanceId = call uuid1
    * def holdingId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId)}
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingId), extInstanceId: #(instanceId) }

  Scenario: Create title level request
    * def extUserId = call uuid
    * def extRequestId = call uuid
    * def extItemId = call uuid
    * def extConfigId = call uuid1

    # post item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1505IBC'), extHoldingsRecordId: #(holdingId)}

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
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1511IBC'), extHoldingsRecordId: #(holdingId) }

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
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extConfigId = call uuid1

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #('FAT-1510UBC-1'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #('FAT-1510UBC-2'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #('FAT-1510UBC-3'), extGroupId: #(fourthUserGroupId) }

    # post an instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId)}

    # post a holding
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingId)  }

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
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extConfigId = call uuid1

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #('FAT-1508UBC-1'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #('FAT-1508UBC-2'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #('FAT-1508UBC-3'), extGroupId: #(fourthUserGroupId) }

    # post an instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }

    # post a holding
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extHoldingsRecordId: #(extHoldingId), extInstanceId: #(extInstanceId) }

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

  Scenario: TLR recall should not prohibit checkout of another item of the same instance
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'book'
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extUserId3 = call uuid1
    * def extUserBarcode1 = 'FAT-6950UBC-1'
    * def extUserBarcode2 = 'FAT-6950UBC-2'
    * def extUserBarcode3 = 'FAT-6950UBC-3'
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extItemBarcode1 = 'FAT-6950IBC-1'
    * def extItemBarcode2 = 'FAT-6950IBC-2'
    * def extHoldingId = call uuid1
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extInstanceId = call uuid1

    # post a group and users
    * def groupId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #(extUserBarcode3), extGroupId: #(groupId) }

    # post an instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }

    # post a holding
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extHoldingsRecordId: #(extHoldingId), extInstanceId: #(extInstanceId) }

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post items
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: #(extItemBarcode2) }

    # checkOut item1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode1) }

    # post page requests for user2
    * def extRequestId1 = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId1), requesterId: #(extUserId2), extInstanceId: #(extInstanceId), extRequestType: "Page" }

    # post move request and verify that request moved to item1
    * def extMoveRequestId = call uuid1
    * def moveRequestEntity = read('classpath:vega/mod-circulation/features/samples/request/move-request-entity-request.json')
    * moveRequestEntity.id = extMoveRequestId
    * moveRequestEntity.destinationItemId = extItemId1
    * moveRequestEntity.requestType = "Recall"
    Given path 'circulation/requests/' + extRequestId1 + '/move'
    And request moveRequestEntity
    When method POST
    Then status 200
    And match response.itemId == extItemId1
    And match response.requestType == "Recall"
    And match response.item.barcode == extItemBarcode1
    And match response.position == 1
    And match response.status == 'Open - Not yet filled'

    # checkOut item2 for user3
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode3), extCheckOutItemBarcode: #(extItemBarcode2) }
    Then status 200

  Scenario: Title-level hold is prohibited when it must follow circulation rules and request policy does not allow Hold requests
    * def borrowerBarcode = "FAT-6946-1"
    * def requesterBarcode = "FAT-6946-2"
    * def itemBarcode = "FAT-6946-3"
    * def borrowerId = call uuid1
    * def requesterId = call uuid1
    * def itemId = call uuid1
    * def instanceId = call uuid1
    * def holdingsId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def requestId = call uuid1

    # update TLR-settings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig') { extTlrHoldShouldFollowCirculationRules: true }

    # prepare domain objects
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(borrowerId), extUserBarcode: #(borrowerBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: #(requesterBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingsId), extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extHoldingsRecordId: #(holdingsId) }

    # backup circulation rules
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def oldCirculationRulesAsText = response.rulesAsText

    # create request policy that does not allow Hold requests
    * def newRequestPolicyId = call uuid1
    * def requestPolicy = read('classpath:vega/mod-circulation/features/samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = newRequestPolicyId
    * requestPolicy.name = 'Request Policy for FAT-6946-1'
    * requestPolicy.requestTypes = ["Page", "Recall"]
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # replace circulation rules using new request policy
    * def newCirculationRulesAsText = 'priority: t, s, c, b, a, m, g \nfallback-policy: l ' + loanPolicyId + ' r ' + newRequestPolicyId + ' o ' + overdueFinePoliciesId + ' i ' + lostItemFeePolicyId + ' n ' + patronPolicyId
    * def newRules = { "rulesAsText": "#(newCirculationRulesAsText)" }
    Given path 'circulation/rules'
    And request newRules
    When method PUT
    Then status 204

    # verify that new circulation rules have been saved
    * configure retry = { count: 10, interval: 1000 }
    Given path 'circulation', 'rules'
    And retry until response.rulesAsText == newCirculationRulesAsText
    When method GET
    Then status 200

    # check-out the item in order to make it eligible for a Hold request
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(borrowerBarcode), extCheckOutItemBarcode: #(itemBarcode) }

    # attempt a Hold request
    * def holdRequest = read('classpath:vega/mod-circulation/features/samples/request/title-level-request-entity-request.json')
    * holdRequest.id = requestId
    * holdRequest.instanceId = instanceId
    * holdRequest.requesterId = requesterId
    * holdRequest.pickupServicePointId = servicePointId
    * holdRequest.requestType = "Hold"
    Given path 'circulation', 'requests'
    And request holdRequest
    When method POST
    Then status 422
    * def error = response.errors[0]
    And match error.message == 'Hold requests are not allowed for this patron and title combination'
    And match error.parameters == '#[2]'
    And match error.parameters[*].key contains "requesterId"
    And match error.parameters[*].value contains requesterId
    And match error.parameters[*].key contains "instanceId"
    And match error.parameters[*].value contains instanceId
    And match error.code == "REQUEST_NOT_ALLOWED_FOR_PATRON_TITLE_COMBINATION"

    # restore original circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRulesAsText)" }
    Given path 'circulation/rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # restore TLR-settings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig')

  Scenario: Title-level hold is placed when it must follow circulation rules and request policy allows Hold requests
    * def borrowerBarcode = "FAT-6946-4"
    * def requesterBarcode = "FAT-6946-5"
    * def itemBarcode = "FAT-6946-6"
    * def borrowerId = call uuid1
    * def requesterId = call uuid1
    * def itemId = call uuid1
    * def instanceId = call uuid1
    * def holdingsId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def requestId = call uuid1

    # update TLR-settings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig') { extTlrHoldShouldFollowCirculationRules: true }

    # prepare domain objects
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(borrowerId), extUserBarcode: #(borrowerBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: #(requesterBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingsId), extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extHoldingsRecordId: #(holdingsId) }

    # check-out the item in order to make it eligible for a Hold request
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(borrowerBarcode), extCheckOutItemBarcode: #(itemBarcode) }

    # place a Hold request
    * def holdRequest = read('classpath:vega/mod-circulation/features/samples/request/title-level-request-entity-request.json')
    * holdRequest.id = requestId
    * holdRequest.instanceId = instanceId
    * holdRequest.requesterId = requesterId
    * holdRequest.pickupServicePointId = servicePointId
    * holdRequest.requestType = "Hold"
    Given path 'circulation', 'requests'
    And request holdRequest
    When method POST
    Then status 201
    And match response.requestType == "Hold"
    And match response.requestLevel == "Title"
    And match response.instanceId == instanceId
    And match response.requesterId == requesterId

    # restore TLR-settings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig')

  Scenario: Title-level hold is placed when it must not follow circulation rules and request policy does not allow Hold requests
    * def borrowerBarcode = "FAT-6946-7"
    * def requesterBarcode = "FAT-6946-8"
    * def itemBarcode = "FAT-6946-9"
    * def borrowerId = call uuid1
    * def requesterId = call uuid1
    * def itemId = call uuid1
    * def instanceId = call uuid1
    * def holdingsId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def requestId = call uuid1

    # update TLR-settings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig') { extTlrHoldShouldFollowCirculationRules: false }

    # prepare domain objects
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(borrowerId), extUserBarcode: #(borrowerBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: #(requesterBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingsId), extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extHoldingsRecordId: #(holdingsId) }

    # backup circulation rules
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def oldCirculationRulesAsText = response.rulesAsText

    # create request policy that does not allow Hold requests
    * def newRequestPolicyId = call uuid1
    * def requestPolicy = read('classpath:vega/mod-circulation/features/samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = newRequestPolicyId
    * requestPolicy.name = 'Request Policy for FAT-6946-2'
    * requestPolicy.requestTypes = ["Page", "Recall"]
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # replace circulation rules using new request policy
    * def newCirculationRulesAsText = 'priority: t, s, c, b, a, m, g \nfallback-policy: l ' + loanPolicyId + ' r ' + newRequestPolicyId + ' o ' + overdueFinePoliciesId + ' i ' + lostItemFeePolicyId + ' n ' + patronPolicyId
    * def newRules = { "rulesAsText": "#(newCirculationRulesAsText)" }
    Given path 'circulation/rules'
    And request newRules
    When method PUT
    Then status 204

    # verify that new circulation rules have been saved
    * configure retry = { count: 10, interval: 1000 }
    Given path 'circulation', 'rules'
    And retry until response.rulesAsText == newCirculationRulesAsText
    When method GET
    Then status 200

    # check-out the item in order to make it eligible for a Hold request
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(borrowerBarcode), extCheckOutItemBarcode: #(itemBarcode) }

    # place a Hold request
    * def holdRequest = read('classpath:vega/mod-circulation/features/samples/request/title-level-request-entity-request.json')
    * holdRequest.id = requestId
    * holdRequest.instanceId = instanceId
    * holdRequest.requesterId = requesterId
    * holdRequest.pickupServicePointId = servicePointId
    * holdRequest.requestType = "Hold"
    Given path 'circulation', 'requests'
    And request holdRequest
    When method POST
    Then status 201
    And match response.requestType == "Hold"
    And match response.requestLevel == "Title"
    And match response.instanceId == instanceId
    And match response.requesterId == requesterId

    # restore original circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRulesAsText)" }
    Given path 'circulation/rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # restore TLR-settings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig')

  Scenario: Title-level request is not placed when requested pickup service point is not allowed by request policy
    * def requesterBarcode = "FAT-7216-4"
    * def borrowerBarcode = "FAT-7216-5"
    * def itemBarcode = "FAT-7216-6"
    * def requesterId = call uuid1
    * def borrowerId = call uuid1
    * def itemId = call uuid1
    * def instanceId = call uuid1
    * def holdingsId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def requestId = call uuid1
    * def newRequestPolicyId = call uuid1
    * def firstServicePointId = call uuid1
    * def secondServicePointId = call uuid1
    * def expectedErrorMessage = 'One or more Pickup locations are no longer available'
    * def expectedErrorCode = 'REQUEST_PICKUP_SERVICE_POINT_IS_NOT_ALLOWED'

    # prepare domain objects
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: #(requesterBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(borrowerId), extUserBarcode: #(borrowerBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingsId), extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extHoldingsRecordId: #(holdingsId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(firstServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(secondServicePointId) }

    # backup circulation rules
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def oldCirculationRulesAsText = response.rulesAsText

    # create request policy with a list of allowed service points
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(newRequestPolicyId), extRequestTypes: ["Hold", "Page", "Recall"], extAllowedServicePoints: {"Page": [#(firstServicePointId)], "Hold": [#(firstServicePointId)], "Recall": [#(firstServicePointId)]} }

    # replace circulation rules using new request policy
    * def newCirculationRulesAsText = 'priority: t, s, c, b, a, m, g \nfallback-policy: l ' + loanPolicyId + ' r ' + newRequestPolicyId + ' o ' + overdueFinePoliciesId + ' i ' + lostItemFeePolicyId + ' n ' + patronPolicyId
    * def newRules = { "rulesAsText": "#(newCirculationRulesAsText)" }
    Given path 'circulation/rules'
    And request newRules
    When method PUT
    Then status 204

    # verify that new circulation rules have been saved
    * configure retry = { count: 10, interval: 1000 }
    Given path 'circulation', 'rules'
    And retry until response.rulesAsText == newCirculationRulesAsText
    When method GET
    Then status 200

    # prepare a request template
    * def requestEntity = read('classpath:vega/mod-circulation/features/samples/request/title-level-request-entity-request.json')
    * requestEntity.instanceId = instanceId
    * requestEntity.requesterId = requesterId
    * requestEntity.pickupServicePointId = secondServicePointId

    # attempt a Page request
    * requestEntity.requestType = 'Page'
    Given path 'circulation', 'requests'
    And request requestEntity
    When method POST
    Then status 422
    * def error = response.errors[0]
    And match error.message == expectedErrorMessage
    And match error.parameters == '#[3]'
    And match error.parameters[*].key contains 'pickupServicePointId'
    And match error.parameters[*].value contains secondServicePointId
    And match error.parameters[*].key contains 'requestType'
    And match error.parameters[*].value contains 'Page'
    And match error.parameters[*].key contains 'requestPolicyId'
    And match error.parameters[*].value contains newRequestPolicyId
    And match error.code == expectedErrorCode

    # check-out the item in order to make it eligible for a Recall request
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(borrowerBarcode), extCheckOutItemBarcode: #(itemBarcode) }

    # attempt a Recall request
    * requestEntity.requestType = 'Recall'
    Given path 'circulation', 'requests'
    And request requestEntity
    When method POST
    Then status 422
    * def error = response.errors[0]
    And match error.message == expectedErrorMessage
    And match error.parameters == '#[3]'
    And match error.parameters[*].key contains 'pickupServicePointId'
    And match error.parameters[*].value contains secondServicePointId
    And match error.parameters[*].key contains 'requestType'
    And match error.parameters[*].value contains 'Recall'
    And match error.parameters[*].key contains 'requestPolicyId'
    And match error.parameters[*].value contains newRequestPolicyId
    And match error.code == expectedErrorCode

    # restore original circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRulesAsText)" }
    Given path 'circulation/rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204
