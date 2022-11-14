Feature: Requests tests

  Background:
    * url baseUrl
    * def servicePointId = call uuid1
    * def groupId = call uuid1
    * def instanceId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def cancellationReasonId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(servicePointId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostCancellationReason')

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy disallows pages
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource'
    * def extUserBarcode = 'FAT-1030UBC'
    * def extItemBarcode = 'FAT-1030IBC'
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(extMaterialTypeId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(firstUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(firstUserGroupId) }

    # post a request and verify that the user is not allowed to create a page request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Page requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a hold request when the applicable request policy disallows holds
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 2'
    * def extUserBarcode = 'FAT-1031UBC'
    * def extItemBarcode = 'FAT-1031IBC'
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(extMaterialTypeId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(secondUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(secondUserGroupId)  }

    # post a request and verify that the user is not allowed to create a hold request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requestType = 'Hold'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Hold requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy disallows recalls
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 3'
    * def extUserBarcode = 'FAT-1032UBC'
    * def extItemBarcode = 'FAT-1032IBC'
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(extMaterialTypeId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(thirdUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(thirdUserGroupId) }

    # post a request and verify that the user is not allowed to create a recall request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requestType = 'Recall'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Recall requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy allows pages, but items is not of status Available or Recently returned
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 4'
    * def extUserBarcode = 'FAT-1033UBC'
    * def extItemBarcode = 'FAT-1033IBC'
    * def extStatusName = 'Paged'
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is not allowed to create a page request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Page requests are not allowed for this patron and item combination'

  # This scenario does not cover testing for item with statuses, 'Recently returned', 'Missing from ASR' and 'Retrieving from ASR' due to lack of implementation
  Scenario Outline: Requests: Given an item Id, a user Id, and a pickup location, attempt to create a hold request when the applicable request policy allows holds, but item is of status "Available", "Recently returned", "In process (not requestable)", "Declared lost", "Lost and paid", "Aged to lost", "Claimed returned", "Missing from ASR", "Long missing", "Retrieving from ASR", "Withdrawn", "Order closed", "Intellectual item", "Unavailable", or "Unknown" (should fail)
    * def extMaterialTypeId = call uuid1
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName:  #(<materialTypeName>) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(<itemBarcode>), extMaterialTypeId: #(extMaterialTypeId), extStatusName: #(<status>) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(<userBarcode>), extGroupId: #(fourthUserGroupId)  }

    # post a request and verify that the user is not allowed to create a hold request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requestType = 'Hold'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Hold requests are not allowed for this patron and item combination'

    # 'Recently returned', 'Missing from ASR' and 'Retrieving from ASR' are skipped due to the lack of implementation
    Examples:
      | status                         | materialTypeName              | itemBarcode      | userBarcode      |
      | 'Available'                    | 'electronic resource 1034-1'  | 'FAT-1034IBC-1'  | 'FAT-1034UBC-1'  |
      | 'In process (non-requestable)' | 'electronic resource 1034-3'  | 'FAT-1034IBC-3'  | 'FAT-1034UBC-3'  |
      | 'Declared lost'                | 'electronic resource 1034-4'  | 'FAT-1034IBC-4'  | 'FAT-1034UBC-4'  |
      | 'Lost and paid'                | 'electronic resource 1034-5'  | 'FAT-1034IBC-5'  | 'FAT-1034UBC-5'  |
      | 'Aged to lost'                 | 'electronic resource 1034-6'  | 'FAT-1034IBC-6'  | 'FAT-1034UBC-6'  |
      | 'Claimed returned'             | 'electronic resource 1034-7'  | 'FAT-1034IBC-7'  | 'FAT-1034UBC-7'  |
      | 'Long missing'                 | 'electronic resource 1034-8'  | 'FAT-1034IBC-8'  | 'FAT-1034UBC-8'  |
      | 'Withdrawn'                    | 'electronic resource 1034-9'  | 'FAT-1034IBC-9'  | 'FAT-1034UBC-9'  |
      | 'Intellectual item'            | 'electronic resource 1034-11' | 'FAT-1034IBC-11' | 'FAT-1034UBC-11' |
      | 'Unavailable'                  | 'electronic resource 1034-12' | 'FAT-1034IBC-12' | 'FAT-1034UBC-12' |
      | 'Unknown'                      | 'electronic resource 1034-13' | 'FAT-1034IBC-13' | 'FAT-1034UBC-13' |

  # This scenario does not cover testing for item with statuses, 'Recently returned', 'Missing from ASR' and 'Retrieving from ASR' due to lack of implementation
  Scenario Outline: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls, but item is of status "Available", "Recently returned", "Missing", "In process (non-requestable)", "Declared lost", "Lost and paid", "Aged to lost", "Claimed returned", "Missing from ASR", "Long missing", "Retrieving from ASR", "Withdrawn", "Order closed", "Intellectual item", "Unavailable", or "Unknown" (should fail)
    * def extMaterialTypeId = call uuid1
    * def extUserId = call uuid1
    * def extItemId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(<materialTypeName>) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(<itemBarcode>), extStatusName: #(<status>),  extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(<userBarcode>), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is not allowed to create a recall request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Recall'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Recall requests are not allowed for this patron and item combination'

    # 'Recently returned', 'Missing from ASR' and 'Retrieving from ASR' are skipped due to the lack of implementation
    Examples:
      | status                         | materialTypeName              | itemBarcode      | userBarcode      |
      | 'Available'                    | 'electronic resource 1035-1'  | 'FAT-1035IBC-1'  | 'FAT-1035UBC-1'  |
      | 'Missing'                      | 'electronic resource 1035-2'  | 'FAT-1035IBC-2'  | 'FAT-1035UBC-2'  |
      | 'In process (non-requestable)' | 'electronic resource 1035-3'  | 'FAT-1035IBC-3'  | 'FAT-1035UBC-3'  |
      | 'Declared lost'                | 'electronic resource 1035-4'  | 'FAT-1035IBC-4'  | 'FAT-1035UBC-4'  |
      | 'Lost and paid'                | 'electronic resource 1035-5'  | 'FAT-1035IBC-5'  | 'FAT-1035UBC-5'  |
      | 'Aged to lost'                 | 'electronic resource 1035-6'  | 'FAT-1035IBC-6'  | 'FAT-1035UBC-6'  |
      | 'Claimed returned'             | 'electronic resource 1035-7'  | 'FAT-1035IBC-7'  | 'FAT-1035UBC-7'  |
      | 'Long missing'                 | 'electronic resource 1035-8'  | 'FAT-1035IBC-8'  | 'FAT-1035UBC-8'  |
      | 'Withdrawn'                    | 'electronic resource 1035-9'  | 'FAT-1035IBC-9'  | 'FAT-1035UBC-9'  |
      | 'Order closed'                 | 'electronic resource 1035-10' | 'FAT-1035IBC-10' | 'FAT-1035UBC-10' |
      | 'Intellectual item'            | 'electronic resource 1035-11' | 'FAT-1035IBC-11' | 'FAT-1035UBC-11' |
      | 'Unavailable'                  | 'electronic resource 1035-12' | 'FAT-1035IBC-12' | 'FAT-1035UBC-12' |
      | 'Unknown'                      | 'electronic resource 1035-13' | 'FAT-1035IBC-13' | 'FAT-1035UBC-13' |

  Scenario Outline: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy allows pages and item status is Available or Recently returned
    * def extMaterialTypeId = call uuid1
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(<materialTypeName>) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(<itemBarcode>), extStatusName: #(<itemStatus>), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(<userBarcode>), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a page request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.item.barcode == <itemBarcode>
    And match response.requester.barcode == <userBarcode>

    Examples:
      | itemStatus | materialTypeName        | itemBarcode     | userBarcode
      | 'Available'| 'electronic resource 1036-1' | 'FAT-1036IBC-1' | 'FAT-1036UBC-1'
      # uncomment this parameter when 'Recently returned' item status is implemented
      # | 'Recently returned'| 'electronic resource 1036-2' | 'FAT-1036IBC-2' | 'FAT-1036UBC-2'

  # Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is not "Available", "Recently returned", "Missing", "In process (not requestable)", "Declared lost", "Lost and paid", "Aged to lost", "Claimed returned", "Missing from ASR", "Long missing", "Retrieving from ASR", "Withdrawn", "Order closed", "Intellectual item", "Unavailable", or "Unknown"
  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "Checked out"
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserBarcode1 = 'FAT-1038UBC-1-CHECKED-OUT'
    * def extUserBarcode2 = 'FAT-1038UBC-2-CHECKED-OUT'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-CHECKED-OUT'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(fourthUserGroupId) }

    # checkout the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode) }

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId2), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "Restricted"
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserBarcode1 = 'FAT-1038UBC-1-RESTRICTED'
    * def extUserBarcode2 = 'FAT-1038UBC-2-RESTRICTED'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-RESTRICTED'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # mark the item as restricted
    Given path 'inventory/items/' + extItemId + '/mark-restricted'
    When method POST
    Then status 200
    And match response.status.name == 'Restricted'

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId2), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "In transit"
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserBarcode1 = 'FAT-1038UBC-1-IN-TRANSIT'
    * def extUserBarcode2 = 'FAT-1038UBC-2-IN-TRANSIT'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-IN-TRANSIT'
    * def extServicePointId = call uuid1

    # post a service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(fourthUserGroupId) }

    # checkout the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode) }

    # check-in the item from the second service point and verify that item status is changed to 'In transit'
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId) }
    * def item = checkInResponse.response.item
    And match item.id == extItemId
    And match item.status.name == 'In transit'

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId2), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "Awaiting pickup"
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserId3 = call uuid2
    * def extUserBarcode1 = 'FAT-1038UBC-1-AWAITING-PICKUP'
    * def extUserBarcode2 = 'FAT-1038UBC-2-AWAITING-PICKUP'
    * def extUserBarcode2 = 'FAT-1038UBC-3-AWAITING-PICKUP'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-AWAITING-PICKUP'
    * def extServicePointId = call uuid1

    # post a service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #(extUserBarcode3), extGroupId: #(fourthUserGroupId) }

    # checkout the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode) }

    # post a request for the checked-out-item
    * def extRequestId1 = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId1), itemId: #(extItemId), requesterId: #(extUserId2), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    # checkIn the item and check if the request status changed to awaiting pickup
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId)}
    * def response = checkInResponse.response
    And match response.item.id == extItemId
    And match response.item.status.name == 'Awaiting pickup'

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId3), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "Paged"
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserBarcode1 = 'FAT-1038UBC-1-PAGED'
    * def extUserBarcode2 = 'FAT-1038UBC-2-PAGED'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-PAGED'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId1 = call uuid1
    * def extRequestType1 = 'Page'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId1), itemId: #(extItemId), requesterId: #(extUserId1), extRequestType: #(extRequestType1), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    # get the item and verify that its status is paged
    Given path 'inventory/items/' + extItemId
    When method GET
    Then status 200
    And print response
    And match $.status.name == 'Paged'

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId2 = call uuid1
    * def extRequestType2 = 'Recall'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId2), itemId: #(extItemId), requesterId: #(extUserId2), extRequestType: #(extRequestType2), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "On order"
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-1038UBC-ON-ORDER'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-ON-ORDER'
    * def extStatusName = 'On order'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * def extRequestType = 'Recall'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "In process"
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-1038UBC-IN-PROCESS'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-IN-PROCESS'
    * def extStatusName = 'In process'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * def extRequestType = 'Recall'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls and item status is "Awaiting delivery"
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-1038UBC-AWAITING-DELIVERY'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1038IBC-AWAITING-DELIVERY'
    * def extStatusName = 'Awaiting delivery'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a recall request
    * def extRequestId = call uuid1
    * def extRequestType = 'Recall'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

  # This scenario does not cover testing for item with status 'Available in ASR' due to lack of implementation
  Scenario Outline: Requests: Given an item Id, a user Id, and a pickup location, attempt to create a hold request when the applicable request policy allows holds and item status is not "Available", "Recently returned", "In process (not requestable)", "Declared lost", "Lost and paid", "Aged to lost", "Claimed returned", "Missing from ASR", "Long missing", "Retrieving from ASR", "Withdrawn", "Order closed", "Intellectual item", "Unavailable", or "Unknown"
    * def extMaterialTypeId = call uuid1
    * def extItemId = call uuid1
    * def extUserId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(<materialTypeName>) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(<itemBarcode>), extStatusName: #(<itemStatus>), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(<userBarcode>), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is allowed to create a hold request
    * def extRequestId = call uuid1
    * def extRequestType = 'Hold'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    # 'Available in ASR' is skipped due to the lack of implementation
    Examples:
      | itemStatus          | materialTypeName              | itemBarcode      | userBarcode      |
      | 'On order'          | 'electronic resource 1037-1'  | 'FAT-1037IBC-1'  | 'FAT-1037UBC-1'  |
      | 'In process'        | 'electronic resource 1037-2'  | 'FAT-1037IBC-2'  | 'FAT-1037UBC-2'  |
      | 'Checked out'       | 'electronic resource 1037-3'  | 'FAT-1037IBC-3'  | 'FAT-1037UBC-3'  |
      | 'In transit'        | 'electronic resource 1037-4'  | 'FAT-1037IBC-4'  | 'FAT-1037UBC-4'  |
      | 'Awaiting pickup'   | 'electronic resource 1037-5'  | 'FAT-1037IBC-5'  | 'FAT-1037UBC-5'  |
      | 'Missing'           | 'electronic resource 1037-6'  | 'FAT-1037IBC-6'  | 'FAT-1037UBC-6'  |
      | 'Paged'             | 'electronic resource 1037-7'  | 'FAT-1037IBC-7'  | 'FAT-1037UBC-7'  |
      | 'Restricted'        | 'electronic resource 1037-8'  | 'FAT-1037IBC-8'  | 'FAT-1037UBC-8'  |
      | 'Awaiting delivery' | 'electronic resource 1037-9'  | 'FAT-1037IBC-9'  | 'FAT-1037UBC-9'  |
      # uncomment this parameter when 'Available in ASR' item status is implemented
      #  | 'Available in ASR'  | 'electronic resource 1037-10' | 'FAT-1037IBC-10' | 'FAT-1037UBC-10' |

  Scenario: Create a request with a patron note
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-1039-IBC'
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-1039-UBC'
    * def extRequestId = call uuid1
    * def extRequestType = 'Page'
    * def extPatronComments = 'This is a patron comment for FAT-1039'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }
    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user created a page request with a patron note
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = extRequestId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = 'Item'
    * requestEntityRequest.patronComments = extPatronComments
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.id == extRequestId
    And match response.itemId == extItemId
    And match response.requesterId == extUserId
    And match response.pickupServicePointId == servicePointId
    And match response.status == 'Open - Not yet filled'
    And match response.patronComments == extPatronComments

  Scenario: Cancel request
    * def extUserId = call uuid1
    * def extItemId = call uuid1
    * def extRequestType = 'Page'
    * def extRequestLevel = 'Item'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1040IBC') }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #('FAT-1040UBC'), extGroupId: #(fourthUserGroupId) }

    # post a request
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    # cancel the request
    * def cancelRequestEntityRequest = read('classpath:vega/mod-circulation/features/samples/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = extUserId
    * cancelRequestEntityRequest.requesterId = extUserId
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
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

  Scenario: Move request to another item on the same instance
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extItemBarcode1 = 'FAT-1041-IBC-1'
    * def extItemBarcode2 = 'FAT-1041-IBC-2'
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-1041-UBC'
    * def extRequestId = call uuid1
    * def extRequestType = 'Page'
    * def extMoveRequestId = call uuid1

    # post first and second items in the same instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: #(extItemBarcode2) }
    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }
    # post a request for the first item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId1), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    # post a move request and verify that request moved to second item
    * def moveRequestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/move-request-entity-request.json')
    * moveRequestEntityRequest.id = extMoveRequestId
    * moveRequestEntityRequest.destinationItemId = extItemId2
    * moveRequestEntityRequest.requestType = extRequestType
    Given path 'circulation/requests/' + extRequestId + '/move'
    And request moveRequestEntityRequest
    When method POST
    Then status 200
    And match response.itemId == extItemId2
    And match response.requestType == extRequestType
    And match response.item.barcode == extItemBarcode2
    And match response.position == 1
    And match response.status == 'Open - Not yet filled'

  Scenario: Generate pick slips for a service point
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extLocationId = call uuid1
    * def extItemBarcode = 'FAT-1043IBC'
    * def extUserBarcode = 'FAT-1043UBC'
    * def extServicePointId = call uuid1
    * def extLocationId = call uuid1
    * def extHoldingId = call uuid1

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId)  }

    # post an item
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request
    * def extRequestId = call uuid1
    * def extRequestType = 'Page'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePoint) }

    # get pick slips and verify that pick slip was generated with request
    Given path 'circulation', 'pick-slips', extServicePointId
    When method GET
    Then status 200
    And match $.pickSlips[0].requester.barcode == extUserBarcode
    And match $.pickSlips[0].item.barcode == extItemBarcode
    And match $.pickSlips[0].request.requestID == extRequestId

  Scenario: Reorder the request queue for an item
    * def extUserId1 = call uuid
    * def extUserId2 = call uuid
    * def extUserId3 = call uuid
    * def extItemId = call uuid
    * def extInstanceId = call uuid

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #('FAT-1042UBC'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #('FAT-1042UBC-2'), extGroupId: #(fourthUserGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId3), extUserBarcode: #('FAT-1042UBC-3'), extGroupId: #(fourthUserGroupId) }

    #post an instance
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId)}

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1042IBC') }

    # checkout the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #('FAT-1042UBC'), extCheckOutItemBarcode: #(extItemBarcode) }

    # post two requests in order to create queue
    * def extRequestId1 = call uuid1
    * def extRequestId2 = call uuid2
    * def extRequestType = 'Hold'
    * def extRequestLevel = 'Item'
    * def postRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId1), itemId: #(extItemId), requesterId: #(extUserId2), extRequestType: #(extRequestType), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(holdingId) }
    * def postRequestResponse2 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId2), itemId: #(extItemId), requesterId: #(extUserId3), extRequestType: #(extRequestType), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(holdingId) }

    # reorder the request queue
    * def reorderQueueRequest = read('classpath:vega/mod-circulation/features/samples/request/reorder-request-queue-entity-request.json')
    * reorderQueueRequest.reorderedQueue[0].id = extRequestId2
    * reorderQueueRequest.reorderedQueue[0].newPosition = postRequestResponse.response.position
    * reorderQueueRequest.reorderedQueue[1].id = extRequestId1
    * reorderQueueRequest.reorderedQueue[1].newPosition = postRequestResponse2.response.position

    Given path 'circulation/requests/queue/item', extItemId, 'reorder'
    And request reorderQueueRequest
    When method POST
    Then status 200

    Given path 'circulation', 'requests', extRequestId1
    When method GET
    Then status 200
    And match $.position == postRequestResponse2.response.position

    Given path 'circulation', 'requests', extRequestId2
    When method GET
    Then status 200
    And match $.position == postRequestResponse.response.position

  Scenario: Generate hold shelf clearance report for a location
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extItemId = call uuid1
    * def extUserBarcode = 'FAT-1044UBC-1'
    * def extItemBarcode = 'FAT-1044IBC'
    * def extServicePointId = call uuid1

    # post a service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId) }

    # post user1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode), extGroupId: #(fourthUserGroupId) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode) }

    # checkOut the item by user1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # post user2
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #('FAT-1044UBC-2'), extGroupId: #(fourthUserGroupId) }

    # post hold ilr by user2
    * def extRequestId = call uuid1
    * def extRequestType = 'Hold'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId2), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePointId:#(extServicePointId) }

    # checkIn the item
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId) }
    * def response = checkInResponse.response
    And match response.item.id == extItemId
    And match response.item.status.name == 'Awaiting pickup'

    # cancel the request and verify that request status is 'Closed - Cancelled'
    * def cancelRequestEntityRequest = read('classpath:vega/mod-circulation/features/samples/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = extUserId2
    * cancelRequestEntityRequest.requesterId = extUserId2
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
    * cancelRequestEntityRequest.itemId = extItemId
    * cancelRequestEntityRequest.pickupServicePointId = extServicePointId
    Given path 'circulation', 'requests', extRequestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', extRequestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    # get hold shelf clearance report for a location
    Given path 'circulation', 'requests-reports', 'hold-shelf-clearance', extServicePointId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].id == extRequestId

  Scenario: Run tlr-request feature
    * call read('classpath:vega/mod-circulation/features/tlr-requests.feature')

  Scenario: VuFind integration - backward compatibility. Requests shouldn't have instanceId, holdingRecordId, requestLevel fields as mandatory
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extRequestType = 'Page'

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: 'FAT-2178IBC' }

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: 'FAT-2178UBC', extGroupId: #(fourthUserGroupId) }

    # post a request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/legacy-request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId
    * requestEntityRequest.itemId = extItemId
    * requestEntityRequest.requestType = extRequestType

    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.instanceId == instanceId
    And match response.holdingsRecordId == holdingId
    And match response.itemId == extItemId
    And match response.requesterId == extUserId
    And match response.requestLevel == 'Item'
    And match response.requestType == extRequestType
    And match response.status == 'Open - Not yet filled'

  Scenario: When patron has exceeded their Patron Group Limit for 'Maximum number of items charged out', patron is not allowed to request items per Conditions settings
    * def extItemBarcode1 = 'FAT-1045IBC-1'
    * def extItemBarcode2 = 'FAT-1045IBC-2'
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extInstanceId = call uuid1
    * def extUserBarcode1 = 'FAT-1045UBC-1'
    * def extUserId1 = call uuid1

    # post items
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: #(extItemBarcode2) }

    # post a group and user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1) }

    # set up 'Maximum number of  items charged out' condition to  block the patron from request
    * def conditionId = '3d7c52dc-c732-4223-8bf8-e5917801386f'
    * def blockMessage = 'Maximum number of items charged out limit reached'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PutPatronBlockConditionById') { pbcId: #(conditionId), pbcMessage: #(blockMessage), blockBorrowing: #(false), blockRenewals: #(false), blockRequests: #(true), pbcName: #('Maximum number of items charged out') }

    # set patron block limits
    * def limitId = call uuid1
    * def patronBlockLimitRequest = { id: #(limitId), patronGroupId: #(groupId), conditionId: #(conditionId), value: 1 }
    Given path 'patron-block-limits'
    And request patronBlockLimitRequest
    When method POST
    Then status 201

    # checkOut the items
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode1) }
    And match responseStatus == 201
    *  call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode2) }
    And match responseStatus == 201
    # check automated patron block of the user and verify that the user has block for requests
    Given path 'automated-patron-blocks', extUserId1
    When method GET
    Then status 200
    And match $.automatedPatronBlocks[0].patronBlockConditionId == conditionId
    And match $.automatedPatronBlocks[0].blockBorrowing == false
    And match $.automatedPatronBlocks[0].blockRenewals == false
    And match $.automatedPatronBlocks[0].blockRequests == true

    # verify that requesting has been blocked for the user1
    * def extUserId2 = call uuid1
    * def extUserBarcode2 = 'FAT-1045UBC-2'
    * def extItemId3 = call uuid1
    * def extItemBarcode3 = 'FAT-1045IBC-3'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId3), extItemBarcode: #(extItemBarcode3) }
    * def checkOutResponse3 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode2), extCheckOutItemBarcode: #(extItemBarcode3) }
    * def requestId = call uuid1
    * def extRequestType = 'Recall'
    * def extRequestLevel = 'Item'
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.requesterId = extUserId1
    * requestEntityRequest.itemId = extItemId3
    * requestEntityRequest.instanceId = extInstanceId
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestType = extRequestType
    * requestEntityRequest.requestLevel = extRequestLevel
    * requestEntityRequest.pickupServicePointId = servicePointId
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    And retry until responseStatus == 422
    When method POST
    And match $.errors[0].message == blockMessage
    
  Scenario: When patron has exceeded their Patron Group Limit for 'Maximum number of overdue recalls', patron is not allowed to request items per Conditions settings
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extUserBarcode1 = 'FAT-1048UBC-1'
    * def extUserBarcode2 = 'FAT-1048UBC-2'
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extItemId3 = call uuid1
    * def extItemBarcode1 = 'FAT-1048IBC-1'
    * def extItemBarcode2 = 'FAT-1048IBC-2'
    * def extItemBarcode3 = 'FAT-1048IBC-3'

    # post a group and users
    * def groupId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(groupId) }

    # post items
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: #(extItemBarcode2) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId3), extItemBarcode: #(extItemBarcode3) }

    # set up 'Maximum number of overdue recalls' to block user(s) from requesting
    * def maxOverdueRecallsConditionId = 'e5b45031-a202-4abb-917b-e1df9346fe2c'
    * def blockMessage = 'Maximum number of overdue recalls limit exceeded'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PutPatronBlockConditionById') { pbcId: #(maxOverdueRecallsConditionId), pbcMessage: #(blockMessage), blockBorrowing: #(false), blockRenewals: #(false), blockRequests: #(true), pbcName: #('Maximum number of overdue recalls') }

    # set patron block limits
    * def limitId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { id: #(limitId), extGroupId: #(groupId), pbcId: #(maxOverdueRecallsConditionId), extValue: #(1) }

    # checkOut item1 and item2 for user1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode2) }

    # checkOut item3 for user2 so that user1 later could create a request for item3
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode2), extCheckOutItemBarcode: #(extItemBarcode3) }

    # post two recall requests for user2 in order to exceed limit (for 'Maximum number of overdue recalls' for user1)
    * def extRequestId1 = call uuid1
    * def extRequestId2 = call uuid1
    * def extRequestType = 'Recall'
    * def extRequestLevel = 'Item'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId1), itemId: #(extItemId1), requesterId: #(extUserId2), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId2), itemId: #(extItemId2), requesterId: #(extUserId2), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId) }

    # check automated patron block of user1 and verify that user1 has block for requesting
    * configure retry = { count: 10, interval: 1000 }
    Given path 'automated-patron-blocks', extUserId1
    And retry until response.automatedPatronBlocks.length > 0
    When method GET
    Then status 200
    And match $.automatedPatronBlocks[0].patronBlockConditionId == maxOverdueRecallsConditionId
    And match $.automatedPatronBlocks[0].blockBorrowing == false
    And match $.automatedPatronBlocks[0].blockRenewals == false
    And match $.automatedPatronBlocks[0].blockRequests == true

    # revert retry configuration to default values
    * configure retry = { count: 3, interval: 3000 }

    # verify that requesting has been blocked for user1:
    * def requestId = call uuid1
    * def extRequestType = 'Recall'
    * def extRequestLevel = 'Item'
    * def extRequestDate = call read('classpath:vega/mod-circulation/features/util/get-time-now-function.js')
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.requesterId = extUserId1
    * requestEntityRequest.itemId = extItemId3
    * requestEntityRequest.instanceId = instanceId
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestType = extRequestType
    * requestEntityRequest.requestLevel = extRequestLevel
    * requestEntityRequest.pickupServicePointId = servicePointId
    * requestEntityRequest.requestDate = extRequestDate
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    And retry until responseStatus == 422
    When method POST
    And match $.errors[0].message == blockMessage

  Scenario: When patron has exceeded their Patron Group Limit for 'Recall overdue by maximum number of days', patron is not allowed to request items per Conditions settings
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extUserBarcode1 = 'FAT-1050UBC-1'
    * def extUserBarcode2 = 'FAT-1050UBC-2'
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extItemBarcode1 = 'FAT-1050IBC-1'
    * def extItemBarcode2 = 'FAT-1050IBC-2'

    # post items
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId2), extItemBarcode: #(extItemBarcode2) }

    # post a group and users
    * def groupId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId1), extUserBarcode: #(extUserBarcode1), extGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: #(extUserBarcode2), extGroupId: #(groupId) }

    # set up 'Recall overdue by maximum number of days' to block user(s) from requesting
    * def recallOverdueMaxDaysConditionId = '08530ac4-07f2-48e6-9dda-a97bc2bf7053'
    * def blockMessage = 'Recall overdue by maximum number of days limit exceeded'
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PutPatronBlockConditionById') { pbcId: #(recallOverdueMaxDaysConditionId), pbcMessage: #(blockMessage), blockBorrowing: #(false), blockRenewals: #(false), blockRequests: #(true), pbcName: #('Recall overdue by maximum number of days') }

    # set patron block limits
    * def limitId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { id: #(limitId), extGroupId: #(groupId), pbcId: #(recallOverdueMaxDaysConditionId), extValue: #(1) }

    # checkOut item1 for user1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode1) }

    # checkOut item2 for user2 so that user1 later could create a request for item2
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode2), extCheckOutItemBarcode: #(extItemBarcode2) }

    # post a recall request for user2 to item1 (in order to exceed limit for 'Maximum number of overdue recalls' for user1)
    * def extRequestId = call uuid1
    * def extRequestType = 'Recall'
    * def extRequestLevel = 'Item'
    * def extRequestDate = '2021-10-27T15:51:02Z'
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = extRequestId
    * requestEntityRequest.itemId = extItemId1
    * requestEntityRequest.requesterId = extUserId2
    * requestEntityRequest.requestType = extRequestType
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestLevel = extRequestLevel
    * requestEntityRequest.requestDate = extRequestDate
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.id == extRequestId
    And match response.itemId == extItemId1
    And match response.requesterId == extUserId2
    And match response.pickupServicePointId == servicePointId
    And match response.status == 'Open - Not yet filled'

    # check automated patron block of user1 and verify that user1 has block for requesting
    * configure retry = { count: 10, interval: 1000 }
    Given path 'automated-patron-blocks', extUserId1
    And retry until response.automatedPatronBlocks.length > 0
    When method GET
    Then status 200
    And match $.automatedPatronBlocks[0].patronBlockConditionId == recallOverdueMaxDaysConditionId
    And match $.automatedPatronBlocks[0].blockBorrowing == false
    And match $.automatedPatronBlocks[0].blockRenewals == false
    And match $.automatedPatronBlocks[0].blockRequests == true

    # verify that requesting has been blocked for user1:
    * def requestId = call uuid1
    * def extRequestType = 'Recall'
    * def extRequestLevel = 'Item'
    * def extRequestDate = call read('classpath:vega/mod-circulation/features/util/get-time-now-function.js')
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.requesterId = extUserId1
    * requestEntityRequest.itemId = extItemId2
    * requestEntityRequest.instanceId = instanceId
    * requestEntityRequest.holdingsRecordId = holdingId
    * requestEntityRequest.requestType = extRequestType
    * requestEntityRequest.requestLevel = extRequestLevel
    * requestEntityRequest.pickupServicePointId = servicePointId
    * requestEntityRequest.requestDate = extRequestDate
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    And retry until responseStatus == 422
    When method POST
    And match $.errors[0].message == blockMessage