# For MODINVOICE-537
Feature: Check payment status after cancelling paid invoice

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
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')
    * def approveInvoice = read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature')
    * def payInvoice = read('classpath:thunderjet/mod-invoice/reusable/pay-invoice.feature')
    * def cancelInvoice = read('classpath:thunderjet/mod-invoice/reusable/cancel-invoice.feature')


  Scenario: Cancel with no other invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }
    * configure headers = headersUser

    * print "Create an order and line"
    * def v = call createOrder { id: '#(orderId)' }
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
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 10, releaseEncumbrance: false }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    * print "Pay the invoice"
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    * print "Check the order line payment status before cancelling"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.paymentStatus == 'Partially Paid'

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    * print "Check the order line payment status after cancelling"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.paymentStatus == 'Awaiting Payment'


  Scenario: Cancel with another invoice with releaseEncumbrance=false
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId1 = call uuid
    * def invoiceId2 = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }
    * configure headers = headersUser

    * print "Create an order and line"
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    * print "Create invoice 1"
    * def v = call createInvoice { id: '#(invoiceId1)' }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line for invoice 1, with releaseEncumbrance=true"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId1)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 5, releaseEncumbrance: true }

    * print "Approve invoice 1"
    * def v = call approveInvoice { invoiceId: '#(invoiceId1)' }

    * print "Pay invoice 1"
    * def v = call payInvoice { invoiceId: '#(invoiceId1)' }

    * print "Create invoice 2"
    * def v = call createInvoice { id: '#(invoiceId2)' }

    * print "Add an invoice line linked to the po line for invoice 2, with releaseEncumbrance=false"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId2)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 5, releaseEncumbrance: false }

    * print "Approve invoice 2"
    * def v = call approveInvoice { invoiceId: '#(invoiceId2)' }

    * print "Pay invoice 2"
    * def v = call payInvoice { invoiceId: '#(invoiceId2)' }

    * print "Cancel invoice 1"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId1)' }

    * print "Check the order line payment status"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.paymentStatus == 'Partially Paid'


  Scenario: Cancel with another invoice with releaseEncumbrance=true
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId1 = call uuid
    * def invoiceId2 = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }
    * configure headers = headersUser

    * print "Create an order and line"
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    * print "Create invoice 1"
    * def v = call createInvoice { id: '#(invoiceId1)' }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line for invoice 1, with releaseEncumbrance=true"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId1)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 5, releaseEncumbrance: true }

    * print "Approve invoice 1"
    * def v = call approveInvoice { invoiceId: '#(invoiceId1)' }

    * print "Pay invoice 1"
    * def v = call payInvoice { invoiceId: '#(invoiceId1)' }

    * print "Create invoice 2"
    * def v = call createInvoice { id: '#(invoiceId2)' }

    * print "Add an invoice line linked to the po line for invoice 2, with releaseEncumbrance=true"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId2)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 5, releaseEncumbrance: true }

    * print "Approve invoice 2"
    * def v = call approveInvoice { invoiceId: '#(invoiceId2)' }

    * print "Pay invoice 2"
    * def v = call payInvoice { invoiceId: '#(invoiceId2)' }

    * print "Cancel invoice 1"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId1)' }

    * print "Check the order line payment status"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.paymentStatus == 'Fully Paid'
