# For MODINVOICE-544 and MODFISTO-488
Feature: Cancel an invoice with an Encumbrance

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant':'#(testTenant)' }
    * configure headers = headersAdmin

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')
    * def approveInvoice = read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature')
    * def payInvoice = read('classpath:thunderjet/mod-invoice/reusable/pay-invoice.feature')
    * def cancelInvoice = read('classpath:thunderjet/mod-invoice/reusable/cancel-invoice.feature')
    * def closeOrderRemoveLines = read('classpath:thunderjet/mod-orders/reusable/close-order-remove-lines.feature')
    * def unopenOrder = read('classpath:thunderjet/mod-orders/reusable/unopen-order.feature')

  @Positive
  Scenario: Cancel an invoice with an Encumbrance from a PO line in "Pending" payment status
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }

    * print "2. Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.cost.listUnitPrice = karate.get('listUnitPrice', 1.0)
    * set poLine.cost.poLineEstimatedPrice = karate.get('listUnitPrice', 1.0)
    * set poLine.isPackage = karate.get('isPackage', false)
    * set poLine.titleOrPackage = karate.get('titleOrPackage', 'test')
    * set poLine.paymentStatus = 'Pending'
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print "3. Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "4. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "5. Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "6. Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "7. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "8. Pay the invoice"
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    * print "9. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    * print "10. Check the encumbrance"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    * def transaction = $
    * print 'Encumbrance transaction: ', transaction
    And match $.transactions[0].encumbrance.status == 'Unreleased'
    And match $.transactions[0].amount == 1

  @Positive
  Scenario: Cancel an invoice with an Encumbrance from a PO line in "Payment Not Required" payment status
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }

    * print "2. Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.cost.listUnitPrice = karate.get('listUnitPrice', 1.0)
    * set poLine.cost.poLineEstimatedPrice = karate.get('listUnitPrice', 1.0)
    * set poLine.isPackage = karate.get('isPackage', false)
    * set poLine.titleOrPackage = karate.get('titleOrPackage', 'test')
    * set poLine.paymentStatus = 'Payment Not Required'
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print "3. Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "4. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "5. Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "6. Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "7. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "8. Pay the invoice"
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    * print "9. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    * print "10. Check the encumbrance"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    * def transaction = $
    * print 'Encumbrance transaction: ', transaction
    And match $.transactions[0].encumbrance.status == 'Unreleased'
    And match $.transactions[0].amount == 1


  @Positive
  Scenario: Cancel a paid invoice after closing the order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }

    * print "2. Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 1 }

    * print "3. Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "4. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "5. Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "6. Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "7. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "8. Pay the invoice"
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    * print "9. Close the order"
    * def v = call closeOrderRemoveLines { orderId: '#(orderId)' }

    * print "10. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    * print "11. Check the encumbrance"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    * def transaction = $
    * print 'Encumbrance transaction: ', transaction
    And match $.transactions[0].encumbrance.status == 'Released'
    And match $.transactions[0].amount == 0


  @Positive
  Scenario: Cancel a paid invoice after unopening the order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }

    * print "2. Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 1 }

    * print "3. Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "4. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "5. Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "6. Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "7. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "8. Pay the invoice"
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    * print "9. Unopen the order"
    * def v = call unopenOrder { orderId: "#(orderId)" }

    * print "10. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    * print "11. Check the encumbrance"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    * def transaction = $
    * print 'Encumbrance transaction: ', transaction
    And match $.transactions[0].encumbrance.status == 'Pending'
    And match $.transactions[0].amount == 0


  @Positive
  Scenario: Cancel an approved invoice after unopening the order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }

    * print "2. Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 1 }

    * print "3. Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "4. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "5. Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "6. Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "7. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "8. Unopen the order"
    * def v = call unopenOrder { orderId: "#(orderId)" }

    * print "9. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    * print "10. Check the encumbrance"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    * def transaction = $
    * print 'Encumbrance transaction: ', transaction
    And match $.transactions[0].encumbrance.status == 'Pending'
    And match $.transactions[0].amount == 0

