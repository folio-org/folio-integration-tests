@parallel=false
  # for MODORDERS-800
  # for MODORDERS-1190
Feature: Remove linked invoice lines fund distribution encumbrance reference when update POL
Also verify with acq units

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * callonce variables

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def budgetId1 = callonce uuid3
    * def budgetId2 = callonce uuid4

    ### Before All: Prepare finance data ###
    * configure headers = headersAdmin
    * table fundTable
      | id      |
      | fundId1 |
      | fundId2 |
    * def v = callonce createFund fundTable
    * table budgetTable
      | id        | allocated | fundId  | status   |
      | budgetId1 | 100       | fundId1 | 'Active' |
      | budgetId2 | 200       | fundId2 | 'Active' |
    * def v = callonce createBudget budgetTable
    * configure headers = headersUser

  Scenario: Delete encumbrance link in ivoice fund distribution when poLine fund was updated
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create an order and order line
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time', ongoing: null }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', paymentStatus: 'Awaiting Payment', receiptStatus: 'Partially Received' }

    # 3. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)'}

    # 5. Create a invoice line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    # 6. Create an invoice line
    * def v = call createInvoiceLine { id: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', code: '#(fundId1)', encumbranceId: '#(encumbranceId)', total: 1, releaseEncumbrance: true }

    # 6. Update fundId in poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].fundId = fundId2
    * set poLine.fundDistribution[0].code = fundId2
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 7. Check the invoice line fund distribution after poLine fund was NOT updated, but encumbrance link was removed
    * def v = call verifyInvoiceLine { invoiceLineId: '#(invoiceLineId)', fundId: '#(fundId2)', code: '#(fundId2)', encumbranceId: null }
