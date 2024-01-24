# For https://issues.folio.org/browse/MODFISTO-458
@parallel=false
Feature: Batch Transaction API

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def poLineId3 = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId1 = callonce uuid8
    * def invoiceLineId2 = callonce uuid9
    * def encumbranceId1 = callonce uuid10
    * def encumbranceId2 = callonce uuid11
    * def encumbranceId3 = callonce uuid12
    * def allocationId = callonce uuid13
    * def pendingPaymentId1 = callonce uuid14
    * def pendingPaymentId2 = callonce uuid15


  Scenario: Create fund and budget
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }


  Scenario: Create initial transactions without using the batch API
    Given path 'finance/order-transaction-summaries'
    And request
    """
      {
        "id": '#(orderId)',
        "numTransactions": 3
      }

    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
        "id": "#(encumbranceId1)",
        "amount": 10,
        "currency": "USD",
        "description": "Encumbrance 1",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance" : {
          "initialAmountEncumbered": 10,
          "status": "Unreleased",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": "#(orderId)",
          "sourcePoLineId": "#(poLineId1)"
        }
      }
    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
        "id": "#(encumbranceId2)",
        "amount": 5,
        "currency": "USD",
        "description": "Encumbrance 2",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance" : {
          "initialAmountEncumbered": 5,
          "status": "Unreleased",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": "#(orderId)",
          "sourcePoLineId": "#(poLineId2)"
        }
      }
    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
        "id": "#(encumbranceId3)",
        "amount": 3,
        "currency": "USD",
        "description": "Encumbrance 3",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance" : {
          "initialAmountEncumbered": 3,
          "status": "Unreleased",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": "#(orderId)",
          "sourcePoLineId": "#(poLineId3)"
        }
      }
    """
    When method POST
    Then status 201


  Scenario: Call the batch transaction API to create, update and delete transactions
    Given path 'finance/transactions', encumbranceId3
    When method GET
    Then status 200
    * def encumbrance3 = $
    * set encumbrance3.encumbrance.status = "Released"

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
{
  "transactionsToCreate": [
    {
      "id": "#(pendingPaymentId1)",
      "amount": 10,
      "currency": "USD",
      "fiscalYearId": "#(globalFiscalYearId)",
      "source": "Invoice",
      "fromFundId": "#(fundId)",
      "transactionType": "Pending payment",
      "awaitingPayment": {
        "encumbranceId": "#(encumbranceId1)",
        "releaseEncumbrance": true
      },
      "sourceInvoiceId": "#(invoiceId)",
      "sourceInvoiceLineId": "#(invoiceLineId1)"
    },
    {
      "id": "#(pendingPaymentId2)",
      "amount": 9,
      "currency": "USD",
      "fiscalYearId": "#(globalFiscalYearId)",
      "source": "Invoice",
      "fromFundId": "#(fundId)",
      "transactionType": "Pending payment",
      "awaitingPayment": {
        "releaseEncumbrance": false
      },
      "sourceInvoiceId": "#(invoiceId)",
      "sourceInvoiceLineId": "#(invoiceLineId2)"
    },
    {
      "id": "#(allocationId)",
      "amount": 7,
      "currency": "USD",
      "description": "To allocation",
      "fiscalYearId": "#(globalFiscalYearId)",
      "source": "User",
      "toFundId": "#(fundId)",
      "transactionType": "Allocation"
    }
  ],
  "transactionsToUpdate": [
    #(encumbrance3)
  ],
  "idsOfTransactionsToDelete": [
    "#(encumbranceId2)"
  ]
}
    """
    When method POST
    Then status 204


  Scenario: Check resulting transactions and budget
    Given path 'finance/transactions'
    And param query = 'fromFundId==' + fundId
    When method GET
    Then status 200
    And match $.totalRecords == 4

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Note: budgets are not updated when an encumbrance is deleted
    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.allocated == 107
    And match $.available == 83
    And match $.expenditures == 0
    And match $.encumbered == 5
    And match $.awaitingPayment == 19
    And match $.unavailable == 24
