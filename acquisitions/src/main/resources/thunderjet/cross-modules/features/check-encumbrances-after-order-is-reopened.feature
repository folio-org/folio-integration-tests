@parallel=false
Feature: Check encumbrances after order is reopened

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def orderLineId1 = callonce uuid4
    * def orderLineId2 = callonce uuid5
    * def invoiceId = callonce uuid6
    * def invoiceLineId1 = callonce uuid7
    * def invoiceLineId2 = callonce uuid8
    * def otherOrderId1 = callonce uuid9
    * def otherOrderId2 = callonce uuid10
    * def otherOrderLineId1 = callonce uuid11
    * def otherOrderLineId2 = callonce uuid12
    * def otherEncumbranceId1 = callonce uuid13
    * def otherEncumbranceId2 = callonce uuid14


  Scenario: Create a fund and budget
  * print "Create a fund and budget"
    * configure headers = headersAdmin
    * callonce createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000}


  Scenario: Check the new budget
    * print "Check the new budget"
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


  Scenario: Create orders
    * print "Create orders"

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


  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * print "Create order lines for <orderLineId> and <fundId>"

    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId    | fundId | amount |
      | orderId | orderLineId1   | fundId | 400    |
      | orderId | orderLineId2   | fundId | 600    |


  Scenario: Create the invoice
    * print "Create the invoice"
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * set invoicePayload.id = invoiceId
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201


  Scenario Outline: Add an invoice line
    * print "Add an invoice line"

    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')
    * set invoiceLinePayload.id = <invoiceLineId>
    * set invoiceLinePayload.invoiceId = invoiceId
    * set invoiceLinePayload.poLineId = <poLineId>
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId
    * set invoiceLinePayload.releaseEncumbrance = <releaseEncumbrance>

    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201
    Examples:
      | invoiceLineId  | poLineId        | releaseEncumbrance |
      | invoiceLineId1 | orderLineId1    | false              |
      | invoiceLineId2 | orderLineId2    | true               |


  Scenario: Open the order
    * print "Open the order"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Check the budget after opening the order
    * print "Check the budget after opening the order"

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 0
    And match budget.expenditures == 0
    And match budget.encumbered == 1000
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 1000


  Scenario: Close the order and release encumbrances
    * print "Close the order and release encumbrances"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Closed'
    # remove the lines, otherwise the order will not close (see MODORDERS-514)
    * remove orderResponse.compositePoLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Check encumbrances status for closed order
    * print "Check encumbrances status for closed order"

    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    * def path1 = "$.transactions[?(@.encumbrance.sourcePoLineId=='" + orderLineId1 + "')].encumbrance.status"
    * match karate.jsonPath(response, path1)[0] == 'Released'
    * def path2 = "$.transactions[?(@.encumbrance.sourcePoLineId=='" + orderLineId2 + "')].encumbrance.status"
    * match karate.jsonPath(response, path2)[0] == 'Released'


  Scenario: Check the budget after closing the order
    * print "Check the budget after closing the order"

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


  Scenario: Add some encumbrance to later test the budget checks when reopening the order
    * print "Add some encumbrance to later test the budget checks when reopening the order"

    Given path 'finance/order-transaction-summaries'
    And request
    """
      {
        "id": '#(otherOrderId1)',
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
        "id": "#(otherEncumbranceId1)",
        "amount": 700,
        "currency": "USD",
        "description": "encumber 700",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance": {
          "initialAmountEncumbered": 700,
          "status": "Unreleased",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": '#(otherOrderId1)',
          "sourcePoLineId": '#(otherOrderLineId1)'
        }
      }
    """
    When method POST
    Then status 201


  Scenario: Check the budget, there should not be enough founds to reopen
    * print "Check the budget, there should not be enough founds to reopen"

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 300
    And match budget.expenditures == 0
    And match budget.encumbered == 700
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 700


  Scenario: Try reopening the order, this should fail because of encumbrance restrictions
    * print "Try reopening the order, this should fail because of encumbrance restrictions"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 500
    And match $.errors[0].message contains 'Fund cannot be paid due to restrictions'


  Scenario: Release the added encumbrance
    * print "Release the added encumbrance"

    Given path 'finance/order-transaction-summaries', otherOrderId1
    And request
    """
      {
        "id": '#(otherOrderId1)',
        "numTransactions": 1
      }
    """
    When method PUT
    Then status 204

    Given path 'finance/encumbrances', otherEncumbranceId1
    And request
    """
      {
        "id": "#(otherEncumbranceId1)",
        "amount": 700,
        "currency": "USD",
        "description": "release 700",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance": {
          "initialAmountEncumbered": 700,
          "status": "Released",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": '#(otherOrderId1)',
          "sourcePoLineId": '#(otherOrderLineId1)'
        },
        "_version": 1
      }
    """
    When method PUT
    Then status 204


  Scenario: Add another (lower) encumbrance to test reopening encumbrance checks
    * print "Add another (lower) encumbrance to test reopening encumbrance checks"

    Given path 'finance/order-transaction-summaries'
    And request
    """
      {
        "id": '#(otherOrderId2)',
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
        "id": "#(otherEncumbranceId2)",
        "amount": 500,
        "currency": "USD",
        "description": "encumber 500",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance": {
          "initialAmountEncumbered": 500,
          "status": "Unreleased",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": '#(otherOrderId2)',
          "sourcePoLineId": '#(otherOrderLineId2)'
        }
      }
    """
    When method POST
    Then status 201


  Scenario: Check the budget before reopening the order
    * print "Check the budget before reopening the order"

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 500
    And match budget.expenditures == 0
    And match budget.encumbered == 500
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 500


  Scenario: Reopen the order
    * print "Reopen the order"

    # encumbrances without an invoice line having releaseEncumbrance=true (with the first poline) should be unreleased
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: check encumbrances status for reopened order
    * print "check encumbrances status for reopened order"

    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    * def path1 = "$.transactions[?(@.encumbrance.sourcePoLineId=='" + orderLineId1 + "')].encumbrance.status"
    * match karate.jsonPath(response, path1)[0] == 'Unreleased'
    * def path2 = "$.transactions[?(@.encumbrance.sourcePoLineId=='" + orderLineId2 + "')].encumbrance.status"
    * match karate.jsonPath(response, path2)[0] == 'Released'


  Scenario: Final budget check
    * print "Final budget check"

    Given path '/finance/budgets'
    And param query = 'fundId == ' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 100
    And match budget.expenditures == 0
    And match budget.encumbered == 900
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 900
