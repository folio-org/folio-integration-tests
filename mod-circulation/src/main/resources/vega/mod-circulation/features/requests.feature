Feature: Requests tests

  Background:
    * url baseUrl
    * def servicePointId = call uuid1
    * def groupId = call uuid1
    * def instanceId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')

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

    # post a cancellation reason
    * def extCancellationReasonId = call uuid1
    * def cancellationReasonRequest = read('classpath:vega/mod-circulation/features/samples/cancellation-reason-entity-request.json')
    * cancellationReasonRequest.id = extCancellationReasonId
    Given path 'cancellation-reason-storage', 'cancellation-reasons'
    And request cancellationReasonRequest
    When method POST
    Then status 201
    And match $.id == extCancellationReasonId

    # cancel the request
    * def cancelRequestEntityRequest = read('classpath:vega/mod-circulation/features/samples/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = extCancellationReasonId
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
    * def reorderQueueRequest = read('classpath:vega/mod-circulation/features/samples/reorder-request-queue-entity-request.json')
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

  Scenario: Ensure request queue containing item and title requests is ordered correctly
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extUserId3 = call uuid1
    * def extItemId1 = call uuid1
    * def extItemId2 = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingId = call uuid1

    # enable tlr feature
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@EnableTlrFeature')

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

  Scenario: Create title level request
    * def extUserId = call uuid
    * def extRequestId = call uuid
    * def extItemId = call uuid

    # enable Tlr feature
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@EnableTlrFeature')

    # post item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1505IBC') }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #('FAT-1505UBC'), extGroupId: #(fourthUserGroupId) }

    # post a title level request
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId), requesterId: #(extUserId), extInstanceId: #(instanceId), extRequestLevel: #(extRequestLevel), extRequestType: "Page" }

  Scenario: Cancel a title level request
    * def extUserId = call uuid1
    * def extItemId = call uuid1

    # enable tlr feature
    * def extTlrConfigId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@EnableTlrFeature') { extConfigId: #(extTlrConfigId) }

    # post users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #('FAT-1511UBC'), extGroupId: #(fourthUserGroupId) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #('FAT-1511IBC') }

    # post a page tlr
    * def extRequestId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostTitleLevelRequest') { requestId: #(extRequestId), requesterId: #(extUserId), extInstanceId: #(instanceId) }

    # post a cancellation reason
    * def extCancellationReasonId = call uuid1
    * def cancellationReasonRequest = read('classpath:vega/mod-circulation/features/samples/cancellation-reason-entity-request.json')
    * cancellationReasonRequest.id = extCancellationReasonId
    Given path 'cancellation-reason-storage', 'cancellation-reasons'
    And request cancellationReasonRequest
    When method POST
    Then status 201
    And match $.id == extCancellationReasonId

    # cancel the request
    * def cancelRequestEntityRequest = read('classpath:vega/mod-circulation/features/samples/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = extCancellationReasonId
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

    # disable tlr feature
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteTlrFeature') { extConfigId: #(extTlrConfigId) }