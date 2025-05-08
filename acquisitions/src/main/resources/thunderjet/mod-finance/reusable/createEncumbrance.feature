Feature: Create an encumbrance

  Background:
    * url baseUrl

  Scenario: Create an encumbrance
    * def id = karate.get('id', uuid())
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def description = karate.get('description', null)
    * def sourcePurchaseOrderId = karate.get('orderId', null)
    * def sourcePoLineId = karate.get('poLineId', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def transactionEncumbrance = { initialAmountEncumbered: '#(amount)', status: 'Unreleased', sourcePurchaseOrderId: '#(sourcePurchaseOrderId)', sourcePoLineId: '#(sourcePoLineId)', orderType: 'One-Time', subscription: false, reEncumber: false }
    * def expectedStatus = karate.get('expectedStatus', 204)

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
      """
      {
      "transactionsToCreate": [{
        "id": "#(id)",
        "amount": "#(amount)",
        "currency": "USD",
        "description": "#(description)",
        "encumbrance": "#(transactionEncumbrance)",
        "expenseClassId": "#(expenseClassId)",
        "fiscalYearId": "#(fiscalYearId)",
        "fromFundId": "#(fundId)",
        "source": "User",
        "transactionType": "Encumbrance"
      }]
      }
      """
    When method POST
    Then assert responseStatus == expectedStatus
