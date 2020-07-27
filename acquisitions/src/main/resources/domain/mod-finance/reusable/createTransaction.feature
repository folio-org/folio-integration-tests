Feature: transaction

  Background:
    * url baseUrl
    * def poLineId = callonce uuid

  Scenario: createTransaction
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)

    Given path 'finance-storage/transactions'
    And request
    """
    {
      "amount": "#(amount)",
      "currency": "USD",
      "fromFundId": "#(fundId)",
      "toFundId": "#(fundId)",
      "fiscalYearId": "#(fiscalYearId)",
      "transactionType": #(transactionType),
      "source": "User",
      "sourceInvoiceId": "#(invoiceId)",
      "expenseClassId": "#(expenseClassId)",
      "encumbrance": {
        "initialAmountEncumbered": #(amount),
        "status": "Unreleased",
        "sourcePurchaseOrderId": "#(orderId)",
        "sourcePoLineId": "#(poLineId)",
        "orderType": "One-Time",
        "subscription": false,
        "reEncumber": false
       }
    }
    """
    When method POST
    Then status 201
