# For MODORDERS-1434
Feature: Batch create pieces updates encumbrance

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
  Scenario: Batch create pieces updates encumbrance
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

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
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 3. Open the order
    * print 'Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Add 2 pieces by batch
    * print '4. Add 2 pieces by batch'
    * call getOrderLineTitleId { poLineId: '#(poLineId)' }
    * table pieceData
      | id       | poLineId | titleId | locationId        | format     |
      | pieceId1 | poLineId | titleId | globalLocationsId | 'Physical' |
      | pieceId2 | poLineId | titleId | globalLocationsId | 'Physical' |
    Given path 'orders/pieces-batch'
    And request { pieces: '#(pieceData)', totalRecords: 2 }
    And param createItem = true
    When method POST
    Then status 201

    # 5. Check encumbrance transaction
    * print '5. Check encumbrance transaction'
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And match encumbranceTr.amount == 3.0
    And match encumbranceTr.encumbrance.initialAmountEncumbered == 3.0
    And match encumbranceTr.encumbrance.status == 'Unreleased'

    # 6. Check budget
    * print '6. Check budget'
    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.encumbered == 3.0
