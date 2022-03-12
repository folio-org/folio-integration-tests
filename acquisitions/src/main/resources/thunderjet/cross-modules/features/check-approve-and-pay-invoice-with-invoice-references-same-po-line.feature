# For https://issues.folio.org/browse/MODINVOICE-363
@parallel=false
Feature: Check approve and pay invoice with more than 15 invoice lines, several of which reference to same POL

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId1 = callonce uuid6
    * def invoiceLineId2 = callonce uuid7
    * def invoiceLineId3 = callonce uuid8
    * def invoiceLineId4 = callonce uuid9
    * def invoiceLineId5 = callonce uuid10
    * def invoiceLineId6 = callonce uuid11
    * def invoiceLineId7 = callonce uuid12
    * def invoiceLineId8 = callonce uuid13
    * def invoiceLineId9 = callonce uuid14
    * def invoiceLineId10 = callonce uuid15
    * def invoiceLineId11 = callonce uuid16
    * def invoiceLineId12 = callonce uuid17
    * def invoiceLineId13 = callonce uuid18
    * def invoiceLineId14 = callonce uuid19
    * def invoiceLineId15 = callonce uuid20
    * def invoiceLineId16 = callonce uuid21
    * def invoiceLineId17 = callonce uuid22
    * def invoiceLineId18 = callonce uuid23
    * def invoiceLineId19 = callonce uuid24
    * def invoiceLineId20 = callonce uuid25
    * def invoiceLineId21 = callonce uuid26
    * def invoiceLineId22 = callonce uuid27
    * def invoiceLineId23 = callonce uuid28
    * def invoiceLineId24 = callonce uuid29
    * def invoiceLineId25 = callonce uuid30
    * def invoiceLineId26 = callonce uuid31
    * def invoiceLineId27 = callonce uuid32
    * def invoiceLineId28 = callonce uuid33
    * def invoiceLineId29 = callonce uuid34
    * def invoiceLineId30 = callonce uuid35

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')


  Scenario: Create finances
    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active'}] }

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
    * set poLine.fundDistribution[0].code = fundId
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

  Scenario Outline: Add an invoice lines linked to the same POL
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice lines linked to the same POL"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = <id>
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.description = '<description>'
    * set invoiceLine.total = <amount>
    * set invoiceLine.subTotal = <amount>
    * remove invoiceLine.fundDistributions[0].expenseClassId

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    Examples:
      | description    | amount | id             |
      | invoice line 1 | 10.0   | invoiceLineId1 |
      | invoice line 2 | 10.0   | invoiceLineId2 |
      | invoice line 3 | 10.0   | invoiceLineId3 |
      | invoice line 4 | 10.0   | invoiceLineId4 |
      | invoice line 5 | 10.0   | invoiceLineId5 |
      | invoice line 6 | 10.0   | invoiceLineId6 |
      | invoice line 7 | 10.0   | invoiceLineId7 |
      | invoice line 8 | 10.0   | invoiceLineId8 |
      | invoice line 9 | 10.0   | invoiceLineId9 |
      | invoice line 10| 10.0   | invoiceLineId10|
      | invoice line 11| 10.0   | invoiceLineId11|
      | invoice line 12| 10.0   | invoiceLineId12|
      | invoice line 13| 10.0   | invoiceLineId13|
      | invoice line 14| 10.0   | invoiceLineId14|
      | invoice line 15| 10.0   | invoiceLineId15|
      | invoice line 16| 10.0   | invoiceLineId16|
      | invoice line 17| 10.0   | invoiceLineId17|
      | invoice line 18| 10.0   | invoiceLineId18|
      | invoice line 19| 10.0   | invoiceLineId19|
      | invoice line 20| 10.0   | invoiceLineId20|
      | invoice line 21| 10.0   | invoiceLineId21|
      | invoice line 22| 10.0   | invoiceLineId22|
      | invoice line 23| 10.0   | invoiceLineId23|
      | invoice line 24| 10.0   | invoiceLineId24|
      | invoice line 25| 10.0   | invoiceLineId25|
      | invoice line 26| 10.0   | invoiceLineId26|
      | invoice line 27| 10.0   | invoiceLineId27|
      | invoice line 28| 10.0   | invoiceLineId28|
      | invoice line 29| 10.0   | invoiceLineId29|
      | invoice line 30| 10.0   | invoiceLineId30|


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
