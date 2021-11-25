Feature: Test changing encumbrance from Released to Unreleased

  Background:
    * url baseUrl
    * callonce login testAdmin
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

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
    Given path 'finance-storage/order-transaction-summaries'
    And request
    """
      {
        "id": '#(orderId1)',
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201
    Given path 'finance/encumbrances'
    And request
    """
      {
        "amount": 10,
        "currency": "USD",
        "description": "PO_Line: History of Incas",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(globalFundId)",
        "transactionType": "Encumbrance",
        "encumbrance" : {
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
    When method POST
    Then status 201
    * def transaction = $

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
    * set transaction.encumbrance.status = "Unreleased"
    Given path 'finance/order-transaction-summaries', orderId1
    And request
    """
      {
        "id": '#(orderId1)',
        "numTransactions": 1
      }
    """
    When method PUT
    Then status 204
    Given path 'finance/encumbrances', transaction.id
    And request transaction
    When method PUT
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

    # create a pending encumbrance transaction with a positive amountExpended
    Given path 'finance-storage/order-transaction-summaries'
    And request
    """
      {
        "id": '#(orderId2)',
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201
    Given path 'finance/encumbrances'
    And request
    """
      {
        "amount": 10,
        "currency": "USD",
        "description": "PO_Line: History of Incas",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(globalFundId)",
        "transactionType": "Encumbrance",
        "encumbrance" : {
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
    When method POST
    Then status 201
    * def transaction = $

    # release the encumbrance
    * set transaction.encumbrance.status = "Released"
    Given path 'finance/release-encumbrance', transaction.id
    And request {}
    When method POST
    Then status 204

    # Check no error is returned if amountExpended is not 0 when trying to unrelease
    * set transaction.encumbrance.status = "Unreleased"
    Given path 'finance/order-transaction-summaries', orderId2
    And request
    """
      {
        "id": '#(orderId2)',
        "numTransactions": 1
      }
    """
    When method PUT
    Then status 204
    Given path 'finance/encumbrances', transaction.id
    And request transaction
    When method PUT
    Then status 204
