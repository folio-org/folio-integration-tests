Feature: Parallel Checkout Tests
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

    * configure headers = headersUser

    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def itemId = call uuid1
    * def groupId = call uuid1
    * def userId = call uuid1
    * def ownerId = call uuid1
    * def manualChargeId = call uuid1
    * def paymentMethodId = call uuid1
    * def checkOutByBarcodeId = call uuid1
    * def parseObjectToDate = read('classpath:vega/mod-circulation/features/util/parse-object-to-date-function.js')
    * def materialTypeId = call uuid1
    * def materialTypeName = 'e-book1'

    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId) }

     # groups
    * def firstUserGroupId = '188f025c-6e52-11ec-90d6-0242ac120013'
    * def secondUserGroupId = 'f1a28f58-702d-48fe-b95d-daf7fd55dc37'
    * def thirdUserGroupId = '0dfcce3e-6fb3-11ec-90d6-0242ac120013'
    * def fourthUserGroupId = 'a58053e4-6fbc-11ec-90d6-0242ac120013'
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(fourthUserGroupId)' }

    # policies
    * def loanPolicyId = call uuid1
    * def loanPolicyMaterialId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1
    * def requestPolicyIdForGroup = call uuid1
    * def requestPolicyIdForGroup2 = call uuid1
    * def requestPolicyIdForGroup3 = call uuid1
    * def requestPolicyIdForGroup4 = call uuid1
    * def extRequestTypesForSecondUserGroupRequestPolicy = ["Page", "Recall"]
    * def extRequestTypesForThirdUserGroupRequestPolicy = ["Page", "Hold"]
    * def extRequestTypesForFirstUserGroupRequestPolicy = ["Hold", "Recall"]

    * def extFallbackPolicy = { loanPolicyId: #(loanPolicyId), lostItemFeePolicyId: #(lostItemFeePolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), patronPolicyId: #(patronPolicyId), requestPolicyId: #(requestPolicyId) }
    * def extMaterialTypePolicy = { materialTypeId: #(materialTypeId), loanPolicyId: #(loanPolicyMaterialId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyId), patronPolicyId: #(patronPolicyId) }
    * def extFirstGroupPolicy = { userGroupId: #(firstUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup), patronPolicyId: #(patronPolicyId) }
    * def extSecondGroupPolicy = { userGroupId: #(secondUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup2), patronPolicyId: #(patronPolicyId) }
    * def extThirdGroupPolicy = { userGroupId: #(thirdUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup3), patronPolicyId: #(patronPolicyId) }
    * def extFourthGroupPolicy = { userGroupId: #(fourthUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup4), patronPolicyId: #(patronPolicyId) }

    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicyWithLimit') { extLoanPolicyId: #(loanPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicyWithLimit') { extLoanPolicyId: #(loanPolicyMaterialId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup), extRequestTypes: #(extRequestTypesForFirstUserGroupRequestPolicy) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup2), extRequestTypes: #(extRequestTypesForSecondUserGroupRequestPolicy) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup3), extRequestTypes: #(extRequestTypesForThirdUserGroupRequestPolicy) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup4) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRulesWithMaterialTypeAndGroup') extFallbackPolicy, extMaterialTypePolicy, extFirstGroupPolicy, extSecondGroupPolicy, extThirdGroupPolicy, extFourthGroupPolicy

    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-793UBC'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-793IBC'


    * def extItemId1 = call uuid1
    * def extItemBarcode1 = 'FAT-593IBC'

    # location and service point setup
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(materialTypeId)}
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId1), extItemBarcode: #(extItemBarcode1), extMaterialTypeId: #(materialTypeId)}

    # post a group and a user
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(groupId) }

  @CheckOutItem
  Scenario: Checkout first item
    * def extItemBarcode = 'FAT-793IBC'
    * def extUserBarcode = 'FAT-793UBC'

    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }
#    And retry until checkOutResponse == 201

#    # get the loan and verify that correct loan-policy has been applied
#    Given path 'circulation', 'loans'
#    And param query = '(userId==' + extUserId + ' and ' + 'itemId==' + extItemId + ')'
#    When method GET
#    Then status 200
#    And match response.loans[0].id == checkOutResponse.response.id
#    And match response.loans[0].loanPolicyId == loanPolicyMaterialId

  @CheckOutSecondItem
  Scenario: Checkout Second item
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-793UBC'
    * def extItemId = call uuid1
    * def extItemBarcode = 'FAT-093IBC'
    * def extInstanceTypeId = call uuid3
    * def extInstitutionId = call uuid2
    * def extHoldingsRecordId = call uuid3
    * def extCampusId = call uuid1
    * def extLibraryId = call uuid1
    * def extInstanceId = call uuid3


    # post an item

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId), extInstanceId: #(extInstanceId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingsRecordId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(materialTypeId)}


    # checkOut the item for the user
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

#    * configure retry = { count: 10, interval: 1000 }
#    * def extUserBarcode = 'FAT-793UBC'
#    * def extItemBarcode1 = 'FAT-593IBC'
    # checkOut the item for the user

#    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode1) }
#    And retry until checkOutResponse == 201