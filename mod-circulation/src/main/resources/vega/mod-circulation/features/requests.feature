Feature: Requests tests

  Background:
    * url baseUrl
    * def itemId = call uuid1
    * def servicePointId = call uuid1
    * def userId = call uuid1
    * def groupId = call uuid1
    * def instanceId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy disallows pages
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource'
    * def userBarcode = 'FAT-1030UBC'
    * def itemBarcode = 'FAT-1030IBC'

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceTypeId: #(extInstanceTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(firstUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode), extGroupId: #(firstUserGroupId) }

    # post a request and verify that the user is not allowed to create a page request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = extHoldingsRecordId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Page requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a hold request when the applicable request policy disallows holds
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 2'
    * def userBarcode = 'FAT-1031UBC'
    * def itemBarcode = 'FAT-1031IBC'

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(secondUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode), extGroupId: #(secondUserGroupId)  }

    # post a request and verify that the user is not allowed to create a hold request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Hold'
    * requestEntityRequest.holdingsRecordId = extHoldingsRecordId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Hold requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy disallows recalls
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 3'
    * def userBarcode = 'FAT-1032UBC'
    * def itemBarcode = 'FAT-1032IBC'

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(thirdUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode), extGroupId: #(thirdUserGroupId) }

    # post a request and verify that the user is not allowed to create a recall request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Recall'
    * requestEntityRequest.holdingsRecordId = extHoldingsRecordId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Recall requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy allows pages, but items is not of status Available or Recently returned
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 4'
    * def userBarcode = 'FAT-1033UBC'
    * def itemBarcode = 'FAT-1033IBC'
    * def extStatusName = 'Paged'

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extStatusName: #(extStatusName), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(fourthUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is not allowed to create a page request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.holdingsRecordId = extHoldingsRecordId
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Page requests are not allowed for this patron and item combination'

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
