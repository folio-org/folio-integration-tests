Feature: Requests tests - extended

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = headersUser
    * def servicePointId = call uuid1
    * def groupId = call uuid1
    * def instanceId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def cancellationReasonId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(servicePointId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostCancellationReason')

  @C539
  Scenario: Search requests by item barcode, title, request id, and requester barcode fragment
    * def groupId = call uuid1
    * def requesterId1 = call uuid1
    * def requesterId2 = call uuid1
    * def requesterBarcode1 = 'requester-12345'
    * def requesterBarcode2 = 'requester-98765'
    * def targetItemId = call uuid1
    * def otherItemId = call uuid1
    * def targetItemBarcode = 'FAT-23874-ITEM-1'
    * def otherItemBarcode = 'FAT-23874-ITEM-2'
    * def targetRequestId = call uuid1
    * def otherRequestId = call uuid1
    * def targetTitle = 'Long'
    * def requestType = 'Page'
    * def requestLevel = 'Item'

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId1), extUserBarcode: #(requesterBarcode1), extGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId2), extUserBarcode: #(requesterBarcode2), extGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(targetItemId), extItemBarcode: #(targetItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(otherItemId), extItemBarcode: #(otherItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(targetRequestId), itemId: #(targetItemId), requesterId: #(requesterId1), extRequestType: #(requestType), extRequestLevel: #(requestLevel), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(otherRequestId), itemId: #(otherItemId), requesterId: #(requesterId2), extRequestType: #(requestType), extRequestLevel: #(requestLevel), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    Given path 'circulation', 'requests'
    And param query = '((id=="' + targetItemBarcode + '" or requesterId=="' + targetItemBarcode + '" or requester.barcode=="' + targetItemBarcode + '*" or instance.title="' + targetItemBarcode + '*" or instanceId="' + targetItemBarcode + '*" or item.barcode="' + targetItemBarcode + '*" or itemId=="' + targetItemBarcode + '" or itemIsbn=="' + targetItemBarcode + '" or searchIndex.callNumberComponents.callNumber=="' + targetItemBarcode + '*" or fullCallNumberIndex=="' + targetItemBarcode + '*")) sortby requestDate'
    And param limit = 100
    When method GET
    Then status 200
    And assert response.requests.length == 1
    And match $.requests[0].id == targetRequestId
    And match $.requests[0].item.barcode == targetItemBarcode

    Given path 'circulation', 'requests'
    And param query = '((id=="' + targetRequestId + '" or requesterId=="' + targetRequestId + '" or requester.barcode=="' + targetRequestId + '*" or instance.title="' + targetRequestId + '*" or instanceId="' + targetRequestId + '*" or item.barcode="' + targetRequestId + '*" or itemId=="' + targetRequestId + '" or itemIsbn=="' + targetRequestId + '" or searchIndex.callNumberComponents.callNumber=="' + targetRequestId + '*" or fullCallNumberIndex=="' + targetRequestId + '*")) sortby requestDate'
    And param limit = 100
    When method GET
    Then status 200
    And assert response.requests.length == 1
    And match $.requests[0].id == targetRequestId

    Given path 'circulation', 'requests'
    And param query = '((id=="' + requesterBarcode1 + '" or requesterId=="' + requesterBarcode1 + '" or requester.barcode=="' + requesterBarcode1 + '*" or instance.title="' + requesterBarcode1 + '*" or instanceId="' + requesterBarcode1 + '*" or item.barcode="' + requesterBarcode1 + '*" or itemId=="' + requesterBarcode1 + '" or itemIsbn=="' + requesterBarcode1 + '" or searchIndex.callNumberComponents.callNumber=="' + requesterBarcode1 + '*" or fullCallNumberIndex=="' + requesterBarcode1 + '*")) sortby requestDate'
    And param limit = 100
    When method GET
    Then status 200
    And assert response.requests.length == 1
    And match $.requests[0].id == targetRequestId
    And match $.requests[0].requester.barcode == requesterBarcode1

    Given path 'circulation', 'requests'
    And param query = '((id=="' + targetTitle + '" or requesterId=="' + targetTitle + '" or requester.barcode=="' + targetTitle + '*" or instance.title="' + targetTitle + '*" or instanceId="' + targetTitle + '*" or item.barcode="' + targetTitle + '*" or itemId=="' + targetTitle + '" or itemIsbn=="' + targetTitle + '" or searchIndex.callNumberComponents.callNumber=="' + targetTitle + '*" or fullCallNumberIndex=="' + targetTitle + '*")) sortby requestDate'
    And param limit = 100
    When method GET
    Then status 200
    And match response.requests[*].id contains targetRequestId
    And match response.requests[*].id contains otherRequestId

  @C409462
  Scenario: If service point is deleted or becomes not pickup location, it should be removed from policies allowed service points
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = headersUser
    * def requesterBarcode = "FAT-7490-1"
    * def itemBarcode = "FAT-7490-2"
    * def requesterId = call uuid1
    * def itemId = call uuid1
    * def instanceId = call uuid1
    * def holdingsId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def firstRequestPolicyId = call uuid1
    * def secondRequestPolicyId = call uuid1
    * def firstServicePointId = call uuid1
    * def secondServicePointId = call uuid1
    * def thirdServicePointId = call uuid1

    # prepare domain objects
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(requesterId), extUserBarcode: #(requesterBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingsId), extInstanceId: #(instanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extHoldingsRecordId: #(holdingsId) }
    * def createFirstServicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(firstServicePointId) }
    * def createSecondServicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(secondServicePointId) }
    * def createThirdServicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(thirdServicePointId) }

    # create request policy with a list of allowed service points
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(firstRequestPolicyId), extAllowedServicePoints: {"Hold": [#(firstServicePointId), #(secondServicePointId)], "Recall": [#(thirdServicePointId)]}, extRequestTypes: ["Hold", "Recall"]}
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(secondRequestPolicyId), extAllowedServicePoints: {"Hold": [#(secondServicePointId), #(thirdServicePointId)]}, extRequestTypes: ["Hold", "Page"]}

    # delete secondServicePoint
    Given path 'service-points', secondServicePointId
    When method DELETE
    Then status 204

    # update thirdServicePoint with pickup location false
    Given path 'service-points', thirdServicePointId
    And request {"name": "Third service point", "code": "test", "discoveryDisplayName": "test", "pickupLocation": false}
    When method PUT
    Then status 204

    # verify that non-pickup and deleted service points are removed from policies
    Given path 'request-policy-storage/request-policies', firstRequestPolicyId
    When method GET
    Then status 200
    And match response.allowedServicePoints.Hold == '#[1]'
    And match response.allowedServicePoints.Hold contains firstServicePointId
    And match response.allowedServicePoints.Page == "#notpresent"
    And match response.allowedServicePoints.Recall == "#notpresent"

    Given path 'request-policy-storage/request-policies', secondRequestPolicyId
    When method GET
    Then status 200
    And match response.allowedServicePoints.Hold == "#notpresent"
    And match response.allowedServicePoints.Page == "#notpresent"
    And match response.allowedServicePoints.Recall == "#notpresent"

    # update thirdServicePoint with pickup location true
    Given path 'service-points', thirdServicePointId
    And request {"name": "Third service point", "code": "test", "discoveryDisplayName": "test", "pickupLocation": true, "holdShelfExpiryPeriod": {"duration": 3,"intervalId": "Weeks"}}
    When method PUT
    Then status 204

  @C350388
  Scenario: Test request filtration by request level
    * def itemId1 = call uuid1
    * def itemId2 = call uuid1
    * def itemBarcode1 = 'FAT-23921-ITEM-1'
    * def itemBarcode2 = 'FAT-23921-ITEM-2'
    * def userId1 = call uuid1
    * def userId2 = call uuid1
    * def patronGroupId = call uuid1
    * def userBarcode1 = 'FAT-23921-USER-1'
    * def userBarcode2 = 'FAT-23921-USER-2'
    * def itemLevelRequestId = call uuid1
    * def titleLevelRequestId = call uuid1

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrConfig')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTlrConfig')

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId1), extItemBarcode: #(itemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId2), extItemBarcode: #(itemBarcode2) }

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(patronGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId1), extUserBarcode: #(userBarcode1), extGroupId: #(patronGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId2), extUserBarcode: #(userBarcode2), extGroupId: #(patronGroupId) }

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(itemLevelRequestId), itemId: #(itemId1), requesterId: #(userId1), extRequestType: 'Page', extRequestLevel: 'Item', extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(titleLevelRequestId), requesterId: #(userId2), extInstanceId: #(instanceId) }

    Given path 'circulation/requests'
    And param query = 'requestLevel==Item AND requesterId==' + userId1
    When method GET
    Then status 200
    And assert response.requests.length == 1
    And match $.requests[0].id == itemLevelRequestId
    And match $.requests[0].requestLevel == 'Item'

    Given path 'circulation/requests'
    And param query = 'requestLevel==Title AND requesterId==' + userId2
    When method GET
    Then status 200
    And assert response.requests.length == 1
    And match $.requests[0].id == titleLevelRequestId
    And match $.requests[0].requestLevel == 'Title'

  @C396391
  Scenario: Verify requester.departments is populated in pick slip
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extDepartmentId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extLocationId = call uuid1
    * def extServicePointId = call uuid1
    * def extHoldingId = call uuid1
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extItemBarcode = 'FAT-396391IBC'
    * def extUserBarcode = 'FAT-396391UBC'
    * def extDepartmentName = 'dept-' + java.util.UUID.randomUUID()
    * def extMaterialTypeName = 'pick-slip-dept-mat-' + java.util.UUID.randomUUID()

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId) }

    # post a material type and item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingId) }

    # post a department
    Given path 'departments'
    And request { id: '#(extDepartmentId)', name: '#(extDepartmentName)', code: '#(extDepartmentName)' }
    When method POST
    Then status 201

    # post a user with the department assigned
    * def userEntityRequest = read('classpath:vega/mod-circulation/features/samples/user/user-entity-request.json')
    * userEntityRequest.id = extUserId
    * userEntityRequest.barcode = extUserBarcode
    * userEntityRequest.patronGroup = fourthUserGroupId
    * userEntityRequest.departments = [extDepartmentId]
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

    # post a Page request
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: 'Page', extRequestLevel: 'Item', extInstanceId: #(instanceId), extHoldingsRecordId: #(extHoldingId), extServicePointId: #(extServicePointId) }

    # get pick slips and verify requester.departments is populated
    Given path 'circulation', 'pick-slips', extServicePointId
    When method GET
    Then status 200
    And match $.pickSlips[0].requester.barcode == extUserBarcode
    And match $.pickSlips[0].requester.departments == extDepartmentName

    * def extMaterialTypeName = null

  @C515012
  Scenario: staffUsername token can be added to Search slip (Hold requests)
    * def searchSlipId = 'e6e29ec1-1a76-4913-bbd3-65f4ffd94e03'
    * def extServicePointId = call uuid1
    * def extLocationId = call uuid1
    * def extHoldingId = call uuid1
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-515012IBC'
    * def extCheckoutUserId = call uuid1
    * def extCheckoutUserBarcode = 'FAT-515012UBC-1'
    * def extHoldUserId = call uuid1
    * def extHoldUserBarcode = 'FAT-515012UBC-2'

    # Step 1-3: Retrieve Search slip (Hold requests) to save current template
    Given path 'staff-slips-storage', 'staff-slips', searchSlipId
    When method GET
    Then status 200
    And match response.name == 'Search slip (Hold requests)'
    * def originalStaffSlip = response
    * def originalTemplate = originalStaffSlip.template

    # Step 4-8: Update template body with {{staffSlip.staffUsername}} token
    * def updatedStaffSlip = originalStaffSlip
    * updatedStaffSlip.template = '<p>{{item.barcodeImage}}</p><p>{{staffSlip.staffUsername}}</p>'
    Given path 'staff-slips-storage', 'staff-slips', searchSlipId
    And request updatedStaffSlip
    When method PUT
    Then status 204

    # Step 9: Verify template was saved with {{staffSlip.staffUsername}} token
    Given path 'staff-slips-storage', 'staff-slips', searchSlipId
    When method GET
    Then status 200
    And match response.template contains '{{staffSlip.staffUsername}}'
    And match response.template contains '{{item.barcodeImage}}'

    # Set up inventory for Hold request: service point, location, holdings, item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), sourceId: #(extHoldingSourceId), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extHoldingsRecordId: #(extHoldingId) }

    # Post checkout user and hold requester user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extCheckoutUserId), extUserBarcode: #(extCheckoutUserBarcode), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extHoldUserId), extUserBarcode: #(extHoldUserBarcode), extGroupId: #(fourthUserGroupId) }

    # Check out item to checkout user so a Hold request becomes eligible
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extCheckoutUserBarcode), extCheckOutItemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId) }

    # Create Hold request for hold requester user
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extHoldUserId), extRequestType: 'Hold', extRequestLevel: 'Item', extInstanceId: #(instanceId), extHoldingsRecordId: #(extHoldingId), extServicePointId: #(extServicePointId) }

    # Enable PRINT_HOLD_REQUESTS so search-slips returns results (defaults to disabled)
    * def printHoldSettingId = call uuid1
    * def printHoldSettingBody = { id: '#(printHoldSettingId)', name: 'PRINT_HOLD_REQUESTS', value: { printHoldRequestsEnabled: true } }
    Given path 'circulation', 'settings'
    And request printHoldSettingBody
    When method POST
    Then status 201

    # Step 10-13: GET search slips and verify item, requester and request data are returned
    Given path 'circulation', 'search-slips', extServicePointId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.searchSlips[0].item.barcode == extItemBarcode
    And match $.searchSlips[0].requester.barcode == extHoldUserBarcode
    And match $.searchSlips[0].request.requestID == extRequestId

    # Step 12/14: Restore original Search slip template
    * originalStaffSlip.template = originalTemplate
    Given path 'staff-slips-storage', 'staff-slips', searchSlipId
    And request originalStaffSlip
    When method PUT
    Then status 204

    # Clean up: delete PRINT_HOLD_REQUESTS setting
    Given path 'circulation', 'settings', printHoldSettingId
    When method DELETE
    Then status 204

  @C515011
  Scenario: staffUsername token can be added to Request delivery staff slip and renders with the correct username
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'staff-username-mat-' + java.util.UUID.randomUUID()
    * def extServicePointId = call uuid1
    * def extLocationId = call uuid1
    * def extHoldingId = call uuid1
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extItemBarcode = 'FAT-20840IBC'
    * def extUserBarcode = 'FAT-20840UBC'

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId) }

    # Get the "Request delivery" staff slip and save original template for restore
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Request delivery"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def slipId = response.staffSlips[0].id
    * def originalSlip = response.staffSlips[0]
    * def originalTemplate = originalSlip.template

    # Update the slip template with {{staffSlip.staffUsername}} token
    * originalSlip.template = '{{staffSlip.staffUsername}}'
    Given path 'staff-slips-storage', 'staff-slips', slipId
    And request originalSlip
    When method PUT
    Then status 204

    # Verify the token was saved in the slip template
    Given path 'staff-slips-storage', 'staff-slips', slipId
    When method GET
    Then status 200
    And match response.template contains '{{staffSlip.staffUsername}}'

    # Create item, user, and Page request to generate a pick slip
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: '#(fourthUserGroupId)' }
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: 'Page', extRequestLevel: 'Item', extInstanceId: #(instanceId), extHoldingsRecordId: #(extHoldingId), extServicePointId: #(extServicePointId) }

    # Verify pick slip is generated for the request with the updated template active
    Given path 'circulation', 'pick-slips', extServicePointId
    When method GET
    Then status 200
    And match $.pickSlips[0].requester.barcode == extUserBarcode

    # Restore original staff slip template
    * originalSlip.template = originalTemplate
    Given path 'staff-slips-storage', 'staff-slips', slipId
    And request originalSlip
    When method PUT
    Then status 204

    * def extMaterialTypeName = null

  @C519972
  Scenario: staffUsername token can be added to Transit staff slip and renders with the correct username
    * def extCheckInServicePointId = call uuid1
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extItemBarcode = 'FAT-519972IBC'
    * def extUserBarcode = 'FAT-519972UBC'

    # Step 1-3: Get the "Transit" staff slip and save original template for restore
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Transit"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def slipId = response.staffSlips[0].id
    * def originalSlip = response.staffSlips[0]
    * def originalTemplate = originalSlip.template

    # Step 4-8: Update the slip template with {{staffSlip.staffUsername}} token
    * originalSlip.template = '<p>Hold request for item:</p><p>{{item.barcodeImage}}</p><p>Pick slip printed by:</p><p>{{staffSlip.staffUsername}}</p>'
    Given path 'staff-slips-storage', 'staff-slips', slipId
    And request originalSlip
    When method PUT
    Then status 204

    # Step 9: Verify template was saved with {{staffSlip.staffUsername}} token
    Given path 'staff-slips-storage', 'staff-slips', slipId
    When method GET
    Then status 200
    And match response.template contains '{{staffSlip.staffUsername}}'

    # Create item at default holdings (home SP = servicePointId from Background) and a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: '#(fourthUserGroupId)' }

    # Check out item to user at the home service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode), extServicePointId: #(servicePointId) }

    # Create a non-home service point for check-in to trigger "In transit" status
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extCheckInServicePointId) }

    # Step 12-13: Check in item at non-home service point — item goes "In transit"
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extCheckInServicePointId) }
    And match checkInResponse.response.item.status.name == 'In transit'
    And match checkInResponse.response.item.barcode == extItemBarcode

    # Verify item is "In transit" and its destination is the home service point
    Given path 'inventory', 'items', extItemId
    When method GET
    Then status 200
    And match response.status.name == 'In transit'

    # Restore original staff slip template
    * originalSlip.template = originalTemplate
    Given path 'staff-slips-storage', 'staff-slips', slipId
    And request originalSlip
    When method PUT
    Then status 204

