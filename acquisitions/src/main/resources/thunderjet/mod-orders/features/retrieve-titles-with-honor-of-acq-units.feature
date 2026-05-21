# created for MODORDERS-619
Feature: Retrieve titles with honor of acquisition units

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


  Scenario: Retrieve titles with honor of acquisition units
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def acqUnitId = call uuid
    * def acqUnitMembershipId = call uuid

    # 1. Create a fund and budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000, statusExpenseClasses: [{expenseClassId: '#(globalPrnExpenseClassId)',status: 'Active'}] }

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
      "name": "testAcqUnit"
    }
    """
    When method POST
    Then status 201

    # 3. Create acq unit membership
    * configure headers = headersAdmin
    * def res = callonce getUserIdByUsername { user: '#(testUser)' }
    * def userId = res.userId
    Given path 'acquisitions-units/memberships'
    And request
    """
      {
        "id": '#(acqUnitMembershipId)',
        "userId": "#(userId)",
        "acquisitionsUnitId": "#(acqUnitId)"
      }
    """
    When method POST
    Then status 201

    # 4. Create a composite order
    * configure headers = headersUser
    * def acqUnitIds = ['#(acqUnitId)']
    * def v = call createOrder { id: '#(orderId)', acqUnitIds: '#(acqUnitIds)' }

    # 5. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 6. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 7. Retrieve title having acq units membership
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # 8. Remove acq unit membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships', acqUnitMembershipId
    When method DELETE
    Then status 204

    # 9. Retrieve title without acq units membership
    * configure headers = headersUser
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0
