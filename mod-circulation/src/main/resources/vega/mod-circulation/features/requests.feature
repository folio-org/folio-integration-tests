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
    * def localMaterialTypeId = call uuid1
    * def localMaterialTypeName = 'electronic resource'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy disallows pages
    * def extInstanceId = call uuid1
    * def extHoldingsRecordId = call uuid1
    * def userBarcode = 'FAT-1030UBC'
    * def itemBarcode = 'FAT-1030IBC'

    # post a material type
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(localMaterialTypeId), extMaterialTypeName: #(localMaterialTypeName) }

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extInstanceTypeId: #(extInstanceTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode), extMaterialTypeId: #(localMaterialTypeId), extHoldingsRecordId: #(extHoldingsRecordId) }

    # post a group and an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(userGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode), extGroupId: #(userGroupId) }

    # post a request and verify that the user are not allowed to create a page request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Page'
    * requestEntityRequest.requestLevel = 'Item'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Page requests are not allowed for this patron and item combination'
