# For MODORDERS-1071
Feature: Check paymentStatus after reopen

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def closeOrderRemoveLines = read('classpath:thunderjet/mod-orders/reusable/close-order-remove-lines.feature')


  Scenario: Open order, approve invoice, close order, reopen order, check paymentStatus
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Prepare finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    * print "Create an order"
    * def v = call createOrder { id: '#(orderId)' }

    * print "Create an order line"
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    * print "Create an invoice"
    * def v = call createInvoice { id: '#(invoiceId)' }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 10 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    * print "Check the po line paymentStatus"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.paymentStatus == 'Awaiting Payment'

    * print "Close the order"
    * def v = call closeOrderRemoveLines { orderId: '#(orderId)' }

    * print "Reopen the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    * print "Check the po line paymentStatus"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.paymentStatus == 'Awaiting Payment'
