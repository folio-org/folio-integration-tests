@parallel=false
# for https://folio-org.atlassian.net/browse/MODORDERS-1021
Feature: Approve and pay order with 50 lines

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
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def closeOrder = read('classpath:thunderjet/mod-orders/reusable/close-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * configure readTimeout = 60000


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * call createFund { id: #(fundId), code: #(fundId), ledgerId: #(globalLedgerId) }
    * call createBudget { id: #(budgetId), fundId: #(fundId), fiscalYearId: #(globalFiscalYearId), allocated: 1000, status: 'Active' }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create 50 order lines
    * def baseUuid = '3333-4444-5555-6666-7777-888'
    * def lineParameters = []
    * def poLineUuids = []
    * def createParameterArray =
      """
      function() {
        for (let i=0; i<50; i++) {
          poLineUuids.push(uuid())
        }
        for (let i=0; i<50; i++) {
          lineParameters.push({ id: poLineUuids.get(i), orderId: orderId, fundId: fundId });
        }
      }
      """
    * eval createParameterArray()
    * def v = call createOrderLine lineParameters


  Scenario: Open the order
    * def v = call openOrder { orderId: "#(orderId)" }

  Scenario: Create an invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

  Scenario: Add invoice line 1 linked to po line 1
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId1
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId1
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.fundDistributions[0].code = fundCode
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    Given path 'invoice/invoice-lines'
    And request invoiceLine
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
