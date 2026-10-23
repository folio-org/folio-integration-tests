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

    # get sidecar-module-access-client token (has elevated system permissions to see/modify scheduler timers)
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken

    # find or create actual-cost-expiration-by-timeout timer with 1 second delay
    * def updateResult = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@UpdateActualCostExpirationTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * def currentTimerId = updateResult.currentTimerId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

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

    # cleanup: delete timer if it was created by this test, otherwise revert delay to 20 minutes
    * if (updateResult.currentTimerCreated) karate.call('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@DeleteActualCostExpirationTimer', { extToken: sidecarToken, extTimerId: currentTimerId })
    * if (!updateResult.currentTimerCreated) karate.call('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@UpdateActualCostExpirationTimer', { extToken: sidecarToken, extTimerId: currentTimerId, extModuleId: updateResult.currentModuleId, extModuleName: updateResult.currentModuleName, extUnit: 'minute', extDelay: '20' })
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # bring back old circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

  @C1464247
  Scenario: Actual cost lost item fee is closed on check-in when Lost item fee policy changed to Set cost after item aged to lost
    * def extItemBarcode = 'FAT-28955IBC'
    * def extUserBarcode = 'FAT-28955UBC'
    * def extLoanDate = '2020-01-01T00:00:00.000Z'
    * def billedAmount = 15.00
    * def setCostAmount = 20.00

    # create a fresh item and user for this scenario (independent of the Background's shared item/user,
    # so fresh IDs must be supplied - @PostItem/@PostUser otherwise default to the Background's fixed IDs
    # which were already consumed by the Background's callonce item/user)
    * def extItemId = call uuid1
    * def extPermanentLoanTypeId = call uuid1
    * def extUserId = call uuid1
    * call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode), extItemId: #(extItemId), extPermanentLoanTypeId: #(extPermanentLoanTypeId) }
    * call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

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

    # Create Lost Item Fee Policy with actual cost, short aging/billing intervals and no overdue charge on return
    * def lostItemFeePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/lost-item-fee-policy-with-actual-cost-entity-request.json')
    * lostItemFeePolicy.id = lostItemFeePolicyId
    * lostItemFeePolicy.name = 'lostItemFeePolicy-' + lostItemFeePolicyId
    * lostItemFeePolicy.itemAgedLostOverdue = { duration: 1, intervalId: 'Minutes' }
    * lostItemFeePolicy.patronBilledAfterAgedLost = { duration: 1, intervalId: 'Minutes' }
    * lostItemFeePolicy.lostItemChargeFeeFine = { duration: 6, intervalId: 'Weeks' }
    * lostItemFeePolicy.lostItemReturned = 'Remove'
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicy
    When method POST
    Then status 201

    # Short term loan policy (loan period = 1 minute)
    * def loanPolicy = read('samples/policies/loan-policy-entity-request.json')
    * loanPolicy.id = loanPolicyId
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicy
    When method POST
    Then status 201

    # Overdue fine policy with 0 amount
    * def overdueFinePolicy = read('samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicy.id = overdueFinePolicyId
    * overdueFinePolicy.name = 'overdueFinePolicy-' + overdueFinePolicyId
    * overdueFinePolicy.overdueFine.quantity = 0.0
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

    # Replace existing circulation rules in order to enable created policies
    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation/rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    # check out the item with a loan date in the distant past so it is already overdue
    * def checkOutResponse = call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostCheckOut') { extUserBarcode: #(extUserBarcode), extItemBarcode: #(extItemBarcode), extLoanDate: #(extLoanDate) }
    * assert checkOutResponse.response.lostItemPolicyId == lostItemFeePolicyId
    * def extLoanId = checkOutResponse.response.id

    # get sidecar-module-access-client token (has elevated system permissions to see/modify scheduler timers)
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken

    # speed up the age-to-lost timer so the item ages to lost within seconds instead of 30 minutes
    * def ageToLostTimerResult = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@UpdateAgeToLostTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # speed up the age-to-lost-fee-charging timer so actual cost billing becomes due within seconds instead of 35 minutes
    * def feeChargingTimerResult = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@UpdateAgeToLostFeeChargingTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # wait until the item is aged to lost
    * configure retry = { count: 15, interval: 3000 }
    Given path 'loan-storage', 'loans', extLoanId
    And retry until response.itemStatus == 'Aged to lost'
    When method GET
    Then status 200

    # wait until an open actual cost record requiring billing is created for the loan (patronBilledAfterAgedLost elapses)
    * configure retry = { count: 30, interval: 3000 }
    Given path 'actual-cost-record-storage', 'actual-cost-records'
    And param query = 'loan.id==' + extLoanId
    And retry until karate.sizeOf(response.actualCostRecords) > 0 && response.actualCostRecords[0].status == 'Open'
    When method GET
    Then status 200
    * def openActualCostRecord = response.actualCostRecords[0]
    * def actualCostRecordId = openActualCostRecord.id
    Then match openActualCostRecord.lossType == 'Aged to lost'

    # bill actual cost for the aged to lost item (Users app -> Lost items requiring actual cost -> Bill actual cost)
    * def billActualCostFeeFineRequest = { actualCostRecordId: '#(actualCostRecordId)', amount: '#(billedAmount)', servicePointId: '#(servicePointId)' }
    Given path 'actual-cost-fee-fine', 'bill'
    And request billActualCostFeeFineRequest
    When method POST
    Then status 201
    Then match response.status == 'Billed'
    * def lostItemFeeAccountId = response.feeFine.accountId

    # verify the lost item fee (actual cost) account was created with the billed amount
    Given path 'accounts'
    And param query = 'loanId==' + extLoanId
    When method GET
    Then status 200
    * def lostItemFeeAccount = response.accounts[0]
    Then match lostItemFeeAccount.id == lostItemFeeAccountId
    Then match lostItemFeeAccount.feeFineType == 'Lost item fee (actual cost)'
    Then match lostItemFeeAccount.amount == billedAmount
    Then match lostItemFeeAccount.remaining == billedAmount
    Then match lostItemFeeAccount.status.name == 'Open'

    # after actual cost was billed, change the Lost item fee policy from Actual cost to Set cost with a positive amount
    * lostItemFeePolicy.chargeAmountItem = { chargeType: 'anotherCost', amount: setCostAmount }
    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    And request lostItemFeePolicy
    When method PUT
    Then status 204

    # check in the item
    * def checkInResponse = call read('classpath:vega/mod-feesfines/features/util/initData.feature@CheckInItem') { extItemBarcode: #(extItemBarcode), extServicePointId: #(servicePointId) }
    And match checkInResponse.response.loan.id == extLoanId

    # verify the actual cost lost item fee was closed (cancelled item returned) with $0 remaining, not re-priced to the new Set cost amount
    Given path 'accounts'
    And param query = 'loanId==' + extLoanId
    When method GET
    Then status 200
    * def closedLostItemFeeAccount = response.accounts[0]
    Then match closedLostItemFeeAccount.id == lostItemFeeAccountId
    Then match closedLostItemFeeAccount.feeFineType == 'Lost item fee (actual cost)'
    Then match closedLostItemFeeAccount.amount == billedAmount
    Then match closedLostItemFeeAccount.remaining == 0
    Then match closedLostItemFeeAccount.status.name == 'Closed'
    Then match closedLostItemFeeAccount.paymentStatus.name == 'Cancelled item returned'

    # verify the fee/fine action history: the original billing action plus the closing "Cancelled item returned" action
    Given path 'feefineactions'
    And param query = 'accountId==' + lostItemFeeAccountId
    When method GET
    Then status 200
    * def feeFineActions = karate.sort(response.feefineactions, (action) => action.dateAction)
    Then match response.totalRecords == 2
    Then match feeFineActions[1].typeAction == 'Cancelled item returned'
    Then match feeFineActions[1].balance == 0

    # cleanup: revert/delete timers if they were created by this test, otherwise revert delay to default
    * if (ageToLostTimerResult.currentTimerCreated) karate.call('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@DeleteAgeToLostTimer', { extToken: sidecarToken, extTimerId: ageToLostTimerResult.currentTimerId })
    * if (!ageToLostTimerResult.currentTimerCreated) karate.call('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@UpdateAgeToLostTimer', { extToken: sidecarToken, extTimerId: ageToLostTimerResult.currentTimerId, extModuleId: ageToLostTimerResult.currentModuleId, extModuleName: ageToLostTimerResult.currentModuleName, extUnit: 'minute', extDelay: '30' })

    * if (feeChargingTimerResult.currentTimerCreated) karate.call('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@DeleteAgeToLostFeeChargingTimer', { extToken: sidecarToken, extTimerId: feeChargingTimerResult.currentTimerId })
    * if (!feeChargingTimerResult.currentTimerCreated) karate.call('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@UpdateAgeToLostFeeChargingTimer', { extToken: sidecarToken, extTimerId: feeChargingTimerResult.currentTimerId, extModuleId: feeChargingTimerResult.currentModuleId, extModuleName: feeChargingTimerResult.currentModuleName, extUnit: 'minute', extDelay: '35' })

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # bring back old circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204