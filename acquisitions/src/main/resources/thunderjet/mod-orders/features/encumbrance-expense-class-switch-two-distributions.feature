# For MODORDERS-1039, https://foliotest.testrail.io/index.php?/cases/view/451477
Feature: Encumbrance Expense Class Switch In Two Fund Distributions

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 500 }

    * callonce variables


  @C451477
  @Positive
  Scenario: Encumbrance Expense Classes Are Updated After Switching Expense Classes In Two Fund Distributions Of One POL
    # 1. Generate Unique Identifiers For This Test Scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 2. Create Fund And Budget With Print And Electronic Expense Classes
    * configure headers = headersAdmin
    * def statusExpenseClasses = [ { expenseClassId: '#(globalPrnExpenseClassId)', status: 'Active' }, { expenseClassId: '#(globalElecExpenseClassId)', status: 'Active' } ]
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000, statusExpenseClasses: '#(statusExpenseClasses)' }

    # 3. Create Order With One POL Having Two Fund Distributions (Same Fund, 50% Electronic + 50% Print)
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def fundDistribution = [ { fundId: '#(fundId)', code: '#(fundId)', distributionType: 'percentage', value: 50.0, expenseClassId: '#(globalElecExpenseClassId)' }, { fundId: '#(fundId)', code: '#(fundId)', distributionType: 'percentage', value: 50.0, expenseClassId: '#(globalPrnExpenseClassId)' } ]
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', listUnitPrice: 10, fundDistribution: '#(fundDistribution)' }

    # 4. Open The Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Switch Expense Classes In Both Fund Distribution Records (Electronic -> Print And Print -> Electronic)
    * def orderLineResponse = call getOrderLine { poLineId: '#(poLineId)' }
    * def updatedFundDistribution = orderLineResponse.poLine.fundDistribution
    * set updatedFundDistribution[0].expenseClassId = globalPrnExpenseClassId
    * set updatedFundDistribution[1].expenseClassId = globalElecExpenseClassId
    * def v = call updateOrderLine { id: '#(poLineId)', fundDistribution: '#(updatedFundDistribution)' }

    # 6. Verify That Both Fund Distribution Records Have The Switched Expense Classes
    * def orderLineResponse = call getOrderLine { poLineId: '#(poLineId)' }
    * def fundDistribution = orderLineResponse.poLine.fundDistribution
    And match fundDistribution[0].expenseClassId == globalPrnExpenseClassId
    And match fundDistribution[1].expenseClassId == globalElecExpenseClassId

    # 7. Verify That Both Encumbrance Transactions Have The Updated Expense Classes
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def transaction1 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[0].encumbrance + "')]")[0]
    * def transaction2 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[1].encumbrance + "')]")[0]
    And match transaction1.expenseClassId == globalPrnExpenseClassId
    And match transaction2.expenseClassId == globalElecExpenseClassId

