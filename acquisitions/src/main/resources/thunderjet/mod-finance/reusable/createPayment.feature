Feature: Create a payment

  Background:
    * url baseUrl

  Scenario: Create a payment
    * def id = karate.get('id', uuid())
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def description = karate.get('description', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def encumbranceId = karate.get('encumbranceId', null)
    * def fromFundId = karate.get('fundId', null)
    * def sourceInvoiceId = karate.get('invoiceId', null)
    * def sourceInvoiceLineId = karate.get('invoiceLineId', null)
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
          "expenseClassId": "#(expenseClassId)",
          "fiscalYearId": "#(fiscalYearId)",
          "source": "User",
          "fromFundId": "#(fundId)",
          "transactionType": "Payment",
          "paymentEncumbranceId": "#(encumbranceId)",
          "sourceInvoiceId": "#(sourceInvoiceId)",
          "sourceInvoiceLineId": "#(sourceInvoiceLineId)"
        }]
      }
      """
    When method POST
    Then assert responseStatus == expectedStatus
