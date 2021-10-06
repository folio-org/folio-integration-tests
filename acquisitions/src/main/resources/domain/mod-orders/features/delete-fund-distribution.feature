# created for MODORDERS-539
@parallel=false
Feature: Delete fund distribution and check encumbrances are removed

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * configure readTimeout = 60000

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Create a fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000}


  Scenario: Create composite order
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
    Given path 'orders/order-lines'

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId

    And request poLine
    When method POST
    Then status 201


  Scenario: Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


  Scenario: check budget after open order
    * configure headers = headersAdmin
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 999
    And match budget.expenditures == 0
    And match budget.encumbered == 1
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 1


  Scenario: Remove the fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * remove poLine.fundDistribution

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: check related transactions have been removed
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  Scenario: check budget has been restored
    * configure headers = headersAdmin
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 1000
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0


  Scenario: Re-add the fund distribution
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def fd = poLine.fundDistribution
    * set fd[0].fundId = fundId

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution = fd

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: check budget again
    * configure headers = headersAdmin
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 999
    And match budget.expenditures == 0
    And match budget.encumbered == 1
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 1


  Scenario: Unopen order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = "Pending"

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


  Scenario: check the transaction is still there
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1


  Scenario: check budget has been restored
    * configure headers = headersAdmin
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 1000
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0


  Scenario: Try a change without touching the fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.edition = "First edition"

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: check the transaction is still there
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1


  Scenario: Remove the fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * remove poLine.fundDistribution

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: check the transaction has been removed
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

