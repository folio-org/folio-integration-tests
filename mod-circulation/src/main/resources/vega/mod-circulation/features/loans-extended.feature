Feature: Loans tests - extended

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
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

  @C9218
  Scenario: When loan anonymization is set to "Immediately after loan closes" with "Treat closed loans with fee/fines differently" enabled and "Immediately after fee/fine closes", closed loans without fee/fines and loans whose fee/fines are paid are both anonymized by the scheduler
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-1054UBC'
    * def extItemBarcode1 = 'FAT-1054IBC-1'
    * def extItemBarcode2 = 'FAT-1054IBC-2'
    # item 1 check-in is before the due date -> no overdue fine
    * def extCheckInDate1 = '2021-11-10T13:25:46.000Z'
    # item 2 check-in is 5 minutes after the due date -> generates overdue fine
    * def extCheckInDate2 = '2021-11-17T13:30:46.000Z'

    # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an owner, manual charge and payment method (required for overdue fine generation)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostManualCharge')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPaymentMethod')

    # post 2 items under the same instance and holdings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode2) }

    # post a group and a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode) }

    # step 2: configure loan history settings
    # delete existing loan_history settings if present, then create fresh ones
    Given path 'circulation/settings'
    And param query = 'name=="loan_history"'
    When method GET
    Then status 200
    * def existingSettings = response.circulationSettings
    * def existingSettingId = existingSettings.length > 0 ? existingSettings[0].id : null
    * if (existingSettingId != null) karate.call('classpath:vega/mod-circulation/features/util/initData.feature@DeleteCirculationSetting', { settingId: existingSettingId })

    # create new settings: anonymize immediately after loan closes, treat fee/fines differently,
    # anonymize fee/fines immediately after close
    Given path 'circulation', 'settings'
    And request
    """
    {
      "name": "loan_history",
      "value": {
        "closingType": {
          "loan": "immediately",
          "feeFine": "immediately",
          "loanExceptions": []
        },
        "loan": {},
        "feeFine": {},
        "loanExceptions": [],
        "treatEnabled": true
      }
    }
    """
    When method POST
    Then status 201
    * def loanHistorySettingsId = response.id

    # check out both items (both use the default loan date '2021-10-27T13:25:46.000Z')
    * def checkOutResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode1) }
    * def loanId1 = checkOutResponse1.response.id
    * def checkOutResponse2 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode2) }
    * def loanId2 = checkOutResponse2.response.id

    # check in item 1 before due date (no overdue fine generated)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode1), extCheckInDate: #(extCheckInDate1) }

    # check in item 2 after due date (overdue fine generated)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode2), extCheckInDate: #(extCheckInDate2) }

    # verification: both loans appear in patron's closed loans
    Given path 'circulation', 'loans'
    And param query = 'userId==' + extUserId + ' and status.name=="Closed"'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    # get the overdue fine associated with the 2nd loan and close it by paying
    Given path 'accounts'
    And param query = 'loanId==' + loanId2
    When method GET
    Then status 200
    And assert response.totalRecords >= 1
    And match response.accounts[0].status.name == 'Open'
    And match response.accounts[0].feeFineType == 'Overdue fine'
    * def overdueFineAccountId = response.accounts[0].id
    * def overdueFineAmount = response.accounts[0].amount

    # pay the fee/fine in full to close it
    * def payResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPay') { accountId: #(overdueFineAccountId), amount: #(overdueFineAmount) }
    And match payResult.response.feefineactions[0].typeAction == 'Paid fully'

    # verify the fee/fine account is now closed
    Given path 'accounts'
    And param query = 'id==' + overdueFineAccountId
    When method GET
    Then status 200
    And match response.accounts[0].status.name == 'Closed'

    # step 5: trigger loan anonymization by updating the scheduler timer to 1 second delay
    # get sidecar-module-access-client token (has elevated system permissions to see/modify scheduler timers)
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken

    # find or create loan anonymization timer with 1 second delay
    * def updateResult = call read('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateLoanAnonymizationTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * def currentTimerId = updateResult.currentTimer.id

    # verification: both closed loans are anonymized (userId field should be removed)
    * configure retry = { count: 15, interval: 3000 }
    Given path 'loan-storage', 'loans', loanId1
    And retry until response.userId == null || response.userId == undefined
    When method GET
    Then status 200
    And match $.userId == '#notpresent'

    Given path 'loan-storage', 'loans', loanId2
    And retry until response.userId == null || response.userId == undefined
    When method GET
    Then status 200
    And match $.userId == '#notpresent'

    # cleanup: revert timer and delete loan history settings
    * if (updateResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@DeleteLoanAnonymizationTimer', { extToken: sidecarToken, extTimerId: currentTimerId })
    * if (!updateResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateLoanAnonymizationTimer', { extToken: sidecarToken, extTimerId: currentTimerId, extModuleId: updateResult.currentModuleId, extModuleName: updateResult.currentModuleName, extUnit: 'minute', extDelay: '60' })
    * configure headers = headersUser
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteCirculationSetting') { settingId: #(loanHistorySettingsId) }

  @C9221
  Scenario: Loan is anonymized 1 hour after the overdue fine is closed
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-23836-USER'
    * def extItemBarcode1 = 'FAT-23836-ITEM-1'
    * def extItemBarcode2 = 'FAT-23836-ITEM-2'
    # item 1 check-in is before the due date -> no overdue fine
    * def extCheckInDate1 = '2021-11-10T13:25:46.000Z'
    # item 2 check-in is 5 minutes after the due date -> generates overdue fine
    * def extCheckInDate2 = '2021-11-17T13:30:46.000Z'

    # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an owner, manual charge and payment method (required for overdue fine generation)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostManualCharge')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPaymentMethod')

    # post 2 items under the same instance and holdings
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode2) }

    # post a group and a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode) }

    # step 2: configure loan history settings
    # delete existing loan_history settings if present, then create fresh ones
    Given path 'circulation/settings'
    And param query = 'name=="loan_history"'
    When method GET
    Then status 200
    * def existingSettings = response.circulationSettings
    * def existingSettingId = existingSettings.length > 0 ? existingSettings[0].id : null
    * if (existingSettingId != null) karate.call('classpath:vega/mod-circulation/features/util/initData.feature@DeleteCirculationSetting', { settingId: existingSettingId })

    # create new settings: anonymize loan after overdue fine is closed
    Given path 'circulation', 'settings'
    And request
    """
    {
      "name": "loan_history",
      "value": {
        "closingType": {
          "loan": "immediately",
          "feeFine": "interval",
          "loanExceptions": []
        },
        "loan": {},
        "feeFine": {
          "duration": 1,
          "intervalId": "hour"
        },
        "loanExceptions": [],
        "treatEnabled": true
      }
    }
    """
    When method POST
    Then status 201
    * def loanHistorySettingsId = response.id

    # check out both items (both use the default loan date '2021-10-27T13:25:46.000Z')
    * def checkOutResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode1) }
    * def loanId1 = checkOutResponse1.response.id
    * def checkOutResponse2 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode2) }
    * def loanId2 = checkOutResponse2.response.id

    # check in item 1 before due date (no overdue fine generated)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode1), extCheckInDate: #(extCheckInDate1) }

    # check in item 2 after due date (overdue fine generated)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode2), extCheckInDate: #(extCheckInDate2) }

    # verification: both loans appear in patron's closed loans
    Given path 'circulation', 'loans'
    And param query = 'userId==' + extUserId + ' and status.name=="Closed"'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    # get the overdue fine associated with the 2nd loan and close it by paying
    Given path 'accounts'
    And param query = 'loanId==' + loanId2
    When method GET
    Then status 200
    And assert response.totalRecords >= 1
    And match response.accounts[0].status.name == 'Open'
    And match response.accounts[0].feeFineType == 'Overdue fine'
    * def overdueFineAccountId = response.accounts[0].id
    * def overdueFineAmount = response.accounts[0].amount

    # pay the fee/fine in full to close it
    * def payResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPay') { accountId: #(overdueFineAccountId), amount: #(overdueFineAmount) }
    And match payResult.response.feefineactions[0].typeAction == 'Paid fully'

    # verify the fee/fine account is now closed
    Given path 'accounts'
    And param query = 'id==' + overdueFineAccountId
    When method GET
    Then status 200
    And match response.accounts[0].status.name == 'Closed'

    # get overdue fine action for cancellation
    Given path 'feefineactions'
    And param query = 'accountId==' + overdueFineAccountId + ' and typeAction=="Paid fully"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def feeFineAction = response.feefineactions[0]
    * def feeFineActionId = feeFineAction.id

    # change cancellation action date to avoid waiting for 1 minute until anonymization kicks in
    * feeFineAction.dateAction = '2020-01-10T00:00:00.000Z'
    Given path 'feefineactions', feeFineActionId
    And request feeFineAction
    When method PUT
    Then status 204

    # step 5: trigger loan anonymization by updating the scheduler timer to 1 second delay
    # get sidecar-module-access-client token (has elevated system permissions to see/modify scheduler timers)
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken

    # find or create loan anonymization timer with 1 second delay
    * def updateResult = call read('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateLoanAnonymizationTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * def currentTimerId = updateResult.currentTimer.id

    # verification: both closed loans are anonymized (userId field should be removed)
    * configure retry = { count: 15, interval: 3000 }
    Given path 'loan-storage', 'loans', loanId1
    And retry until response.userId == null || response.userId == undefined
    When method GET
    Then status 200
    And match $.userId == '#notpresent'

    Given path 'loan-storage', 'loans', loanId2
    And retry until response.userId == null || response.userId == undefined
    When method GET
    Then status 200
    And match $.userId == '#notpresent'

    # cleanup: revert timer and delete loan history settings
    * if (updateResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@DeleteLoanAnonymizationTimer', { extToken: sidecarToken, extTimerId: currentTimerId })
    * if (!updateResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateLoanAnonymizationTimer', { extToken: sidecarToken, extTimerId: currentTimerId, extModuleId: updateResult.currentModuleId, extModuleName: updateResult.currentModuleName, extUnit: 'minute', extDelay: '60' })
    * configure headers = headersUser
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeleteCirculationSetting') { settingId: #(loanHistorySettingsId) }

  @C1464246
  Scenario: Check in an aged to lost item whose actual cost was billed - lost item fee is cancelled with "Cancelled item returned" payment status
    * def extUserId = call uuid1
    * def extUserBarcode = 'FAT-C1464246-USER'
    * def extItemBarcode = 'FAT-C1464246-ITEM'
    * def extMaterialTypeId = call uuid1
    * def extMaterialTypeName = 'C1464246 material ' + random_string()
    * def extGroupId = call uuid1
    * def extLoanPolicyId = call uuid1
    * def extOverduePolicyId = call uuid1
    * def extLostPolicyId = call uuid1
    * def extPatronPolicyId = call uuid1
    * def extRequestPolicyId = call uuid1
    # old loan date -> loan is already overdue, so the age-to-lost timer picks it up immediately
    * def extLoanDate = '2020-01-01T00:00:00.000Z'
    * def actualCostAmount = 25.00

    # location, service point, owner (the backend resolves the owner from the service point when billing)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')

    # material type, group, item and user without fees/fines
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId), extMaterialTypeName: #(extMaterialTypeName) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(extGroupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(extMaterialTypeId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(extGroupId) }

    # policies: loan, overdue fine, lost item fee (aged to lost after 1 min, billed after 1 min, actual cost), notice, request
    * def loanPolicyId = extLoanPolicyId
    * def overdueFinePoliciesId = extOverduePolicyId
    * def patronPolicyId = extPatronPolicyId
    * def requestPolicyId = extRequestPolicyId
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(extLoanPolicyId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(extOverduePolicyId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLostPolicyActualCost') { extLostItemFeePolicyId: #(extLostPolicyId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(extPatronPolicyId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(extRequestPolicyId) }

    # circulation rule for the material type + patron group (appended to the existing rules; restored in cleanup)
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def originalRulesAsText = response.rulesAsText
    # always restore timers and circulation rules, even if a step below fails (a leftover 1 second age-to-lost timer ages every overdue loan of the tenant)
    * configure afterScenario = read('classpath:vega/mod-circulation/features/util/restore-timers-and-rules-function.js')
    * def newRule = 'm ' + extMaterialTypeId + ' + g ' + extGroupId + ': l ' + extLoanPolicyId + ' o ' + extOverduePolicyId + ' i ' + extLostPolicyId + ' r ' + extRequestPolicyId + ' n ' + extPatronPolicyId
    * def newRulesAsText = originalRulesAsText + '\n' + newRule
    Given path 'circulation', 'rules'
    And request { rulesAsText: '#(newRulesAsText)' }
    When method PUT
    Then status 204

    # preconditions: check out the item to the patron
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode), extLoanDate: #(extLoanDate) }
    * def loanId = checkOutResponse.response.id
    And match checkOutResponse.response.lostItemPolicyId == extLostPolicyId

    # sidecar token has elevated permissions to see/modify scheduler timers
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken

    # preconditions: item becomes "Aged to lost" - age-to-lost timer set to 1 second
    * def ageToLostResult = call read('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateAgeToLostTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * def ageToLostTimer = ageToLostResult.currentTimer
    # the timer object above is mutated by the update (shared scope), so restore to the module descriptor defaults instead (age-to-lost: 30 minutes)
    * def ageToLostOriginal = { unit: 'minute', delay: '30' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 3000 }
    Given path 'loan-storage', 'loans', loanId
    And retry until response.itemStatus == 'Aged to lost'
    When method GET
    Then status 200

    # preconditions: actual cost record is created once "patron billed after aged to lost" (1 min) has passed - fee-charging timer set to 1 second
    * def feeChargingResult = call read('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateAgeToLostFeeChargingTimer') { extToken: #(sidecarToken), extUnit: 'second', extDelay: '1' }
    * def feeChargingTimer = feeChargingResult.currentTimer
    # age-to-lost fee-charging default: 35 minutes
    * def feeChargingOriginal = { unit: 'minute', delay: '35' }
    * configure headers = headersUser
    * configure retry = { count: 30, interval: 5000 }
    Given path 'actual-cost-record-storage', 'actual-cost-records'
    And param query = 'loan.id==' + loanId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.actualCostRecords[0].status == 'Open'
    * def actualCostRecordId = response.actualCostRecords[0].id

    # cleanup of timers: delete when created by this test, otherwise restore the original delay
    * if (ageToLostResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@DeleteAgeToLostTimer', { extToken: sidecarToken, extTimerId: ageToLostTimer.id })
    * if (!ageToLostResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateAgeToLostTimer', { extToken: sidecarToken, extTimer: ageToLostTimer, extUnit: ageToLostOriginal.unit, extDelay: ageToLostOriginal.delay })
    * if (feeChargingResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@DeleteAgeToLostFeeChargingTimer', { extToken: sidecarToken, extTimerId: feeChargingTimer.id })
    * if (!feeChargingResult.currentTimerCreated) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@UpdateAgeToLostFeeChargingTimer', { extToken: sidecarToken, extTimer: feeChargingTimer, extUnit: feeChargingOriginal.unit, extDelay: feeChargingOriginal.delay })
    * def timersRestored = true
    * configure headers = headersUser

    # preconditions: bill actual cost ("Lost items requiring actual cost" -> "Bill actual cost")
    * def billRequest = { actualCostRecordId: '#(actualCostRecordId)', servicePointId: '#(servicePointId)', amount: '#(actualCostAmount)', additionalInfoForStaff: 'C1464246 staff info', additionalInfoForPatron: 'C1464246 patron info' }
    Given path 'actual-cost-fee-fine', 'bill'
    And request billRequest
    When method POST
    Then status 201

    Given path 'accounts'
    And param query = 'loanId==' + loanId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.accounts[0].feeFineType == 'Lost item fee (actual cost)'
    And match response.accounts[0].status.name == 'Open'
    And match response.accounts[0].amount == actualCostAmount
    And match response.accounts[0].remaining == actualCostAmount
    * def accountId = response.accounts[0].id

    # step 1: check in the aged to lost item ("Check in aged to lost item?" is confirmed in the UI)
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    And match checkInResponse.response.loan.id == loanId

    # step 2: fee/fine details contain "Lost item fee (actual cost)" and "Cancelled item returned" with $0.00 balance
    Given path 'feefineactions'
    And param query = 'accountId==' + accountId
    And param limit = 100
    When method GET
    Then status 200
    * def actionTypes = karate.map(response.feefineactions, function(a){ return a.typeAction })
    And match actionTypes contains 'Lost item fee (actual cost)'
    And match actionTypes contains 'Cancelled item returned'
    * def cancelledAction = karate.filter(response.feefineactions, function(a){ return a.typeAction == 'Cancelled item returned' })[0]
    And match cancelledAction.balance == 0
    * def billedAction = karate.filter(response.feefineactions, function(a){ return a.typeAction == 'Lost item fee (actual cost)' })[0]
    And match billedAction.amountAction == actualCostAmount

    # step 3: the account is closed, with "Cancelled item returned" payment status, billed amount unchanged, remaining $0.00
    Given path 'accounts', accountId
    When method GET
    Then status 200
    And match response.status.name == 'Closed'
    And match response.paymentStatus.name == 'Cancelled item returned'
    And match response.amount == actualCostAmount
    And match response.remaining == 0

    # cleanup: restore circulation rules
    Given path 'circulation', 'rules'
    And request { rulesAsText: '#(originalRulesAsText)' }
    When method PUT
    Then status 204
    * def rulesRestored = true
