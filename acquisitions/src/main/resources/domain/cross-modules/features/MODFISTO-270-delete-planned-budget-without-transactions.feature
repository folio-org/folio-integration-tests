# for https://issues.folio.org/browse/MODFISTO-270
Feature: Planned budgets without transactions should be deleted

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_cross_modules'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser
    * callonce variables

    * def ledgerId = callonce uuid1

    * def currentFundId = callonce uuid2
    * def currentBudgetId = callonce uuid3
    * def plannedBudgetId = callonce uuid4

    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6

  Scenario: Create ledger
    * print "Create ledger"
    * call createLedger { 'id': '#(ledgerId)'}

  Scenario: Create funds and current and planned budget
    * print "Create funds and current and planned budget"

    * configure headers = headersAdmin
    * call createFund { 'id': '#(currentFundId)'}
    * call createBudget { 'id': '#(currentBudgetId)', 'allocated': 1000, 'fundId': '#(currentFundId)'}
    * print "Create planned budget"
    * call createBudget  {'id': '#(plannedBudgetId)', 'budgetStatus': 'Planned', 'allocated': 1000, 'fundId': '#(currentFundId)', "fiscalYearId":"#(globalPlannedFiscalYearId)"}

  Scenario: Create order
    * print "Create order"

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

  Scenario: Create order line
    * print "Create order line"

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = currentFundId

    And request orderLine
    When method POST
    Then status 201

  Scenario: Open order
    * print "Open order"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Verify that planned budget without transaction can be deleted
    * print "Verify that planned budget without transaction can be deleted"

    Given path 'finance/budgets', plannedBudgetId
    When method DELETE
    Then status 204


  Scenario: Verify planned budget was deleted
    * print "Verify planned budget was deleted"

    Given path 'finance/budgets', plannedBudgetId
    When method GET
    Then status 404

  Scenario: Verify that current budget with transaction can't be deleted
    * print "Verify that current budget with transaction can't be deleted"

    Given path 'finance/budgets', currentBudgetId
    When method DELETE
    Then status 400
    And match $.errors[0].message contains 'Budget related transactions found. Deletion of the budget is forbidden.'
