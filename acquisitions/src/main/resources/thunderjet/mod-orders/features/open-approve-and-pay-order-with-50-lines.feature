@parallel=false
# for https://folio-org.atlassian.net/browse/MODORDERS-1021
Feature: Approve and pay order with 50 lines
  1. Created Order
  2. Created 50 OrderLines for the order
  3. Create Invoice
  4. Create 50 InvoiceLines for 50 OrderLines
  5. Approve the invoice
  6. Pay for the invoice
  7. Check every transaction total amount for every invoice line

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
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def invoiceId = callonce uuid4
    * def poLineUuid = 'f91b86d6-e2e5-4d0c-bffd-7beb1d56ce'
    * def invoiceLineUuid = '0c2a0074-43e3-4dcf-b3a8-978124ea20'

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
    * def lineParameters = []
    * def poLineUuids = []
    * def createParameterArray =
      """
      function() {
        for (let i=10; i<60; i++) {
          lineParameters.push({ id: poLineUuid + i, orderId: orderId, fundId: fundId });
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


  Scenario: Create 50 invoiceLines for 50 poLines
    * def lineParameters = []
    * def createParameterArray =
      """
      function() {
        for (let i=10; i<60; i++) {
          lineParameters.push(
          {
            invoiceLineId: invoiceLineUuid + i,
            invoiceId: invoiceId,
            poLineId: poLineUuid + i,
            fundDistributions: [{fundId: globalFundId, value: 100}],
            subTotal: 10,
            total: 10
          })
        }
      }
      """
    * eval createParameterArray()
    * call createInvoiceLine lineParameters


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


  Scenario: Verify payed invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == 'Paid'


  Scenario Outline: Check that payments created with 10$ amount of money
    * def invoiceLineId = <invoiceLineId>
    * def amount = <amount>
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Payment'
    When method GET
    Then status 200
    * def total = $.transactions[0].amount
    And assert total == amount

    Examples:
      | invoiceLineId           | amount |
      | invoiceLineUuid  + '10' | 10.0   |
      | invoiceLineUuid  + '11' | 10.0   |
      | invoiceLineUuid  + '12' | 10.0   |
      | invoiceLineUuid  + '13' | 10.0   |
      | invoiceLineUuid  + '14' | 10.0   |
      | invoiceLineUuid  + '15' | 10.0   |
      | invoiceLineUuid  + '16' | 10.0   |
      | invoiceLineUuid  + '17' | 10.0   |
      | invoiceLineUuid  + '18' | 10.0   |
      | invoiceLineUuid  + '19' | 10.0   |
      | invoiceLineUuid  + '20' | 10.0   |
      | invoiceLineUuid  + '21' | 10.0   |
      | invoiceLineUuid  + '22' | 10.0   |
      | invoiceLineUuid  + '23' | 10.0   |
      | invoiceLineUuid  + '24' | 10.0   |
      | invoiceLineUuid  + '25' | 10.0   |
      | invoiceLineUuid  + '26' | 10.0   |
      | invoiceLineUuid  + '27' | 10.0   |
      | invoiceLineUuid  + '28' | 10.0   |
      | invoiceLineUuid  + '29' | 10.0   |
      | invoiceLineUuid  + '30' | 10.0   |
      | invoiceLineUuid  + '31' | 10.0   |
      | invoiceLineUuid  + '32' | 10.0   |
      | invoiceLineUuid  + '33' | 10.0   |
      | invoiceLineUuid  + '34' | 10.0   |
      | invoiceLineUuid  + '35' | 10.0   |
      | invoiceLineUuid  + '36' | 10.0   |
      | invoiceLineUuid  + '37' | 10.0   |
      | invoiceLineUuid  + '38' | 10.0   |
      | invoiceLineUuid  + '39' | 10.0   |
      | invoiceLineUuid  + '40' | 10.0   |
      | invoiceLineUuid  + '41' | 10.0   |
      | invoiceLineUuid  + '42' | 10.0   |
      | invoiceLineUuid  + '43' | 10.0   |
      | invoiceLineUuid  + '44' | 10.0   |
      | invoiceLineUuid  + '45' | 10.0   |
      | invoiceLineUuid  + '46' | 10.0   |
      | invoiceLineUuid  + '47' | 10.0   |
      | invoiceLineUuid  + '48' | 10.0   |
      | invoiceLineUuid  + '49' | 10.0   |
      | invoiceLineUuid  + '50' | 10.0   |
      | invoiceLineUuid  + '51' | 10.0   |
      | invoiceLineUuid  + '52' | 10.0   |
      | invoiceLineUuid  + '53' | 10.0   |
      | invoiceLineUuid  + '54' | 10.0   |
      | invoiceLineUuid  + '55' | 10.0   |
      | invoiceLineUuid  + '56' | 10.0   |
      | invoiceLineUuid  + '57' | 10.0   |
      | invoiceLineUuid  + '58' | 10.0   |
      | invoiceLineUuid  + '59' | 10.0   |
