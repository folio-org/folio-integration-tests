Feature: Budget's totals (available, unavailable, encumbered) is updated when encumbrance's amount is changed but status has not been changed

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * configure retry = { count: 10, interval: 10000 }

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

  @Positive
  Scenario: Update encumbrance flow
    * def orderId = call uuid
    * def poLineId = call uuid
    * def budgetId = "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a697"
    * def encumbranceAmountChanged = 20
    * def encumbranceId = call uuid

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    * def budgetBefore = $
    * def encumbrance =
    """
    {
      "id": "#(encumbranceId)",
      "amount": 10,
      "currency": "USD",
      "description": "PO_Line: History of Incas",
      "fiscalYearId": "ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
      "source": "User",
      "fromFundId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696",
      "transactionType": "Encumbrance",
      "encumbrance": {
        "initialAmountEncumbered": 10,
        "status": "Unreleased",
        "orderType": "One-Time",
        "subscription": false,
        "reEncumber": false,
        "sourcePurchaseOrderId": '#(orderId)',
        "sourcePoLineId": '#(poLineId)'
      }
    }
    """
    Given path 'finance/transactions/batch-all-or-nothing'
    And request { "transactionsToCreate": [ "#(encumbrance)" ] }
    When method POST
    Then status 204

    ## Retrieve modified encumbrance
    Given path 'finance/transactions', encumbrance.id
    When method GET
    Then status 200
    * def createdEncumbrance = $
    * set createdEncumbrance.amount = encumbranceAmountChanged
    * set createdEncumbrance.encumbrance.initialAmountEncumbered = encumbranceAmountChanged
    Given path 'finance/transactions/batch-all-or-nothing'
    And request { "transactionsToUpdate": [ "#(createdEncumbrance)" ] }
    When method POST
    Then status 204

    * def isBudgetUpdated =
      """
      function(response) {
        var expectedAvailable = budgetBefore.available - encumbranceAmountChanged;
        var expectedUnavailable = budgetBefore.unavailable + encumbranceAmountChanged;
        var expectedEncumbered = budgetBefore.encumbered + encumbranceAmountChanged;
        return response.available == expectedAvailable &&
               response.unavailable == expectedUnavailable &&
               response.encumbered == expectedEncumbered;
      }
      """
    Given path '/finance/budgets', budgetId
    And retry until responseStatus == 200 && isBudgetUpdated(response)
    When method GET
    Then status 200

