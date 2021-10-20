Feature: Loans tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def materialTypeId = call uuid1
    * def itemId = call uuid1
    * def loanPolicyId = call uuid1
    * def loanPolicyMaterialId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1
    * def groupId = call uuid1
    * def userId = call uuid1
    * def checkOutByBarcodeId = call uuid1

  Scenario: When patron and item id's entered at checkout, post a new loan using the circulation rule matched

    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { varItemBarcode: 666666, varMaterialTypeId: #(materialTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { varLoanPolicyId: #(loanPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { varLoanPolicyId: #(loanPolicyMaterialId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLostPolicy') { varLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostOverduePolicy') { varOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPatronPolicy') { varPatronPolicyId8: #(patronPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRequestPolicy') { varRequestPolicyId: #(requestPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRulesWithMaterial') { varLoanPolicyId: #(loanPolicyId), varLostItemFeePolicyId: #(lostItemFeePolicyId), varOverdueFinePoliciesId: #(overdueFinePoliciesId), varPatronPolicyId: #(patronPolicyId), varRequestPolicyId: #(requestPolicyId), varMaterialTypeId: #(materialTypeId), varLoanPolicyMaterialId: #(loanPolicyMaterialId), varOverdueFinePoliciesMaterialId: #(overdueFinePoliciesId), varLostItemFeePolicyMaterialId: #(lostItemFeePolicyId), varRequestPolicyMaterialId: #(requestPolicyId), varPatronPolicyMaterialId: #(patronPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { varUserBarcode: 55555 }

    # checkOut
    * def checkOutResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { varCheckOutUserBarcode: 55555, varCheckOutItemBarcode: 666666 }

    # get loan and verify
    Given path 'circulation', 'loans'
    And param query = '(userId==' + userId + ' and ' + 'itemId==' + itemId + ')'
    When method GET
    Then status 200
    And match response.loans[0].id == checkOutResponse.response.id
    And match response.loans[0].loanPolicyId == loanPolicyMaterialId
