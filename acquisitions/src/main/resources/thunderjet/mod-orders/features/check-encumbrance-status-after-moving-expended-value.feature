@parallel=false
# for https://issues.folio.org/browse/MODORDERS-943
Feature: Check encumbrance status after moving expended value

  Background:
    * print karate.info.scenarioName

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
    * def fundId3 = callonce uuid3
    * def fundId4 = callonce uuid4
    * def budgetId1 = callonce uuid5
    * def budgetId2 = callonce uuid6
    * def budgetId3 = callonce uuid7
    * def budgetId4 = callonce uuid8
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId = callonce uuid8

  Scenario Outline: Prepare finances
    * def fundId = <fundId>
    * def fundCode = <fundCode>
    * def budgetId = <budgetId>
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)', ledgerId: '#(globalLedgerId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    Examples:
      | fundId  | fundCode    | budgetId  |
      | fundId1 | 'fundCode1' | budgetId1 |
      | fundId2 | 'fundCode2' | budgetId2 |
      | fundId3 | 'fundCode3' | budgetId3 |
      | fundId4 | 'fundCode4' | budgetId4 |


  Scenario: Create an order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      reEncumber: 'True'
    }
    """
    When method POST
    Then status 201

  Scenario: Create a po line
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId1
    * set poLine.fundDistribution[0].code = 'fundCode1'
    * set poLine.fundDistribution[0].value = 50
    * set poLine.fundDistribution[0].distributionType = 'percentage'
    * set poLine.fundDistribution[1].fundId = fundId2
    * set poLine.fundDistribution[1].code = 'fundCode1'
    * set poLine.fundDistribution[1].value = 50
    * set poLine.fundDistribution[1].distributionType = 'percentage'
    * set poLine.paymentStatus = 'Awaiting Payment'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

  Scenario: Create an invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

  Scenario: Create a invoice line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId1 = poLine.fundDistribution[0].encumbrance
    * def encumbranceId2 = poLine.fundDistribution[1].encumbrance

    * print "Add an invoice line linked to the po line"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0] = { fundId:'#(fundId1)', code: 'fundCode1', encumbrance: '#(encumbranceId1)', distributionType:'percentage', value:50 }
    * set invoiceLine.fundDistributions[1] = { fundId:'#(fundId2)', code: 'fundCode2', encumbrance: '#(encumbranceId2)', distributionType:'percentage', value:50 }
    * set invoiceLine.total = 1
    * set invoiceLine.subTotal = 1
    * set invoiceLine.releaseEncumbrance = true
    * remove invoiceLine.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

  Scenario: Approve the invoice
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
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Update fundId in poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.fundDistribution[0].fundId = fundId3
    * set poLine.fundDistribution[0].code = 'fundCode3'
    * set poLine.fundDistribution[0].value = 30
    * set poLine.fundDistribution[1].value = 30
    * set poLine.fundDistribution[2] = { fundId:'#(fundId4)', code: 'fundCode4', distributionType:'percentage', value: 40 }
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

  Scenario Outline: Check the newly created encumbrance
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def newEncumbranceId = $.fundDistribution[<index>].encumbrance

    Given path 'finance/transactions', newEncumbranceId
    When method GET
    Then status 200
    And match $.amount == <amount>
    And match $.encumbrance.amountExpended == <amountExpended>
    And match $.encumbrance.status == <status>

    Examples:
      | index | amount | amountExpended | status       |
      | 0     | 0      | 0.5            | 'Released'   |
      | 1     | 0      | 0.5            | 'Released'   |
      | 2     | 0.4    | 0              | 'Unreleased' |
