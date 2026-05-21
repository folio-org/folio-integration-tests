# For MODORDERS-1415
Feature: No side effect with failed piece operation

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

    * def getOrderLineTitleId = read('classpath:thunderjet/mod-orders/reusable/get-order-line-title-id.feature')


  @Negative
  Scenario: Add piece with encumbrance restriction
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid

    # 1. Prepare finances with encumbrance restriction
    * print '1. Prepare finances with encumbrance restriction'
    * configure headers = headersAdmin
    * def v = call createLedger { id: '#(ledgerId)', restrictEncumbrance: true }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allowableEncumbrance: 100.0, allocated: 100 }

    # 2. Create an order and line
    * print '2. Create an order and line'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 100 }

    # 3. Open the order
    * print 'Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Add a piece, expect an error
    * print '4. Add a piece, expect an error'
    * call getOrderLineTitleId { poLineId: '#(poLineId)' }
    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    And param createItem = true
    When method POST
    Then status 422

    # 5. Check the item was not created
    * print '5. Check the item was not created'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1


  @Negative
  Scenario: Add piece with inactive budget
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid

    # 1. Prepare finances
    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createLedger { id: '#(ledgerId)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    # 2. Create an order and line
    * print '2. Create an order and line'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 5 }

    # 3. Open the order
    * print 'Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Make the budget inactive
    * print '4. Make the budget inactive'
    * configure headers = headersAdmin
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = $
    * set budget.budgetStatus = 'Inactive'
    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    # 5. Try to add a piece, expect an error
    * print '5. Try to add a piece, expect an error'
    * configure headers = headersUser
    * call getOrderLineTitleId { poLineId: '#(poLineId)' }
    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    And param createItem = true
    When method POST
    Then status 422

    # 6. Check the holdings was not created
    * print '6. Check the holdings was not created'
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1


  @Negative
  Scenario: Add pieces by batch with encumbrance restriction
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

    # 1. Prepare finances with encumbrance restriction
    * print '1. Prepare finances with encumbrance restriction'
    * configure headers = headersAdmin
    * def v = call createLedger { id: '#(ledgerId)', restrictEncumbrance: true }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allowableEncumbrance: 100.0, allocated: 100 }

    # 2. Create an order and line
    * print '2. Create an order and line'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 100 }

    # 3. Open the order
    * print 'Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Try to add 2 pieces by batch, expect an error
    * print '4. Try to add 2 pieces by batch, expect an error'
    * call getOrderLineTitleId { poLineId: '#(poLineId)' }
    * table pieceData
      | id       | poLineId | titleId | locationId        | format     |
      | pieceId1 | poLineId | titleId | globalLocationsId | 'Physical' |
      | pieceId2 | poLineId | titleId | globalLocationsId | 'Physical' |
    Given path 'orders/pieces-batch'
    And request { pieces: '#(pieceData)', totalRecords: 2 }
    And param createItem = true
    When method POST
    Then status 422

    # 5. Check no item was created
    * print '5. Check no item was created'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1

    # 6. Check no holdings was created
    * print '6. Check no holdings was created'
    * configure headers = headersUser
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1


  @Negative
  Scenario: Delete piece with inactive budget
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Prepare finances
    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createLedger { id: '#(ledgerId)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    # 2. Create an order and line with quantity: 2
    * print '2. Create an order and line with quantity: 2'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', quantity: 2 }

    # 3. Open the order
    * print 'Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Make the budget inactive
    * print '4. Make the budget inactive'
    * configure headers = headersAdmin
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = $
    * set budget.budgetStatus = 'Inactive'
    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    # 5. Try to delete a piece, expect an error
    * print '5. Try to delete a piece, expect an error'
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def pieceId = $.pieces[0].id
    Given path '/orders/pieces', pieceId
    When method DELETE
    Then status 422

    # 6. Check no item was deleted
    * print '6. Check no item was deleted'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

    # 7. Check no holdings was deleted
    * print '7. Check no holdings was deleted'
    * configure headers = headersUser
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
