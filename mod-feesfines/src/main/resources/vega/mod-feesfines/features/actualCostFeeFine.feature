Feature: Actual cost fee/fine tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostLocation')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostServicePoint')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostInstance')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostHoldings')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostMaterialType')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostItem')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostPatronGroup')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostUser')
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostOwner')

  Scenario: Cancel actual cost lost item fee
    # Save existing circulation rules
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def oldCirculationRules = response.rulesAsText

    * def overdueFinePolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def loanPolicyId = call uuid1
    * def patronNoticePolicyId = call uuid1
    * def requestPolicyId = call uuid1

    # Create Lost Item Fee Policy with actual cost
    * def lostItemFeePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/lost-item-fee-policy-with-actual-cost-entity-request.json')
    * lostItemFeePolicy.id = lostItemFeePolicyId
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicy
    When method POST
    Then status 201

    * def loanPolicy = read('samples/policies/loan-policy-entity-request.json')
    * loanPolicy.id = loanPolicyId
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicy
    When method POST
    Then status 201

    * def overdueFinePolicy = read('samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicy.id = overdueFinePolicyId
    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    * def patronNoticePolicy = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicy.id = patronNoticePolicyId
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    * def requestPolicy = read('samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = requestPolicyId
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # Replace existing circulation rules in order to enable lost item fee policy with actual cost
    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # check out an item
    * def checkOutResponse = call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostCheckOut')
    * assert checkOutResponse.response.lostItemPolicyId == lostItemFeePolicyId

    # declare item lost
    * call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostDeclareLost') { extLoanId: #(checkOutResponse.response.id) }

    # verify that actual cost record was created
    Given path 'actual-cost-record-storage', 'actual-cost-records'
    And param query = 'loan.id==' + checkOutResponse.response.id
    When method GET
    Then status 200
    * def openActualCostRecord = response.actualCostRecords[0]
    * def actualCostRecordId = openActualCostRecord.id
    Then match openActualCostRecord.status == 'Open'
    Then match openActualCostRecord.additionalInfoForStaff == '#notpresent'
    Then match openActualCostRecord.additionalInfoForPatron == '#notpresent'

    # cancel actual cost fee/fine
    * call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostCancelActualCostFeeFine') { extActualCostRecordId: #(actualCostRecordId) }

    # bring back old circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204