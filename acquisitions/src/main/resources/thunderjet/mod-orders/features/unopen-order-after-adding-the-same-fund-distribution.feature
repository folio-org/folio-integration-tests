@parallel=false
# for https://issues.folio.org/browse/MODORDERS-894
Feature: Should unopen order after adding the same fund reference with another expense class

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Create a fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active'}]}

  Scenario: Prepare expense classes
    * configure headers = headersAdmin

    Given path '/finance-storage/budget-expense-classes'
    And request
      """
        {
          "id": "#(globalPrnExpenseClassId)",
          "budgetId": "#(budgetId)",
          "expenseClassId": "#(globalPrnExpenseClassId)"
        }
      """
    When method POST
    Then assert responseStatus == 201 || responseStatus == 400

    Given path '/finance-storage/budget-expense-classes'
    And request
      """
        {
          "id": "#(globalPrnExpenseClassId)",
          "budgetId": "#(budgetId)",
          "expenseClassId": "#(globalElecExpenseClassId)"
        }
      """
    When method POST
    Then assert responseStatus == 201 || responseStatus == 400


  Scenario: Create a composite order
    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": "#(orderId)",
      "vendor": "#(globalVendorId)",
      "orderType": "Ongoing",
      "ongoing" : {
        "interval" : 123,
        "isSubscription" : true,
        "renewalDate" : "2023-05-08T00:00:00.000+00:00"
      }
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line
    Given path 'orders/order-lines'

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution =
      """
        [{
          "fundId" : "#(fundId)",
          "distributionType" : "percentage",
          "expenseClassId" : "#(globalElecExpenseClassId)",
          "value" : 100.0
        }]
      """

    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


  Scenario: Unopen the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Pending'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


  Scenario: Add fund distribution with the same fund and another expense class
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].value = 50.0
    * set poLine.fundDistribution[1] =
      """
        {
          "fundId" : "#(fundId)",
          "distributionType" : "percentage",
          "expenseClassId" : "#(globalPrnExpenseClassId)",
          "value" : 50.0
        }
      """

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Open the order again
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

