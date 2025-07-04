Feature: Parallel Checkout Tests
  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)','Accept': '*/*' }
    * configure headers = headersUser
    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
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

     # settings
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostSettings')

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

    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicyWithLimit') { extLoanPolicyId: #(loanPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicyWithLimit') { extLoanPolicyId: #(loanPolicyMaterialId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@UpdateRules') extFallbackPolicy, extMaterialTypePolicy

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

  Scenario: Checkout first item
    * print "1st item checkout start"
    * def intLoanDate = '2021-10-27T13:25:46.000Z'
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = 'FAT-793IBC'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    * checkOutByBarcodeEntityRequest.loanDate = intLoanDate
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    * print "1st item checkout end"


  Scenario: Checkout Second item
    * print "2nd item checkout start"
    * def intLoanDate = '2021-10-27T13:25:46.000Z'
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = 'FAT-593IBC'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    * checkOutByBarcodeEntityRequest.loanDate = intLoanDate
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    * print "2nd item checkout end"

  Scenario: Check loan count
    # Checking only one checkout is happened when 2 parallel request are triggered with loan limit 1.
    * print "loan count check start"
    * call pause 5000
    Given path 'circulation', 'loans'
    And param query = '(userId=="' + extUserId + '")'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, loans: #present }
    And match response.totalRecords == 1
    * def checkedOutItemBarcode = response.loans[0].item.barcode
    * assert (checkedOutItemBarcode == 'FAT-593IBC') || (checkedOutItemBarcode == 'FAT-793IBC')
    * print "loan count check end"
