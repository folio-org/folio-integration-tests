Feature: Unopen order and add addition POL and 1 Fund. Also verify encumbrances

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Unopen order and add addition POL and 1 Fund. Also verify encumbrances

    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    # 1. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId)', fundId: '#(globalFundId)' }

    # 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Check that order status Open in encumbrance after Open order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId1+"')]")[0]
    And match transaction.amount == 1.0
    And match transaction.currency == 'USD'
    And match transaction.encumbrance.initialAmountEncumbered == 1.0
    And match transaction.encumbrance.status == 'Unreleased'
    And match transaction.encumbrance.orderStatus == 'Open'

    # 5. UnOpen order
    * def v = call unopenOrder { orderId: '#(orderId)' }

    # 6. Check order workflow status is Pending after Unopen
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    And match orderResponse.workflowStatus == "Pending"

    # 7. Check that order status Pending in encumbrance after UnOpen order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId1+"')]")[0]
    And match transaction.amount == 0
    And match transaction.currency == 'USD'
    And match transaction.encumbrance.initialAmountEncumbered == 0
    And match transaction.encumbrance.status == 'Pending'
    And match transaction.encumbrance.orderStatus == 'Pending'

    # 8. Create order line after Unopen order
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId)', fundId: '#(globalFundId)' }

    # 9. Reopen order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 10. Check order after Reopen
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == "Open"

    # 11. Check that order status Open in encumbrance after Reopen order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def encumbrance1 = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId1+"')]")[0]
    * def encumbrance2 = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId2+"')]")[0]
    And match encumbrance1.amount == 1.0
    And match encumbrance1.currency == 'USD'
    And match encumbrance1.encumbrance.initialAmountEncumbered == 1.0
    And match encumbrance1.encumbrance.status == 'Unreleased'
    And match encumbrance1.encumbrance.orderStatus == 'Open'
    And match encumbrance2.amount == 1.0
    And match encumbrance2.currency == 'USD'
    And match encumbrance2.encumbrance.initialAmountEncumbered == 1.0
    And match encumbrance2.encumbrance.status == 'Unreleased'
    And match encumbrance2.encumbrance.orderStatus == 'Open'
