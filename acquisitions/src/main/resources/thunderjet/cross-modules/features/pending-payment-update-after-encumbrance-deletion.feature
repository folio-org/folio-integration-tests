# For MODORDERS-1043
Feature: Pending payment update after encumbrance deletion
  # (also checks that encumbrances cannot be deleted when linked to an approved invoice, even with pending orders)

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
    * def unopenOrder = read('classpath:thunderjet/mod-orders/reusable/unopen-order.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')
    * def approveInvoice = read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature')
    * def cancelInvoice = read('classpath:thunderjet/mod-invoice/reusable/cancel-invoice.feature')


  Scenario: Check update to pending payment after deleting an encumbrance for an open order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: "#(fundId)" }
    * call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }
    * configure headers = headersUser

    * print "Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)" }

    * print "Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "Try to remove the fund distribution (invoice is approved), expect an error"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * remove poLine.fundDistribution[0]
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 403

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    * print "Remove the fund distribution"
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    * print "Check the encumbrance was removed"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print "Check the pending payment after removing the fund distribution"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].awaitingPayment.encumbranceId == '#notpresent'

    * print "Check the encumbrance link was removed in the invoice line"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == '#notpresent'


  Scenario: Check update to pending payment after deleting an encumbrance for a pending order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: "#(fundId)" }
    * call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }
    * configure headers = headersUser

    * print "Create an order and line"
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)" }

    * print "Open the order"
    * def v = call openOrder { orderId: "#(orderId)" }

    * print "Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", encumbranceId: "#(encumbranceId)", total: 1 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "Unopen the order"
    * def v = call unopenOrder { orderId: "#(orderId)" }

    * print "Try to remove the fund distribution (invoice is approved), expect an error"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * remove poLine.fundDistribution[0]
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 403

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    * print "Remove the fund distribution"
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    * print "Check the encumbrance was removed"
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print "Check the pending payment after removing the fund distribution"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].awaitingPayment.encumbranceId == '#notpresent'

    * print "Check the encumbrance link was removed in the invoice line"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == '#notpresent'
