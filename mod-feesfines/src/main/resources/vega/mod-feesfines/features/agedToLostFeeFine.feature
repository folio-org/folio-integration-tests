Feature: Aged to lost fee/fine tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # unique identifiers, so the test does not collide with data created by other features in the same tenant
    * def uniqueSuffix = random_string()
    * def testInstitutionId = call uuid1
    * def testCampusId = call uuid1
    * def testLibraryId = call uuid1
    * def testLocationId = call uuid1
    * def testServicePointId = call uuid1
    * def testInstanceTypeId = call uuid1
    * def testContributorNameTypeId = call uuid1
    * def testInstanceId = call uuid1
    * def testHoldingsId = call uuid1
    * def testHoldingSourceId = call uuid1
    * def testMaterialTypeId = call uuid1
    * def testLoanTypeId = call uuid1
    * def testItemId = call uuid1
    * def testPatronGroupId = call uuid1
    * def testUserId = call uuid1
    * def testOwnerId = call uuid1
    * def testCheckOutId = call uuid1
    * def testItemBarcode = 'aged.lost.item.' + uniqueSuffix
    * def testUserBarcode = 'aged.lost.user.' + uniqueSuffix

    * def initDataArgs =
    """
    {
      extInstitutionId: '#(testInstitutionId)',
      extCampusId: '#(testCampusId)',
      extLibraryId: '#(testLibraryId)',
      extLocationId: '#(testLocationId)',
      extServicePointId: '#(testServicePointId)',
      extInstanceTypeId: '#(testInstanceTypeId)',
      extContributorNameTypeId: '#(testContributorNameTypeId)',
      extContributorNameTypeName: '#("contributor-name type " + uniqueSuffix)',
      extInstanceId: '#(testInstanceId)',
      extHoldingsRecordId: '#(testHoldingsId)',
      id: '#(testHoldingSourceId)',
      sourceId: '#(testHoldingSourceId)',
      extHoldingSourceName: '#(uniqueSuffix)',
      extMaterialTypeId: '#(testMaterialTypeId)',
      extMaterialTypeName: '#("material " + uniqueSuffix)',
      extPermanentLoanTypeId: '#(testLoanTypeId)',
      extItemId: '#(testItemId)',
      extItemBarcode: '#(testItemBarcode)',
      extPatronGroupId: '#(testPatronGroupId)',
      extUserId: '#(testUserId)',
      extUserBarcode: '#(testUserBarcode)',
      extOwnerId: '#(testOwnerId)'
    }
    """

    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostLocation') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostServicePoint') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostInstance') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostHoldings') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostMaterialType') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostItem') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostPatronGroup') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostUser') initDataArgs
    * callonce read('classpath:vega/mod-feesfines/features/util/initData.feature@PostOwner') initDataArgs

  @C1504471
  Scenario: C1504471 Check in aged to lost item with Set cost lost item fee policy changed to Actual cost, lost item fee is cancelled
    # Save existing circulation rules
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def oldCirculationRules = response.rulesAsText

    * def loanPolicyId = call uuid1
    * def overdueFinePolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def patronNoticePolicyId = call uuid1
    * def requestPolicyId = call uuid1

    # Short term loan policy (loan period = 1 minute)
    * def loanPolicy = read('classpath:vega/mod-feesfines/features/samples/policies/loan-policy-entity-request.json')
    * loanPolicy.name = 'agedToLostLoanPolicy-' + loanPolicyId
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicy
    When method POST
    Then status 201

    # Overdue fine policy with 0 amount
    * def overdueFinePoliciesId = overdueFinePolicyId
    * def overdueFinePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicy.name = 'agedToLostOverdueFinePolicy-' + overdueFinePolicyId
    * overdueFinePolicy.overdueFine.quantity = 0.0
    * overdueFinePolicy.overdueRecallFine.quantity = 0.0
    * overdueFinePolicy.maxOverdueFine = 0.0
    * overdueFinePolicy.maxOverdueRecallFine = 0.0
    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    # Lost item fee policy: aged to lost after 1 minute, patron billed after 1 minute, Set cost 100.00
    * def lostItemFeePolicyName = 'agedToLostLostItemFeePolicy-' + lostItemFeePolicyId
    * def lostItemFeePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/lost-item-fee-policy-aged-to-lost-entity-request.json')
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicy
    When method POST
    Then status 201

    * def patronNoticePolicyName = 'agedToLostPatronNoticePolicy-' + patronNoticePolicyId
    * def patronPolicyId = patronNoticePolicyId
    * def patronNoticePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicy.id = patronNoticePolicyId
    * patronNoticePolicy.name = patronNoticePolicyName
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    * def requestPolicy = read('classpath:vega/mod-feesfines/features/samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = requestPolicyId
    * requestPolicy.name = 'agedToLostRequestPolicy-' + requestPolicyId
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # Circulation rule for the created policies with specific material type and patron group
    * def policies = 'l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    * def rules = 'priority: t, s, c, b, a, m, g\nfallback-policy: ' + policies + '\nm ' + testMaterialTypeId + ' + g ' + testPatronGroupId + ': ' + policies
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation', 'rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    * configure retry = { count: 10, interval: 1000 }
    Given path 'circulation', 'rules'
    And retry until response.rulesAsText == rules
    When method GET
    Then status 200

    # Check out the item to the patron; loan date is in the past, so the loan is already overdue enough to age to lost
    * def loanDate = java.time.Instant.ofEpochSecond(java.time.Instant.now().getEpochSecond() - 86400).toString()
    * def checkOutResponse = call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostCheckOut') { extCheckOutId: #(testCheckOutId), extUserBarcode: #(testUserBarcode), extItemBarcode: #(testItemBarcode), extServicePointId: #(testServicePointId), extLoanDate: #(loanDate) }
    * def loanId = checkOutResponse.response.id
    # created policies have been applied to the loan
    * match checkOutResponse.response.loanPolicyId == loanPolicyId
    * match checkOutResponse.response.overdueFinePolicyId == overdueFinePolicyId
    * match checkOutResponse.response.lostItemPolicyId == lostItemFeePolicyId

    # Speed up the age-to-lost and age-to-lost-fee-charging scheduler timers (the UI scenario waits ~65 minutes instead)
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken
    * def ageToLostTimer = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@SetTimerByPath') { extToken: #(sidecarToken), extPathPattern: '/circulation/scheduled-age-to-lost', extUnit: 'second', extDelay: '1' }
    * def feeChargingTimer = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@SetTimerByPath') { extToken: #(sidecarToken), extPathPattern: '/circulation/scheduled-age-to-lost-fee-charging', extUnit: 'second', extDelay: '1' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # Item became "Aged to lost"
    * configure retry = { count: 30, interval: 10000 }
    Given path 'inventory', 'items', testItemId
    And retry until response.status.name == 'Aged to lost'
    When method GET
    Then status 200

    # Lost item fee has been incurred for the patron (lost item fee type is created by mod-feesfines automatically)
    Given path 'accounts'
    And param query = 'loanId==' + loanId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def accountId = response.accounts[0].id
    * match response.accounts[0].feeFineType == 'Lost item fee'
    * match response.accounts[0].amount == 100.00
    * match response.accounts[0].remaining == 100.00
    * match response.accounts[0].status.name == 'Open'

    # Restore the scheduler timers
    * call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@RestoreTimer') { extToken: #(sidecarToken), extTimerId: #(ageToLostTimer.currentTimerId), extTimerCreated: #(ageToLostTimer.currentTimerCreated), extOriginalTimer: #(ageToLostTimer.originalTimer) }
    * call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@RestoreTimer') { extToken: #(sidecarToken), extTimerId: #(feeChargingTimer.currentTimerId), extTimerCreated: #(feeChargingTimer.currentTimerCreated), extOriginalTimer: #(feeChargingTimer.originalTimer) }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # Edit the lost item fee policy: replace "Set cost" with "Actual cost"
    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method GET
    Then status 200
    * def editedLostItemFeePolicy = response
    * editedLostItemFeePolicy.chargeAmountItem = { chargeType: 'actualCost', amount: 0.0 }
    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    And request editedLostItemFeePolicy
    When method PUT
    Then status 204

    # Step 1: check in the aged to lost item
    * def checkInDate = java.time.Instant.now().toString()
    * def checkInRequest = read('classpath:vega/mod-feesfines/features/samples/check-in-by-barcode-entity-request.json')
    * checkInRequest.itemBarcode = testItemBarcode
    * checkInRequest.checkInDate = checkInDate
    * checkInRequest.servicePointId = testServicePointId
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * match response.item.status.name == 'Available'

    # Step 2: Fee/fine details contain "Lost item fee" ($100.00 balance) and "Cancelled item returned" ($0.00 balance) actions
    * configure retry = { count: 10, interval: 2000 }
    Given path 'feefineactions'
    And param query = 'accountId==' + accountId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def lostItemFeeActions = karate.filter(response.feefineactions, function(a){ return a.typeAction == 'Lost item fee' })
    * def cancelledActions = karate.filter(response.feefineactions, function(a){ return a.typeAction == 'Cancelled item returned' })
    * match lostItemFeeActions == '#[1]'
    * match cancelledActions == '#[1]'
    * match lostItemFeeActions[0].balance == 100.00
    * match cancelledActions[0].balance == 0.00

    # Step 3: Fee/fine record is closed with "Cancelled item returned" payment status, billed = $100.00, remaining = $0.00
    Given path 'accounts', accountId
    And retry until response.status.name == 'Closed'
    When method GET
    Then status 200
    * match response.feeFineType == 'Lost item fee'
    * match response.paymentStatus.name == 'Cancelled item returned'
    * match response.amount == 100.00
    * match response.remaining == 0.00

    # bring back old circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

  @C1464246
  Scenario: C1464246 Check in aged to lost item with billed actual cost lost item fee, lost item fee (actual cost) is cancelled
    # Save existing circulation rules
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def oldCirculationRules = response.rulesAsText

    # Own item and patron, so the scenario does not depend on the state left by other scenarios
    * def acLoanTypeId = call uuid1
    * def acItemId = call uuid1
    * def acUserId = call uuid1
    * def acItemBarcode = 'aged.lost.ac.item.' + uniqueSuffix
    * def acUserBarcode = 'aged.lost.ac.user.' + uniqueSuffix
    * def acItemArgs = { extHoldingsRecordId: '#(testHoldingsId)', extMaterialTypeId: '#(testMaterialTypeId)', extPermanentLoanTypeId: '#(acLoanTypeId)', extItemId: '#(acItemId)', extItemBarcode: '#(acItemBarcode)' }
    * def acItemResult = call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostItem') acItemArgs
    * def acUserArgs = { extPatronGroupId: '#(testPatronGroupId)', extUserId: '#(acUserId)', extUserBarcode: '#(acUserBarcode)' }
    * def acUserResult = call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostUser') acUserArgs

    * def loanPolicyId = call uuid1
    * def overdueFinePolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def patronNoticePolicyId = call uuid1
    * def requestPolicyId = call uuid1

    # Short term loan policy (loan period = 1 minute)
    * def loanPolicy = read('classpath:vega/mod-feesfines/features/samples/policies/loan-policy-entity-request.json')
    * loanPolicy.name = 'agedToLostActualCostLoanPolicy-' + loanPolicyId
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicy
    When method POST
    Then status 201

    # Overdue fine policy with 0 amount
    * def overdueFinePoliciesId = overdueFinePolicyId
    * def overdueFinePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicy.name = 'agedToLostActualCostOverdueFinePolicy-' + overdueFinePolicyId
    * overdueFinePolicy.overdueFine.quantity = 0.0
    * overdueFinePolicy.overdueRecallFine.quantity = 0.0
    * overdueFinePolicy.maxOverdueFine = 0.0
    * overdueFinePolicy.maxOverdueRecallFine = 0.0
    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    # Lost item fee policy: aged to lost after 1 minute, patron billed after 1 minute, Actual cost
    * def lostItemFeePolicyName = 'agedToLostActualCostLostItemFeePolicy-' + lostItemFeePolicyId
    * def lostItemFeePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/lost-item-fee-policy-aged-to-lost-entity-request.json')
    * lostItemFeePolicy.chargeAmountItem = { chargeType: 'actualCost', amount: 0.0 }
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicy
    When method POST
    Then status 201

    * def patronPolicyId = patronNoticePolicyId
    * def patronNoticePolicy = read('classpath:vega/mod-feesfines/features/samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicy.id = patronNoticePolicyId
    * patronNoticePolicy.name = 'agedToLostActualCostPatronNoticePolicy-' + patronNoticePolicyId
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    * def requestPolicy = read('classpath:vega/mod-feesfines/features/samples/policies/request-policy-entity-request.json')
    * requestPolicy.id = requestPolicyId
    * requestPolicy.name = 'agedToLostActualCostRequestPolicy-' + requestPolicyId
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    # Circulation rule for the created policies with specific material type and patron group
    * def policies = 'l ' + loanPolicyId + ' o ' + overdueFinePolicyId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronNoticePolicyId
    * def rules = 'priority: t, s, c, b, a, m, g\nfallback-policy: ' + policies + '\nm ' + testMaterialTypeId + ' + g ' + testPatronGroupId + ': ' + policies
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation', 'rules'
    And request rulesEntityRequest
    When method PUT
    Then status 204

    * configure retry = { count: 10, interval: 1000 }
    Given path 'circulation', 'rules'
    And retry until response.rulesAsText == rules
    When method GET
    Then status 200

    # Check out the item to the patron; loan date is in the past, so the loan is already overdue enough to age to lost
    * def loanDate = java.time.Instant.ofEpochSecond(java.time.Instant.now().getEpochSecond() - 86400).toString()
    * def acCheckOutId = call uuid1
    * def checkOutArgs = { extCheckOutId: '#(acCheckOutId)', extUserBarcode: '#(acUserBarcode)', extItemBarcode: '#(acItemBarcode)', extServicePointId: '#(testServicePointId)', extLoanDate: '#(loanDate)' }
    * def checkOutResponse = call read('classpath:vega/mod-feesfines/features/util/initData.feature@PostCheckOut') checkOutArgs
    * def loanId = checkOutResponse.response.id
    # created policies have been applied to the loan
    * match checkOutResponse.response.loanPolicyId == loanPolicyId
    * match checkOutResponse.response.overdueFinePolicyId == overdueFinePolicyId
    * match checkOutResponse.response.lostItemPolicyId == lostItemFeePolicyId

    # Speed up the age-to-lost and age-to-lost-fee-charging scheduler timers (the UI scenario waits ~30 minutes instead)
    * def sidecarResult = call read('classpath:common/eureka/keycloak.feature@getSidecarToken')
    * def sidecarToken = sidecarResult.sidecarToken
    * def ageToLostTimer = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@SetTimerByPath') { extToken: #(sidecarToken), extPathPattern: '/circulation/scheduled-age-to-lost', extUnit: 'second', extDelay: '1' }
    * def feeChargingTimer = call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@SetTimerByPath') { extToken: #(sidecarToken), extPathPattern: '/circulation/scheduled-age-to-lost-fee-charging', extUnit: 'second', extDelay: '1' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # Item became "Aged to lost"
    * configure retry = { count: 30, interval: 10000 }
    Given path 'inventory', 'items', acItemId
    And retry until response.status.name == 'Aged to lost'
    When method GET
    Then status 200

    # Open actual cost record appears for the aged to lost loan ("Lost items requiring actual cost")
    Given path 'actual-cost-record-storage', 'actual-cost-records'
    And param query = 'loan.id==' + loanId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def actualCostRecord = response.actualCostRecords[0]
    * match actualCostRecord.status == 'Open'

    # Restore the scheduler timers
    * call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@RestoreTimer') { extToken: #(sidecarToken), extTimerId: #(ageToLostTimer.currentTimerId), extTimerCreated: #(ageToLostTimer.currentTimerCreated), extOriginalTimer: #(ageToLostTimer.originalTimer) }
    * call read('classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@RestoreTimer') { extToken: #(sidecarToken), extTimerId: #(feeChargingTimer.currentTimerId), extTimerCreated: #(feeChargingTimer.currentTimerCreated), extOriginalTimer: #(feeChargingTimer.originalTimer) }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # Bill actual cost for the aged to lost item ("Bill actual cost" action)
    * def actualCostRecordId = actualCostRecord.id
    * def actualCostAmount = 75.50
    * def billRequest = read('classpath:vega/mod-feesfines/features/samples/actual-cost-fee-fine-bill-request-entity.json')
    Given path 'actual-cost-fee-fine', 'bill'
    And request billRequest
    When method POST
    Then status 201

    * configure retry = { count: 10, interval: 2000 }
    Given path 'accounts'
    And param query = 'loanId==' + loanId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def accountId = response.accounts[0].id
    * match response.accounts[0].feeFineType == 'Lost item fee (actual cost)'
    * match response.accounts[0].amount == actualCostAmount
    * match response.accounts[0].remaining == actualCostAmount
    * match response.accounts[0].status.name == 'Open'

    # Step 1: check in the aged to lost item
    * def checkInDate = java.time.Instant.now().toString()
    * def checkInRequest = read('classpath:vega/mod-feesfines/features/samples/check-in-by-barcode-entity-request.json')
    * checkInRequest.itemBarcode = acItemBarcode
    * checkInRequest.checkInDate = checkInDate
    * checkInRequest.servicePointId = testServicePointId
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * match response.item.status.name == 'Available'

    # Step 2: Fee/fine details contain "Lost item fee (actual cost)" (billed amount) and "Cancelled item returned" ($0.00 balance) actions
    Given path 'feefineactions'
    And param query = 'accountId==' + accountId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def lostItemFeeActions = karate.filter(response.feefineactions, function(a){ return a.typeAction == 'Lost item fee (actual cost)' })
    * def cancelledActions = karate.filter(response.feefineactions, function(a){ return a.typeAction == 'Cancelled item returned' })
    * match lostItemFeeActions == '#[1]'
    * match cancelledActions == '#[1]'
    * match lostItemFeeActions[0].balance == actualCostAmount
    * match cancelledActions[0].balance == 0.00

    # Step 3: Fee/fine record is closed with "Cancelled item returned" payment status, billed = actual cost, remaining = $0.00
    Given path 'accounts', accountId
    And retry until response.status.name == 'Closed'
    When method GET
    Then status 200
    * match response.feeFineType == 'Lost item fee (actual cost)'
    * match response.paymentStatus.name == 'Cancelled item returned'
    * match response.amount == actualCostAmount
    * match response.remaining == 0.00

    # bring back old circulation rules
    * def rulesEntityRequest = { "rulesAsText": "#(oldCirculationRules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204
