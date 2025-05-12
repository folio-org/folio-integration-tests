# For MODINVOICE-516
@parallel=false
Feature: Pay invoice without order acq unit permission

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId = callonce uuid6
    * def acqUnitId = callonce uuid7
    * def acqUnitMembershipId = callonce uuid8


  Scenario: Prepare finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }


  Scenario: Create acq unit
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
      "name": "testAcqUnit3"
    }
    """
    When method POST
    Then status 201


  Scenario: Create acq unit membership
    * configure headers = headersAdmin
    * def res = callonce getUserIdByUsername { user: '#(testUser)' }
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


  Scenario: Create an order
    * def v = call createOrder { id: '#(orderId)', acqUnitIds: ['#(acqUnitId)'] }


  Scenario: Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }


  Scenario: Open the order
    * def v = call openOrder { orderId: '#(orderId)' }


  Scenario: Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }


  Scenario: Add an invoice line linked to the po line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 10 }


  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }


  Scenario: Remove acq unit membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships', acqUnitMembershipId
    When method DELETE
    Then status 204


  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }
