# For MODFIN-394, FAT-21157
Feature: Recalculate budget

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

  @Positive
  Scenario: Recalculate budget
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def releasedEncumbranceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId1 = call uuid
    * def invoiceId2 = call uuid
    * def invoiceId3 = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid

    # 1. Create funds and budgets
    * def v = call createFund { id: '#(fundId1)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 100 }
    * def v = call createFund { id: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 100 }

    # 2. Create unreleased encumbrance
    * def v = call createEncumbrance { amount: 2.0, fundId: '#(fundId1)', sourcePurchaseOrderId: '#(orderId)', sourcePoLineId: '#(poLineId)' }

    # 3. Create released encumbrance
    * def v = call createEncumbrance { id: '#(releasedEncumbranceId)', amount: 0.0, initialAmountEncumbered: 3.0, fundId: '#(fundId1)', status: 'Released', sourcePurchaseOrderId: '#(orderId)', sourcePoLineId: '#(poLineId)' }

    # 4. Create pending payment
    * def v = call createPendingPayment { amount: 5.0, fundId: '#(fundId1)', encumbranceId: '#(releasedEncumbranceId)', invoiceId: '#(invoiceId1)', invoiceLineId: '#(invoiceLineId1)', releaseEncumbrance: true }

    # 5. Create payment
    * def v = call createPayment { amount: 7.0, fundId: '#(fundId1)', invoiceId: '#(invoiceId2)', invoiceLineId: '#(invoiceLineId2)' }

    # 6. Create credit
    * def v = call createCredit { amount: 11.0, fundId: '#(fundId1)', invoiceId: '#(invoiceId3)', invoiceLineId: '#(invoiceLineId3)' }

    # 7. Create allocation
    * def v = call createTransaction { transactionType: 'Allocation', amount: 13.0, fundId: '#(fundId1)' }

    # 8. Create transfer
    * def v = call createTransaction { transactionType: 'Transfer', amount: 17.0, fromFundId: '#(fundId2)', toFundId: '#(fundId1)' }

    # 9. Create rollover transfer
    * def v = call createTransaction { transactionType: 'Rollover transfer', amount: 19.0, fundId: '#(fundId1)' }

    # 10. Change budget amounts so it needs to be recalculated
    Given path '/finance/budgets', budgetId1
    When method GET
    Then status 200
    * def budget = $
    * set budget.allocated = 0
    * set budget.awaitingPayment = 0
    * set budget.credits = 0
    * set budget.encumbered = 0
    * set budget.expenditures = 0
    * set budget.netTransfers = 0
    Given path '/finance/budgets', budgetId1
    And request budget
    When method PUT
    Then status 204

    # 11. Recalculate budget
    Given path 'finance/budgets', budgetId1, 'recalculate'
    When method POST
    Then status 204

    # 12. Check budget amounts
    Given path '/finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.initialAllocation == 100
    And match $.allocationTo == 13
    And match $.allocationFrom == 0
    # allocated = initialAllocation + allocationTo - allocationFrom
    And match $.allocated == 113
    And match $.netTransfers == 36
    # totalFunding = allocated + netTransfers
    And match $.totalFunding == 149
    And match $.encumbered == 2
    And match $.awaitingPayment == 5
    And match $.expenditures == 7
    And match $.credits == 11
    # unavailable = encumbered + awaitingPayment + expenditures - credits
    And match $.unavailable == 3
    # available = totalFunding - unavailable
    And match $.available == 146
