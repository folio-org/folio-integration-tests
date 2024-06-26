# Created for MODORDERS-894
Feature: Should unopen order after adding the same fund reference with another expense class

  Background:
    * url baseUrl
    * print karate.info.scenarioName

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def unopenOrder = read('classpath:thunderjet/mod-orders/reusable/unopen-order.feature')
    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

  @Positive
  Scenario: Should unopen order after adding the same fund reference with another expense class
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print '1. Prepare expense classes'
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active' }]}

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

    * print '2. Create a composite order'
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

    * print '3. Create an order line'
    Given path 'orders/order-lines'

    * copy poLine = orderLineTemplate
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

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '5. Unopen the order'
    * def v = call unopenOrder { orderId: '#(orderId)' }

    * print '6. Add fund distribution with the same fund and another expense class'
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

    * print '7. Open the order again'
    * def v = call openOrder { orderId: '#(orderId)' }

