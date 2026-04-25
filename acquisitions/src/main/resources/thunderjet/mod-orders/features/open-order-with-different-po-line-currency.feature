Feature: Open order with different po line currency

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Open order with different po line currency
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineIdOne = call uuid
    * def orderLineIdTwo = call uuid

    # 1. create fund and budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 9999 }

    # 2. Create order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create order lines
    * table lines
      | id             | currency |
      | orderLineIdOne | 'USD'    |
      | orderLineIdTwo | 'EUR'    |
    * def v = call createOrderLine lines

    # 4. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Check encumbrances
    * configure headers = headersAdmin
    Given path '/finance/exchange-rate'
    And param from = 'EUR'
    And param to = 'USD'
    When method GET
    Then status 200
    * def rate = $.exchangeRate

    Given path 'finance/transactions'
    And param query = "transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==" + orderId +  " and encumbrance.sourcePoLineId==" + orderLineIdTwo
    When method GET
    Then status 200
    * def transaction = $.transactions[0]
    And match transaction.amount == java.math.BigDecimal.valueOf(rate).setScale(2, java.math.RoundingMode.HALF_EVEN);
    And match transaction.currency == 'USD'
