# For https://issues.folio.org/browse/MODFISTO-281
@parallel=false
Feature: Change fund and pay invoice

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def budgetId1 = callonce uuid3
    * def budgetId2 = callonce uuid4
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId1 = callonce uuid8
    * def invoiceLineId2 = callonce uuid9


  Scenario: Create finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId1)' }
    * call createFund { 'id': '#(fundId2)' }
    * call createBudget { 'id': '#(budgetId1)', 'allocated': 1000, 'fundId': '#(fundId1)', 'status': 'Active' }
    * call createBudget { 'id': '#(budgetId2)', 'allocated': 1000, 'fundId': '#(fundId2)', 'status': 'Active' }


  Scenario: Create an order
    * print "Create an order"

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


  Scenario: Create an order line with the first fund
    * print "Create an order line with the first fund"

    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId1
    * set poLine.fundDistribution[0].code = fundId1
    * set poLine.cost.listUnitPrice = 10

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


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


  Scenario: Create an invoice
    * print "Create an invoice"

    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201


  Scenario: Add an invoice line with the second fund
    * print "Add an invoice line with the second fund"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId1
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId2
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Approve the invoice - this will fail
    * print "Approve the invoice - this will fail"

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Approved'

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 400


  Scenario: Unopen the order
    * print "Unopen the order"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Pending'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Remove the fund distribution from the order line
    * print "Remove the fund distribution from the order line"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * remove poLine.fundDistribution

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Add a new fund distribution with the new fund to the order line
    * print "Add a new fund distribution with the new fund to the order line"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution = [ { fundId:"#(fundId2)", code:"#(fundId2)", distributionType:"percentage", value:100.0 } ]

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Reopen the order
    * print "Reopen the order"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Remove the invoice line
    * print "Remove the invoice line"

    Given path 'invoice/invoice-lines', invoiceLineId1
    When method DELETE
    Then status 204


  Scenario: Add another invoice line with the second fund
    * print "Add another invoice line with the second fund"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId2
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId2
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Approve the invoice
    * print "Approve the invoice"

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Approved'

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


  Scenario: Pay the invoice
    * print "Pay the invoice"

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Paid'

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


  Scenario: Check the payment transaction
    * print "Check the payment transaction"

    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].amount == 10


  Scenario: Check the budgets
    * print "Check the budgets"

    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1000
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 10
    And match $.cashBalance == 990
    And match $.encumbered == 0
