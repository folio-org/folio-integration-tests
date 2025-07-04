@parallel=false
# for https://issues.folio.org/browse/MODORDERS-859
Feature: Open order after approving invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId = callonce uuid6


  Scenario: Prepare finances
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 100 }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create an order line with Receipt Not Required
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.receiptStatus = 'Receipt Not Required'
    * set poLine.checkinItems = true

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Create an invoice
    * def v = call createInvoice { id: #(invoiceId) }


  Scenario: Add an invoice line linked to the po line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: 1 }


  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: #(invoiceId) }


  Scenario: Open the order
    * def v = call openOrder { orderId: #(orderId) }


  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: #(invoiceId) }
    * call pause 1500


  Scenario: Check the order was closed
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'


  Scenario: Check the encumbrance was released
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 1
