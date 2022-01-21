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

    # post an user
#    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(fourthUserGroupId)' }
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

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy allows recalls, but item is of status Available, Recently returned, Missing, In process (not requestable)", "Declared lost", "Lost and paid", "Aged to lost", "Claimed returned", "Missing from ASR", "Long missing", "Retrieving from ASR", "Withdrawn", "Order closed", "Intellectual item", "Unavailable", or "Unknown"
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'electronic resource 6'
    * def userBarcode = 'FAT-1035UBC'
    * def itemBarcode = 'FAT-1035IBC'
    * def extStatusName = 'Missing'

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceId: #(extInstanceId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extMaterialTypeId: #(extMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode), extGroupId: #(fourthUserGroupId) }

    # post a request and verify that the user is not allowed to create a page request
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
