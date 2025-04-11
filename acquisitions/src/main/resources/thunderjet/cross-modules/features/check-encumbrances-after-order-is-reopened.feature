# For MODORDERS-474 and MODORDERS-1055
@parallel=false
Feature: Check encumbrances after order is reopened

  Background:
    * print karate.info.scenarioName
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

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')


  Scenario: Create a fund and budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }


  Scenario: Check the new budget
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


  Scenario: Create order
    * def v = call createOrder { id: '#(orderId)' }


  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>
    * def fundId = <fundId>
    * def amount = <amount>

    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: #(amount) }

    Examples:
      | orderId | orderLineId    | fundId | amount |
      | orderId | orderLineId1   | fundId | 400    |
      | orderId | orderLineId2   | fundId | 600    |


  Scenario: Create the invoice
    * def v = call createInvoice { id: '#(invoiceId)' }


  Scenario Outline: Add an invoice line with releaseEncumbrance=<releaseEncumbrance>
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
    * def v = call openOrder { orderId: '#(orderId)' }


  Scenario: Check the budget after opening the order
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
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Closed'
    # remove the lines, otherwise the order will not close (see MODORDERS-514)
    * remove orderResponse.poLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Check encumbrances status for closed order
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    And match each $.transactions[*].encumbrance.status == 'Released'


  Scenario: Check the budget after closing the order
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
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
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
      }]
    }
    """
    When method POST
    Then status 204


  Scenario: Check the budget, there should not be enough founds to reopen
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
    Given path 'finance/transactions', otherEncumbranceId1
    When method GET
    Then status 200
    * def transaction = $
    * set transaction.description = 'release 700'
    * set transaction.encumbrance.status = 'Released'

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToUpdate": [ #(transaction) ]
    }
    """
    When method POST
    Then status 204


  Scenario: Check the budget before reopening the order
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


  Scenario: Reopen the order
    * def v = call openOrder { orderId: '#(orderId)' }


  Scenario: check encumbrances status for reopened order
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    And match $.transactions == '#[2]'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'


  Scenario: Final budget check
    Given path '/finance/budgets'
    And param query = 'fundId == ' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 0
    And match budget.expenditures == 0
    And match budget.encumbered == 1000
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 1000
