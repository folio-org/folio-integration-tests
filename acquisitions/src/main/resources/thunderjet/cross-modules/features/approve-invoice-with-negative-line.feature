# For https://issues.folio.org/browse/MODINVOICE-346
@parallel=false
Feature: Approve an invoice with a negative line

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId1 = callonce uuid6
    * def invoiceLineId2 = callonce uuid7
    * def invoiceLineId3 = callonce uuid8


  Scenario: Create finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }


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


  Scenario: Create an order line
    * print "Create an order line"

    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
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


  Scenario Outline: Create <description>
    * print "Create <description>"

    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = <id>
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.description = '<description>'
    * set invoiceLine.total = <amount>
    * set invoiceLine.subTotal = <amount>
    * set invoiceLine.releaseEncumbrance = true

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    Examples:
      | description    | amount | id             |
      | invoice line 1 | 10.0   | invoiceLineId1 |
      | invoice line 2 | 10.0   | invoiceLineId2 |
      | invoice line 3 | 10.0   | invoiceLineId3 |


  Scenario: Update second invoice line
    * print "Update second invoice line"

    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    * def invoiceLine = $
    * set invoiceLine.total = -invoiceLine.total
    * set invoiceLine.subTotal = -invoiceLine.subTotal

    Given path 'invoice/invoice-lines', invoiceLineId2
    And request invoiceLine
    When method PUT
    Then status 204


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


  Scenario: check the budget encumbrance
    * print "check the budget encumbrance"

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match response.budgets[0].encumbered == 0
