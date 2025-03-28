Feature: Remove linked invoice lines fund distribution encumbrance reference when update POL
Also verify with acq units
  # for MODORDERS-800
  # for MODORDERS-1190
  # for MODORDERS-1224

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

  Scenario: Delete encumbrance link in invoice fund distribution when poLine fund was updated
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create an order
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time', ongoing: null }

    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', fundCode: '#(fundId1)', paymentStatus: 'Awaiting Payment', receiptStatus: 'Partially Received' }

    # 3. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 5. Create an invoice line
    # Get the encumbrance id
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    # Create the invoice line
    * def invoiceLine = { id: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', fundCode: '#(fundId1)', encumbrance: '#(encumbranceId)', total: 1, subTotal: 1 }
    * def v = call createInvoiceLine invoiceLine

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
    * def v = call verifyInvoiceLine { _invoiceLineId: '#(invoiceLineId)', _fundId: '#(fundId1)', _fundCode: '#(fundId1)', _encumbrance: '#notpresent' }


  @Positive
  Scenario: Scenario: Delete encumbrance link in invoice fund distribution when poLine fund was updated with acq units
    1. Create acquisition unit selecting all permissions
    2. Add your user to the acquisition unit from step #1
    3. Create an order and line
    4. Open the order
    5. Create an invoice from the order
    6. Set the invoice acquisition unit to the one from step #1
    7. Delete your user from the acquisition unit from step #1
    8. Remove the po line fund distribution
    9. Add your user to the acquisition unit from step #1
    10. Check the invoice line encumbrance link

    * def acqUnitId = call uuid
    * def userId = "00000000-1111-5555-9999-999999999992"

    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create acquisition unit and assign user
    * configure headers = headersAdmin
    * def v = call createAcqUnit { id: '#(acqUnitId)', name: 'Acq Unit 1', isDeleted: false, protectCreate: true, protectRead: true, protectUpdate: true, protectDelete: true }
    * def v = call assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    # 3. Create an order and line
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time', ongoing: null }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', fundCode: '#(fundId1)', paymentStatus: 'Awaiting Payment', receiptStatus: 'Partially Received' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)', acqUnitIds: ['#(acqUnitId)'] }

    # Create the invoice line
    * def invoiceLine = { id: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', fundCode: '#(fundId1)', encumbrance: '#(encumbranceId)', total: 1, subTotal: 1 }
    * def v = call createInvoiceLine invoiceLine

    # 7. Delete user from acquisition unit
    * configure headers = headersAdmin
    * def v = call deleteUserFromAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    # 8. Remove the po line fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * remove poLine.fundDistribution[0]

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 9. Add user to acquisition unit again
    * configure headers = headersAdmin
    * def v = call assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    # 10. Check the invoice line encumbrance link
    * def v = call verifyInvoiceLine { _invoiceLineId: '#(invoiceLineId)', _fundId: '#(fundId1)', _fundCode: '#(fundId1)', _encumbrance: '#notpresent' }
