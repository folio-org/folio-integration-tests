# For MODORDERS-1185
Feature: Check encumbrances after order line exchange rate update

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * call loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * call loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

  @Positive
  Scenario: Check encumbrances after order line exchange rate update to manual rate 2 times
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    ### 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }
    * configure headers = headersUser

    ### 2. Create an order and line
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    ### 3. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

   ###########################################################################################################

    ### 4. Update the order line with first manual exchange rate
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.currency = 'AUD'
    * set poLine.cost.exchangeRate = 0.7

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    ### 5. Check the budget after first manual exchange rate update
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match each $.budgets[*].available == 9999.3
    And match each $.budgets[*].expenditures == 0
    And match each $.budgets[*].encumbered ==  0.7
    And match each $.budgets[*].awaitingPayment == 0
    And match each $.budgets[*].unavailable == 0.7

    ### 6. Check encumbrances after first manual exchange rate update
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    And match each $.transactions[*].amount == 0.7
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == 0.7

    ###########################################################################################################

    ### 7. Update the order line with second manual exchange rate
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.currency = 'AUD'
    * set poLine.cost.exchangeRate = 0.8

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    ### 8. Check the budget after second manual exchange rate update
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match each $.budgets[*].available == 9999.2
    And match each $.budgets[*].expenditures == 0
    And match each $.budgets[*].encumbered ==  0.8
    And match each $.budgets[*].awaitingPayment == 0
    And match each $.budgets[*].unavailable == 0.8

    ### 9. Check encumbrances after second manual exchange rate update
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    And match each $.transactions[*].amount == 0.8
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == 0.8

  @Positive
  Scenario: Check encumbrances after order line exchange rate update from manual to dynamic exchange rate
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    ### 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 10000, fundId: "#(fundId)", status: "Active" }
    * configure headers = headersUser

    ### 2. Create an order and line
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    ### 3. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    ###########################################################################################################

    ### 4. Update the order line with first manual exchange rate
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.currency = 'AUD'
    * set poLine.cost.exchangeRate = 1234

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    ### 5. Check the budget after first manual exchange rate update
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match each $.budgets[*].available == 8766.0
    And match each $.budgets[*].expenditures == 0
    And match each $.budgets[*].encumbered == 1234
    And match each $.budgets[*].awaitingPayment == 0
    And match each $.budgets[*].unavailable == 1234

    ### 6. Check encumbrances after first manual exchange rate update
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    And match each $.transactions[*].amount == 1234
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == 1234

    ###########################################################################################################

    ### 7. Update the order line with second dynamic exchange rate
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.currency = 'AUD'
    * set poLine.cost.exchangeRate = null

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    ### 8. Check the budget after second dynamic exchange rate update
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match each $.budgets[*].available != 8766.0
    And match each $.budgets[*].expenditures == 0
    And match each $.budgets[*].encumbered != 1234
    And match each $.budgets[*].awaitingPayment == 0
    And match each $.budgets[*].unavailable != 1234

    ### 9. Check encumbrances after second dynamic exchange rate update
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
    When method GET
    Then status 200
    And match each $.transactions[*].amount != 1234
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered != 1234