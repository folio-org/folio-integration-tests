# created for https://issues.folio.org/browse/MODORDERS-833
@parallel=false
Feature: Pay an invoice and delete a piece

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

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-audit-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def approveInvoice = read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature')
    * def payInvoice = read('classpath:thunderjet/mod-invoice/reusable/pay-invoice.feature')

    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId = callonce uuid6


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create an order line
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }


  Scenario: Open the order
    * def v = call openOrder { orderId: #(orderId) }


  Scenario: Receive the piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId)",
              itemStatus: "In process",
              locationId: "#(globalLocationsId)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1


  Scenario: Create an invoice
    * def v = call createInvoice { id: #(invoiceId) }


  Scenario: Add an invoice line
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0] = { fundId:'#(fundId)', code:'#(fundId)', distributionType:'percentage', value:100 }
    * set invoiceLine.total = 1
    * set invoiceLine.subTotal = 1
    * set invoiceLine.releaseEncumbrance = true

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: #(invoiceId) }


  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: #(invoiceId) }


  Scenario: Delete the piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 204


  Scenario: Check the budget encumbrance
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match response.budgets[0].encumbered == 0
