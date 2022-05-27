# For https://issues.folio.org/browse/MODINVOICE-385
@parallel=false
Feature: Cancel invoice and unrelease 2 encumbrances

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

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
    * def invoiceLineId = callonce uuid8


  Scenario: Create finances
    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId1)', code: '#(fundId1)' }
    * call createBudget { id: '#(budgetId1)', allocated: 1000, fundId: '#(fundId1)', status: 'Active' }
    * call createFund { id: '#(fundId2)', code: '#(fundId2)' }
    * call createBudget { id: '#(budgetId2)', allocated: 1000, fundId: '#(fundId2)', status: 'Active' }


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


  Scenario: Create an order line with 2 fund distributions
    * print "Create an order line with 2 fund distributions"

    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0] = { fundId: '#(fundId1)', code: '#(fundId1)', distributionType: 'percentage', value: 50 }
    * set poLine.fundDistribution[1] = { fundId: '#(fundId2)', code: '#(fundId2)', distributionType: 'percentage', value: 50 }
    * set poLine.cost.listUnitPrice = 10
    * set poLine.cost.poLineEstimatedPrice = 10

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


  Scenario: Add an invoice line with the same fund distributions
    * print "Add an invoice line with the same fund distributions"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0] = { fundId:'#(fundId1)', code: '#(fundId1)', distributionType:'percentage', value:50 }
    * set invoiceLine.fundDistributions[1] = { fundId:'#(fundId2)', code: '#(fundId2)', distributionType:'percentage', value:50 }
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    * set invoiceLine.releaseEncumbrance = true
    * remove invoiceLine.fundDistributions[0].expenseClassId

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


  Scenario: Check invoice line encumbrances have been added when the invoice was approved
    * print "Check invoice line encumbrances have been added when the invoice was approved"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * match $.fundDistributions[0].encumbrance == '#present'
    * match $.fundDistributions[1].encumbrance == '#present'


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


  Scenario: Check encumbrances before cancelling the invoice
    * print "Check encumbrances before cancelling the invoice"
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * match $.transactions[0].encumbrance.status == 'Released'
    * match $.transactions[1].encumbrance.status == 'Released'


  Scenario: Cancel the invoice
    * print "Cancel the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Cancelled'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


  Scenario: Check encumbrances after cancelling the invoice
    * print "Check encumbrances after cancelling the invoice"
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * match $.transactions[0].encumbrance.status == 'Unreleased'
    * match $.transactions[1].encumbrance.status == 'Unreleased'
