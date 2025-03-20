Feature: Create a pending payment

  Background:
    * url baseUrl

  Scenario: Create a pending payment
    * def id = karate.get('id', uuid())
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def description = karate.get('description', null)
    * def fromFundId = karate.get('fundId', null)
    * def sourceInvoiceId = karate.get('invoiceId', null)
    * def sourceInvoiceLineId = karate.get('invoiceLineId', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def encumbranceId = karate.get('encumbranceId', null)
    * def releaseEncumbrance = karate.get('releaseEncumbrance', false)
    * def awaitingPayment = { encumbranceId: '#(encumbranceId)', releaseEncumbrance: '#(releaseEncumbrance)' }
    * def expectedStatus = karate.get('expectedStatus', 204)

    Given path 'finance-storage/transactions/batch-all-or-nothing'
    And request
      """
      {
        "transactionsToCreate": [{
          "id": "#(id)",
          "amount": "#(amount)",
          "awaitingPayment": "#(awaitingPayment)",
          "currency": "USD",
          "description": "#(description)",
          "expenseClassId": "#(expenseClassId)",
          "fiscalYearId": "#(fiscalYearId)",
          "fromFundId": "#(fromFundId)",
          "source": "User",
          "sourceInvoiceId": "#(sourceInvoiceId)",
          "sourceInvoiceLineId": "#(sourceInvoiceLineId)",
          "transactionType": "Pending payment"
        }]
      }
      """
    When method POST
    Then assert responseStatus == expectedStatus
