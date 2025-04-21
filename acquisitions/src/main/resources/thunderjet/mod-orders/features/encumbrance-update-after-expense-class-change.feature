@parallel=false
# for MODORDERS-1039
Feature: Encumbrance update after expense class change

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def unopenOrder = read('classpath:thunderjet/mod-orders/reusable/unopen-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def statusExpenseClasses = [ { expenseClassId: "#(globalPrnExpenseClassId)", status: "Active" }, { expenseClassId: "#(globalElecExpenseClassId)", status: "Active" } ]
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000, statusExpenseClasses: #(statusExpenseClasses) }


  Scenario: Create an order
    * def v = call createOrder { id: "#(orderId)" }


  Scenario: Create an order line using an expense class in a single fund distribution
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * def v = call openOrder { orderId: "#(orderId)" }


  Scenario: Change the expense class
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].expenseClassId = globalElecExpenseClassId

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Check the encumbrance expense class
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].expenseClassId == globalElecExpenseClassId


  Scenario: Unopen the order
    * def v = call unopenOrder { orderId: "#(orderId)" }


  Scenario: Change the expense class
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Check the encumbrance expense class again
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].expenseClassId == globalPrnExpenseClassId


  Scenario: Add a fund distribution to the po line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].value = 50.0
    * set poLine.fundDistribution[1] = { fundId: "#(fundId)", code: "#(fundId)", distributionType: "percentage", value: 50.0, expenseClassId: "#(globalElecExpenseClassId)" }

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Reopen the order
    * def v = call openOrder { orderId: "#(orderId)" }


  Scenario: Check the encumbrances expense classes
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def fundDistribution = $.fundDistribution

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def transaction1 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[0].encumbrance + "')]")[0]
    * def transaction2 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[1].encumbrance + "')]")[0]
    And match transaction1.expenseClassId == fundDistribution[0].expenseClassId
    And match transaction2.expenseClassId == fundDistribution[1].expenseClassId


  Scenario: Switch expense classes
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].expenseClassId = globalElecExpenseClassId
    * set poLine.fundDistribution[1].expenseClassId = globalPrnExpenseClassId

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Check the encumbrances expense classes again
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def fundDistribution = $.fundDistribution

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def transaction1 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[0].encumbrance + "')]")[0]
    * def transaction2 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[1].encumbrance + "')]")[0]
    And match transaction1.expenseClassId == fundDistribution[0].expenseClassId
    And match transaction2.expenseClassId == fundDistribution[1].expenseClassId


  Scenario: Unopen the order again
    * def v = call unopenOrder { orderId: "#(orderId)" }


  Scenario: Switch expense classes again
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId
    * set poLine.fundDistribution[1].expenseClassId = globalElecExpenseClassId

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Check the encumbrances expense classes again
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def fundDistribution = $.fundDistribution

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def transaction1 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[0].encumbrance + "')]")[0]
    * def transaction2 = karate.jsonPath(response, "$.transactions[?(@.id=='" + fundDistribution[1].encumbrance + "')]")[0]
    And match transaction1.expenseClassId == fundDistribution[0].expenseClassId
    And match transaction2.expenseClassId == fundDistribution[1].expenseClassId
