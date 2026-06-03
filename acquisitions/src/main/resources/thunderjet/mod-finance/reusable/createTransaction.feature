Feature: Create transaction

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create transaction
    * def id = karate.get('id', uuid())
    * def poLineId = karate.get('poLineId', null)
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def sourceInvoiceId = karate.get('invoiceId', null)
    * def sourcePurchaseOrderId = karate.get('orderId', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def transactionEncumbrance = { initialAmountEncumbered: '#(amount)', status: 'Unreleased', sourcePurchaseOrderId: '#(sourcePurchaseOrderId)', sourcePoLineId: '#(poLineId)', orderType: 'One-Time', subscription: false, reEncumber: false }
    * def transactionEncumbrance = transactionType == 'Encumbrance' ? transactionEncumbrance : null
    * def fundId = karate.get('fundId', null)
    * def creditTransactions = ['Allocation', 'Credit', 'Rollover transfer']
    * def fromFundId = karate.get('fromFundId', creditTransactions.includes(transactionType) ? null : fundId)
    * def toFundId = karate.get('toFundId', creditTransactions.includes(transactionType) ? fundId : null)

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(id)",
        "amount": "#(amount)",
        "currency": "USD",
        "fromFundId": "#(fromFundId)",
        "toFundId": "#(toFundId)",
        "fiscalYearId": "#(fiscalYearId)",
        "transactionType": "#(transactionType)",
        "source": "User",
        "sourceInvoiceId": "#(sourceInvoiceId)",
        "expenseClassId": "#(expenseClassId)",
        "encumbrance": #(transactionEncumbrance)
      }]
    }
    """
    When method POST
    Then status 204
