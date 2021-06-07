# Note: this feature matches the use cases in MODFISTO-240
# The 3 scenarios could be run in parallel
Feature: Check encumbrances after order is reopened - 2

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid

    # Create a fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000}
    * configure headers = headersUser


  Scenario: Use Case 1 - Allow encumbrance with expended value to be unreleased

    # Create an order
    * def orderId = call uuid
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    # User has created a POL for $100 for a quantity of 2
    * def poLineId = call uuid
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 50
    * set poLine.cost.quantityPhysical = 2
    * set poLine.locations[0].quantityPhysical = 2
    * set poLine.locations[0].quantity = 2
    * set poLine.cost.poLineEstimatedPrice = 100
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201
    # Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # User receives 1 copy and pays first invoice for $49
    # Create invoice
    * def invoiceId = call uuid
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * set invoicePayload.id = invoiceId
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    # Add a line
    * def invoiceLineId = call uuid
    * def invoiceLinePayload =
"""
{
  "id": "#(invoiceLineId)",
  "invoiceId": "#(invoiceId)",
  "poLineId": "#(poLineId)",
  "invoiceLineStatus": "Open",
  "fundDistributions": [
    {
      "distributionType": "amount",
      "fundId": "#(fundId)",
      "value": "49"
    }
  ],
  "subTotal": "49",
  "description": "test",
  "quantity": "1",
  "releaseEncumbrance": false
}
"""
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201
    # Approve invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204
    # Pay invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # Encumbrance amount is now $51
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 51

    # User closes order by mistake and encumbrance is released
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Closed'
    # remove the lines, otherwise the order will not close (see MODORDERS-514)
    * remove order.compositePoLines
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 0

    # User Reopens order and $51 is re-encumbered
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 51


  Scenario: Use Case 2 - Prevent encumbrance from being unreleased

    # Create an order
    * def orderId = call uuid
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    # User has created a POL for $75 for a quantity of 2
    * def poLineId = call uuid
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 37.5
    * set poLine.cost.quantityPhysical = 2
    * set poLine.locations[0].quantityPhysical = 2
    * set poLine.locations[0].quantity = 2
    * set poLine.cost.poLineEstimatedPrice = 75
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201

    # Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # Get the order line fund distribution to create an invoice line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fd = $.fundDistribution

    # User receives 2 copies and pays all on 1 invoice line which has "Release encumbrance" = true
    # Create invoice
    * def invoiceId = call uuid
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * set invoicePayload.id = invoiceId
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    # Add a line
    * def invoiceLineId = call uuid
    * def invoiceLinePayload =
"""
{
  "id": "#(invoiceLineId)",
  "invoiceId": "#(invoiceId)",
  "poLineId": "#(poLineId)",
  "invoiceLineStatus": "Open",
  "fundDistributions": #(fd),
  "subTotal": "75",
  "description": "test",
  "quantity": "2",
  "releaseEncumbrance": true
}
"""
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201
    # Approve invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204
    # Pay invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # Check encumbrances for the order
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    * match $.transactions[0].encumbrance.status == 'Released'

    # POL payment status changes to fully paid and order is closed as complete.
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.compositePoLines[0].paymentStatus == 'Fully Paid'
    * def order = $
    * set order.workflowStatus = 'Closed'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # One of the books is damaged so user reopens the order.
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # Encumbrance is NOT unreleased because the amount has already been paid in full.
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 0

    # User receives a replacement book and closes order again.
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Closed'
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 0


  Scenario: Use Case 3 - Allow encumbrance to be unreleased

    # Create an order
    * def orderId = call uuid
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    # User has created a POL for $100 for a quantity of 1
    * def poLineId = call uuid
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 100
    * set poLine.cost.quantityPhysical = 1
    * set poLine.locations[0].quantityPhysical = 1
    * set poLine.locations[0].quantity = 1
    * set poLine.cost.poLineEstimatedPrice = 100
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201
    # Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # Encumbrance amount is now $100
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 100

    # User closes order before receiving or paying anything
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Closed'
    # remove the lines, otherwise the order will not close (see MODORDERS-514)
    * remove order.compositePoLines
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # Encumbrance is released
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 0

    # User Reopens order and encumbrance is unreleased, $100 is re-encumbered
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 100
