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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
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

  # This scenario does not cover testing for item with status 'Available in ASR' due to lack of implementation
  Scenario Outline: Requests: Given an item Id, a user Id, and a pickup location, attempt to create a hold request when the applicable request policy allows holds and item status is not "Available", "Recently returned", "In process (not requestable)", "Declared lost", "Lost and paid", "Aged to lost", "Claimed returned", "Missing from ASR", "Long missing", "Retrieving from ASR", "Withdrawn", "Order closed", "Intellectual item", "Unavailable", or "Unknown"
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def extMaterialTypeId = call uuid1

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(<materialTypeName>) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(<itemBarcode>), extStatusName: #(<itemStatus>), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(<userBarcode>), extGroupId: #(firstUserGroupId) }

    # post a request and verify that the user is allowed to create a hold request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Hold'
    * requestEntityRequest.holdingsRecordId = extHoldingsRecordId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.item.barcode == <itemBarcode>
    And match response.requester.barcode == <userBarcode>

    Given path 'circulation', 'requests', requestId
    When method DELETE
    Then status 204

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
