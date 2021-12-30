Feature: Requests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def materialTypeId = call uuid1
    * def materialTypeName = 'book'
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId) }

    * def loanPolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }

    * def itemId = call uuid1
    * def servicePointId = call uuid1
    * def userId = call uuid1
    * def groupId = call uuid1
    * def instanceId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a page request when the applicable request policy disallows pages
    * def requestPolicyId = call uuid1
    * def groupId = call uuid1
    * def userBarcode = 'FAT-1030UBC'
    * def itemBarcode = 'FAT-1030IBC'
    * def requestId = call uuid1
    * def extRequestTypes = ["Hold", "Recall"]

    # post group, request policy and rule
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId), requestTypes: #(extRequestTypes) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PutRule') { extPatronGroupId: #(groupId), extMaterialTypeId: #(materialTypeId), extLoanPolicyId: #(loanPolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extRequestPolicyId: #(requestPolicyId), extPatronPolicyId: #(patronPolicyId)}

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode) }

    # post a request and verify that the user is not allowed to create a page request
    * def requestId = call uuid1
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Page'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Page requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a hold request when the applicable request policy disallows holds
    * def userBarcode = 'FAT-1031UBC'
    * def itemBarcode = 'FAT-1031IBC'
    * def requestPolicyId = call uuid1
    * def groupId = call uuid1
    * def requestId = call uuid1
    * def extRequestTypes = ["Page", "Recall"]

    # post group, request policy and rule
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId), requestTypes: #(extRequestTypes) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PutRule') { extPatronGroupId: #(groupId), extMaterialTypeId: #(materialTypeId), extLoanPolicyId: #(loanPolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extRequestPolicyId: #(requestPolicyId), extPatronPolicyId: #(patronPolicyId)}

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode) }

    # post a request and verify that the user is not allowed to create a hold request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Hold'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Hold requests are not allowed for this patron and item combination'

  Scenario: Given an item Id, a user Id, and a pickup location, attempt to create a recall request when the applicable request policy disallows recalls
    * def userBarcode = 'FAT-1032UBC'
    * def itemBarcode = 'FAT-1032IBC'
    * def requestPolicyId = call uuid1
    * def groupId = call uuid1
    * def requestId = call uuid1
    * def extRequestTypes = ["Page", "Hold"]

    # post group, request policy and rule
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId), requestTypes: #(extRequestTypes) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PutRule') { extPatronGroupId: #(groupId), extMaterialTypeId: #(materialTypeId), extLoanPolicyId: #(loanPolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extRequestPolicyId: #(requestPolicyId), extPatronPolicyId: #(patronPolicyId)}

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(itemBarcode) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(userId), extUserBarcode: #(userBarcode) }

    # post a request and verify that the user is not allowed to create a recall request
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = userId
    * requestEntityRequest.requestType = 'Recall'
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Recall requests are not allowed for this patron and item combination'
