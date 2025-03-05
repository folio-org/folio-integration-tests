Feature: Budge's totals (available, unavailable, encumbered) is updated when encumbrance's amount is changed but status has not been changed

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }

    * configure headers = headersAdmin

    * def orderId = callonce uuid
    * def poLineId = callonce uuid
    * def budgetId = "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a697"
    * def encumbranceAmountChanged = 20

  Scenario: Update encumbrance flow

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    * def budgetBefore = $

    * def encumbranceId = call uuid
    * def encumbrance =
    """
    {
      "id": "#(encumbranceId)",
      "amount": 10,
      "currency": "USD",
      "description": "PO_Line: History of Incas",
      "fiscalYearId": ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2,
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
    And request
    """
    {
      "transactionsToCreate": [ #(encumbrance) ]
    }
    """
    When method POST
    Then status 204


    ## retrieve modified encumbrance
    Given path 'finance/transactions', encumbrance.id
    When method GET
    Then status 200
    * def created_encumbrance = $

    * set created_encumbrance.amount = encumbranceAmountChanged
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
    "transactionsToUpdate": [ #(created_encumbrance) ]
    }
    """
    When method POST
    Then status 204

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200

    And match $.available == budgetBefore.available - encumbranceAmountChanged
    And match $.unavailable == budgetBefore.unavailable + encumbranceAmountChanged
    And match $.encumbered == budgetBefore.encumbered + encumbranceAmountChanged
