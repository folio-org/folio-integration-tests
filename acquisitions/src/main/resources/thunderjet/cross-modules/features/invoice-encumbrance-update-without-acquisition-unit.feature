# For MODORDERS-1073
Feature: Invoice encumbrance update without acquisition unit

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Invoice encumbrance update without acquisition unit
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def acqUnitId = call uuid
    * def acqUnitMembershipId = call uuid

    # 1. Prepare finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create acq unit
    * configure headers = headersAdmin
    Given path 'acquisitions-units/units'
    And request
    """
    {
      "id": '#(acqUnitId)',
      "protectUpdate": true,
      "protectCreate": true,
      "protectDelete": true,
      "protectRead": true,
      "name": "testAcqUnitForInvoice3"
    }
    """
    When method POST
    Then status 201

    # 3. Create acq unit membership
    * def res = call getUserIdByUsername { user: '#(testUser)' }
    * def userIdForMembership = res.userId
    Given path 'acquisitions-units/memberships'
    And request
    """
      {
        "id": '#(acqUnitMembershipId)',
        "userId": "#(userIdForMembership)",
        "acquisitionsUnitId": "#(acqUnitId)"
      }
    """
    When method POST
    Then status 201

    # 4. Create an order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 5. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    # 6. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 7. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)', acqUnitIds: ['#(acqUnitId)'] }

    # 8. Add an invoice line linked to the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', total: 10 }

    # 9. Remove acq unit membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships', acqUnitMembershipId
    When method DELETE
    Then status 204

    # 10. Remove the order line fund distribution
    * configure headers = headersUser
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * remove poLine.fundDistribution

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 11. Re-add acq unit membership
    * configure headers = headersAdmin
    * def res = call getUserIdByUsername { user: '#(testUser)' }
    * def userIdForMembership = res.userId
    Given path 'acquisitions-units/memberships'
    And request
    """
      {
        "id": '#(acqUnitMembershipId)',
        "userId": "#(userIdForMembership)",
        "acquisitionsUnitId": "#(acqUnitId)"
      }
    """
    When method POST
    Then status 201

    # 12. Check the encumbrance link was removed in the invoice line
    * configure headers = headersUser
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == '#notpresent'
