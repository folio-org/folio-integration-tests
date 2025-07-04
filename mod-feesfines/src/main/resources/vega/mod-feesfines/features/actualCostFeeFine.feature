Feature: Actual cost fee/fine tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }

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
    * overdueFinePolicy.name='mytestPol'
    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    * def patronNoticePolicy = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicy.id = patronNoticePolicyId
    * patronNoticePolicy.name = "mytestpat"
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    * def requestPolicy = read('samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = requestPolicyId
    * requestPolicy.name = "testpolicy"
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # Replace existing circulation rules in order to enable lost item fee policy with actual cost
    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation/rules'
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

  Scenario: Expired actual cost record has the same properties as original open record
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
    * lostItemFeePolicy.name = 'lostItemFeePolicy-' + lostItemFeePolicyId
    * lostItemFeePolicy.lostItemChargeFeeFine.intervalId = "Minutes"
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
    * overdueFinePolicy.name = 'overdueFinePolicy-' + overdueFinePolicyId
    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    * def patronNoticePolicy = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicy.id = patronNoticePolicyId
    * patronNoticePolicy.name = 'patronNoticePolicy-' + patronNoticePolicyId
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    * def requestPolicy = read('samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = requestPolicyId
    * requestPolicy.name = 'requestPolicy-' + requestPolicyId
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # Replace existing circulation rules in order to enable lost item fee policy with actual cost
    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation', 'rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # verify that new circulation rules have been saved
    * configure retry = { count: 10, interval: 1000 }
    Given path 'circulation', 'rules'
    And retry until response.rulesAsText == rules
    When method GET
    Then status 200

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
    * def actualCostRecordPatronGroupId = openActualCostRecord.user.patronGroupId
    * def actualCostRecordPatronGroup = openActualCostRecord.user.patronGroup
    * def actualCostRecordVolume = openActualCostRecord.item.volume
    * def actualCostRecordEnumeration = openActualCostRecord.item.enumeration
    * def actualCostRecordChronology = openActualCostRecord.item.chronology
    * def actualCostRecordCopyNumber = openActualCostRecord.item.copyNumber
    Then match openActualCostRecord.status == 'Open'

    # find current module id for actual-cost-expiration-by-timeout processor delay time
    Given path '/scheduler/timers'
    And param limit = 100
    When method GET
    Then status 200
    * def fun = function(module) { return module.routingEntry.pathPattern == '/circulation/actual-cost-expiration-by-timeout' }
    * def timers = karate.filter(response.timerDescriptors, fun)
    * def timerId = timers[0].id
    * def moduleId = timers[0].moduleId
    * def moduleName = timers[0].moduleName

    # update actual-cost-expiration-by-timeout processor delay time
    * def updateRequest = read('classpath:vega/mod-feesfines/features/samples/update-timer-request.json')
    * updateRequest.id = timerId
    * updateRequest.moduleId = moduleId
    * updateRequest.moduleName = moduleName
    * updateRequest.routingEntry.unit = 'second'
    * updateRequest.routingEntry.delay = '1'
    Given path '/scheduler/timers/'+timerId
    And request updateRequest
    When method PUT
    Then status 200

    # get actual cost record and verify that the record has been expired and has properties mapped in CIRC-1769
    * configure retry = { count: 20, interval: 10000 }
    Given path 'actual-cost-record-storage', 'actual-cost-records'
    And param query = 'loan.id==' + checkOutResponse.response.id
    And retry until response.actualCostRecords[0].status == 'Expired'
    When method GET
    Then status 200
    * def actualCostRecord = response.actualCostRecords[0]
    * def actualCostRecordId = openActualCostRecord.id
    Then match actualCostRecord.user.patronGroupId == actualCostRecordPatronGroupId
    Then match actualCostRecord.user.patronGroup == actualCostRecordPatronGroup
    Then match actualCostRecord.item.volume == actualCostRecordVolume
    Then match actualCostRecord.item.enumeration == actualCostRecordEnumeration
    Then match actualCostRecord.item.chronology == actualCostRecordChronology
    Then match actualCostRecord.item.copyNumber == actualCostRecordCopyNumber

    # revert actual-cost-expiration-by-timeout processor delay time
    * def revertRequest = read('classpath:vega/mod-feesfines/features/samples/update-timer-request.json')
    * revertRequest.id = timerId
    * revertRequest.moduleId = moduleId
    * revertRequest.moduleName = moduleName
    * revertRequest.routingEntry.unit = 'minute'
    * revertRequest.routingEntry.delay = '20'
    Given path '/scheduler/timers/'+timerId
    And request revertRequest
    When method PUT
    Then status 200

    # bring back old circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204