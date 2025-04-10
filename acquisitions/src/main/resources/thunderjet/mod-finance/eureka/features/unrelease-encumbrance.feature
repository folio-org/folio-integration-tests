Feature: Test changing encumbrance from Released to Unreleased

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }

    * configure headers = headersAdmin

    * callonce variables
    * def orderId1 = callonce uuid1
    * def orderId2 = callonce uuid2
    * def poLineId1 = callonce uuid3
    * def poLineId2 = callonce uuid4

  Scenario: Test Encumbrance Transition from Released to Unreleased

    # retrieve budge info for later
    Given path '/finance/budgets', globalBudgetId
    When method GET
    Then status 200
    * def budgetBefore = $

    # create a pending encumbrance transaction
    * def encumbranceId = call uuid
    * def transaction =
    """
    {
      "id": "#(encumbranceId)",
      "amount": 10,
      "currency": "USD",
      "description": "PO_Line: History of Incas",
      "fiscalYearId": "#(globalFiscalYearId)",
      "source": "User",
      "fromFundId": "#(globalFundId)",
      "transactionType": "Encumbrance",
      "encumbrance": {
        "initialAmountEncumbered": 10,
        "amountExpended": 0,
        "status": "Pending",
        "orderType": "One-Time",
        "subscription": false,
        "reEncumber": false,
        "sourcePurchaseOrderId": '#(orderId1)',
        "sourcePoLineId": '#(poLineId1)'
      }
    }
    """
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [ #(transaction) ]
    }
    """
    When method POST
    Then status 204

    # release the encumbrance
    * set transaction.encumbrance.status = "Released"
    Given path 'finance/release-encumbrance', transaction.id
    And request {}
    When method POST
    Then status 204

    # check the budget was not changed
    Given path '/finance/budgets', globalBudgetId
    When method GET
    Then status 200
    And match $.encumbered == budgetBefore.encumbered
    And match $.available == budgetBefore.available
    And match $.unavailable == budgetBefore.unavailable

    # unrelease the encumbrance
    Given path 'finance/transactions', transaction.id
    When method GET
    Then status 200
    * def transaction = $
    * set transaction.encumbrance.status = "Unreleased"
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
    "transactionsToUpdate": [ #(transaction) ]
    }
    """
    When method POST
    Then status 204

    # check the transaction amount and encumbrance status
    Given path 'finance/transactions', transaction.id
    And request transaction
    When method GET
    Then status 200
    And match $.encumbrance.status == "Unreleased"
    And match $.amount == 10

    # check the budget's encumbered total was updated
    Given path '/finance/budgets', globalBudgetId
    When method GET
    Then status 200
    And match $.encumbered == budgetBefore.encumbered + 10


  Scenario: Test Error when trying to unrelease expended encumbrance
    * def encumbranceId = call uuid
    # create a pending encumbrance transaction with a positive amountExpended
    * def transaction =
    """
    {
      "id": "#(encumbranceId)",
      "amount": 10,
      "currency": "USD",
      "description": "PO_Line: History of Incas",
      "fiscalYearId": "#(globalFiscalYearId)",
      "source": "User",
      "fromFundId": "#(globalFundId)",
      "transactionType": "Encumbrance",
      "encumbrance": {
        "initialAmountEncumbered": 10,
        "amountExpended": 5,
        "status": "Pending",
        "orderType": "One-Time",
        "subscription": false,
        "reEncumber": false,
        "sourcePurchaseOrderId": '#(orderId2)',
        "sourcePoLineId": '#(poLineId2)'
      }
    }
    """
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [ #(transaction) ]
    }
    """
    When method POST
    Then status 204

    # release the encumbrance
    * set transaction.encumbrance.status = "Released"
    Given path 'finance/release-encumbrance', transaction.id
    And request {}
    When method POST
    Then status 204

    # Check no error is returned if amountExpended is not 0 when trying to unrelease
    Given path 'finance/transactions', transaction.id
    When method GET
    Then status 200
    * def transaction = $
    * set transaction.encumbrance.status = "Unreleased"
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
    "transactionsToUpdate": [ #(transaction) ]
    }
    """
    When method POST
    Then status 204
