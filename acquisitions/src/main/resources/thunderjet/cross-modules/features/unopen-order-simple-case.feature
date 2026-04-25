Feature: Unpopen order with one line and check encumbrance

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Unpopen order with one line and check encumbrance

    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Prepare finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    # 2. Create orders
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 4. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Check that order status Open in encumbrance after Open order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId+"')]")[0]
    And match transaction.amount == 1.0
    And match transaction.currency == 'USD'
    And match transaction.encumbrance.initialAmountEncumbered == 1.0
    And match transaction.encumbrance.status == 'Unreleased'
    And match transaction.encumbrance.orderStatus == 'Open'

    # 6. Unopen order
    * def v = call unopenOrder { orderId: '#(orderId)' }

    # 7. Check order workflow status is Pending after Unopen
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    And match orderResponse.workflowStatus == "Pending"

    # 8. Check that order status Pending in encumbrance after Unopen order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId+"')]")[0]
    And match transaction.amount == 0
    And match transaction.currency == 'USD'
    And match transaction.encumbrance.initialAmountEncumbered == 0
    And match transaction.encumbrance.status == 'Pending'
    And match transaction.encumbrance.orderStatus == 'Pending'
