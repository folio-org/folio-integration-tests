# Note: this feature matches the use cases in MODFISTO-240
# The 3 scenarios could be run in parallel
Feature: Check encumbrances after order is reopened - 2

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid

    # Create a fund and budget
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000 }


  Scenario: Use Case 1 - Allow encumbrance with expended value to be unreleased

    # Create an order
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    # User has created a POL for $100 for a quantity of 2
    * def poLineId = call uuid
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 50, quantity: 2 }
    # Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # User receives 1 copy and pays first invoice for $49
    # Create invoice
    * def invoiceId = call uuid
    * def v = call createInvoice { id: '#(invoiceId)' }
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
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    # Pay invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # Encumbrance amount is now $51
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 51

    # User closes order by mistake and encumbrance is released
    * def v = call closeOrder { orderId: '#(orderId)' }

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
    * def v = call createOrder { id: '#(orderId)' }

    # User has created a POL for $75 for a quantity of 2
    * def poLineId = call uuid
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 37.5, quantity: 2 }

    # Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # Get the order line fund distribution to create an invoice line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fd = $.fundDistribution

    # User receives 2 copies and pays all on 1 invoice line which has "Release encumbrance" = true
    # Create invoice
    * def invoiceId = call uuid
    * def v = call createInvoice { id: '#(invoiceId)' }
    # Add a line
    * def invoiceLineId = call uuid
    * def invoiceLinePayload =
    """
    {
      "id": "#(invoiceLineId)",
      "invoiceId": "#(invoiceId)",
      "poLineId": "#(poLineId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": "#(fd)",
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
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    # Pay invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

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
    And match $.poLines[0].paymentStatus == 'Fully Paid'
    * def order = $
    * set order.workflowStatus = 'Closed'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # One of the books is damaged so user reopens the order.
    * def v = call openOrder { orderId: '#(orderId)' }

    # Encumbrance is NOT unreleased because the amount has already been paid in full.
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 0

    # User receives a replacement book and closes order again.
    * def v = call closeOrder { orderId: '#(orderId)' }

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 0


  Scenario: Use Case 3 - Allow encumbrance to be unreleased

    # Create an order
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    # User has created a POL for $100 for a quantity of 1
    * def poLineId = call uuid
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 100 }
    # Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # Encumbrance amount is now $100
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].encumbered == 100

    # User closes order before receiving or paying anything
    * def v = call closeOrder { orderId: '#(orderId)' }

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
