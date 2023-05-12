Feature: transaction

  Background:
    * url baseUrl

  Scenario: createTransaction
    * def id = karate.get('id', null)
    * def poLineId = karate.get('poLineId', null)
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def sourceInvoiceId = karate.get('invoiceId', null)
    * def sourcePurchaseOrderId = karate.get('orderId', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def transactionEncumbrance = { initialAmountEncumbered: #(amount), status: 'Unreleased', sourcePurchaseOrderId: #(sourcePurchaseOrderId), sourcePoLineId: #(poLineId), orderType: 'One-Time', subscription: false, reEncumber: false }
    * def transactionEncumbrance = transactionType == 'Encumbrance' ? transactionEncumbrance : null

    Given path 'finance-storage/transactions'
    And request
    """
    {
      "id": "#(id)",
      "amount": "#(amount)",
      "currency": "USD",
      "fromFundId": "#(fundId)",
      "toFundId": "#(fundId)",
      "fiscalYearId": "#(fiscalYearId)",
      "transactionType": #(transactionType),
      "source": "User",
      "sourceInvoiceId": "#(sourceInvoiceId)",
      "expenseClassId": "#(expenseClassId)",
      "encumbrance": #(transactionEncumbrance)
    }
    """
    When method POST
    Then status 201
