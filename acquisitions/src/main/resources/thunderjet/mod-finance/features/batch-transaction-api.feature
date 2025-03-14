# For MODFISTO-458, MODFISTO-515
Feature: Batch Transaction API

Background:
  * print karate.info.scenarioName

  * url baseUrl
  * callonce login testUser
  * def okapitokenUser = okapitoken

  * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
  * configure headers = headersUser

  * callonce variables


Scenario: Use the batch transaction API to create, update and delete transactions
  * def fundId = call uuid
  * def budgetId = call uuid
  * def orderId = call uuid
  * def poLineId1 = call uuid
  * def poLineId2 = call uuid
  * def poLineId3 = call uuid
  * def invoiceId = call uuid
  * def invoiceLineId1 = call uuid
  * def invoiceLineId2 = call uuid
  * def encumbranceId1 = call uuid
  * def encumbranceId2 = call uuid
  * def encumbranceId3 = call uuid
  * def allocationId = call uuid
  * def pendingPaymentId1 = call uuid
  * def pendingPaymentId2 = call uuid

  * print "Create fund and budget"
  * def v = call createFund { id: '#(fundId)' }
  * def v = call createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }

  * print "Create initial transactions"
  * table encumbrances
    | id             | amount | description     | poLineId  |
    | encumbranceId1 | 10     | 'encumbrance 1' | poLineId1 |
    | encumbranceId2 | 5      | 'encumbrance 2' | poLineId2 |
    | encumbranceId3 | 3      | 'encumbrance 3' | poLineId3 |
  * def v = call createEncumbrance encumbrances


  * print "Call the batch transaction API to create, update and delete transactions"

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
      "#(encumbrance3)"
    ],
    "idsOfTransactionsToDelete": [
      "#(encumbranceId2)"
    ]
  }
  """
  When method POST
  Then status 204


  * print "Check resulting transactions and budget"

  Given path 'finance/transactions'
  And param query = 'fromFundId==' + fundId
  When method GET
  Then status 200
  And match $.totalRecords == 4

  Given path 'finance/transactions'
  And param query = 'toFundId==' + fundId
  When method GET
  Then status 200
  # the second allocation is the initial allocation for the fund
  And match $.totalRecords == 2

  # Note: budgets are not updated when an encumbrance is deleted
  Given path '/finance/budgets', budgetId
  When method GET
  Then status 200
  And match $.allocated == 107
  And match $.available == 83
  And match $.expenditures == 0
  And match $.credits == 0
  And match $.encumbered == 5
  And match $.awaitingPayment == 19
  And match $.unavailable == 24


Scenario Outline: Create and delete a pending payment with an encumbrance - releaseEncumbrance: <releaseEncumbrance>
  * def fundId = call uuid
  * def budgetId = call uuid
  * def orderId = call uuid
  * def poLineId = call uuid
  * def invoiceId = call uuid
  * def invoiceLineId = call uuid
  * def encumbranceId = call uuid
  * def pendingPaymentId = call uuid
  * def releaseEncumbrance = <releaseEncumbrance>

  * print "Create fund and budget"
  * def v = call createFund { id: '#(fundId)' }
  * def v = call createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }

  * print "Create the encumbrance and pending payment"
  * def v = call createEncumbrance { id: '#(encumbranceId)', amount: 10 }
  * def v = call createPendingPayment { id: '#(pendingPaymentId)', amount: 5, encumbranceId: '#(encumbranceId)', releaseEncumbrance: '#(releaseEncumbrance)' }


  * print "Delete the pending payment"

  Given path 'finance/transactions/batch-all-or-nothing'
  And request
    """
    {
      "idsOfTransactionsToDelete": [
        "#(pendingPaymentId)"
      ]
    }
    """
  When method POST
  Then status 204


  * print "Check resulting transactions and budget"

  Given path 'finance/transactions', pendingPaymentId
  When method GET
  Then status 404

  Given path 'finance/transactions', encumbranceId
  When method GET
  Then status 200
  And match $.amount == releaseEncumbrance ? 0 : 10
  And match $.encumbrance.initialAmountEncumbered == 10
  And match $.encumbrance.amountAwaitingPayment == 0
  And match $.encumbrance.status == releaseEncumbrance ? 'Released' : 'Unreleased'

  Given path '/finance/budgets', budgetId
  When method GET
  Then status 200
  And match $.allocated == 100
  And match $.available == releaseEncumbrance ? 100 : 90
  And match $.expenditures == 0
  And match $.credits == 0
  And match $.encumbered == releaseEncumbrance ? 0 : 10
  And match $.awaitingPayment == 0
  And match $.unavailable == releaseEncumbrance ? 0 : 10

Examples:
  | releaseEncumbrance  |
  | true                |
  | false               |
