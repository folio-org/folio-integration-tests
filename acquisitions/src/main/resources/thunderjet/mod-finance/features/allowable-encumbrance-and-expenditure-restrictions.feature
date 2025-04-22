Feature: Test allowable encumbrance and expenditure restrictions

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }

    * configure headers = headersAdmin
    * call variables

    * def ledgerId = call uuid

    # the ledger needs to have restrictEncumbrance=true
    * call createLedger { 'id': '#(ledgerId)'}


  Scenario Outline: Test allowable encumbrance: remaining encumbrance would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def encumbranceId = call uuid

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(ledgerId)' }

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "allocated": <allocated>,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPmt>,
      "expenditures": <expenditures>,
      "netTransfers": <netTransfers>,
      "allowableEncumbrance": <allowableEnc>,
      "allowableExpenditure": 120.0
    }
    """
    When method POST
    Then status 201

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(encumbranceId)",
        "amount": <newEnc>,
        "currency": "USD",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance": {
          "initialAmountEncumbered": <newEnc>,
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": "#(orderId)",
          "sourcePoLineId": "#(poLineId)"
        }
      }]
    }
    """
    When method POST
    Then status <status>

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPmt | expenditures | allowableEnc | newEnc | status |
      | positive   | 100        | 10           | 50         | 25          | 17           | 110          | 28     | 204    |
      | zero       | 100        | 10           | 50         | 25          | 17           | 110          | 29     | 204    |
      | negative   | 100        | 10           | 50         | 25          | 17           | 110          | 30     | 422    |


  Scenario Outline: Test allowable expenditure with pending payment: remaining expenditure would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def poLineId = call uuid
    * def encumbranceId = call uuid
    * def pendingPaymentId = call uuid

    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(ledgerId)' }

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "allocated": <allocated>,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPmt>,
      "expenditures": <expenditures>,
      "netTransfers": <netTransfers>,
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": <allowableExp>
    }
    """
    When method POST
    Then status 201

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(encumbranceId)",
        "amount": <encumbrance>,
        "currency": "USD",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance": {
          "initialAmountEncumbered": <encumbrance>,
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": "#(orderId)",
          "sourcePoLineId": "#(poLineId)"
        }
      }]
    }
    """
    When method POST
    Then status 204

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(pendingPaymentId)",
        "amount": <amount>,
        "currency": "USD",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Pending payment",
        "awaitingPayment": {
          "encumbranceId": "#(encumbranceId)",
          "releaseEncumbrance": <encumbrance>
        },
        "sourceInvoiceId": "#(invoiceId)",
        "sourceInvoiceLineId": "#(invoiceLineId)"
      }]
    }
    """
    When method POST
    Then status <status>

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPmt | expenditures | allowableExp | encumbrance | amount | status |
      | positive   | 100        | 10           | 50         | 25          | 17           | 100          | 17          | 17     | 204    |
      | zero       | 100        | 10           | 50         | 25          | 17           | 100          | 17          | 18     | 204    |
      | negative   | 100        | 10           | 50         | 25          | 17           | 100          | 18          | 19     | 422    |


  Scenario Outline: Test allowable expenditure with payment: remaining expenditure would be <remaining>
    * def fundId = call uuid
    * def invoiceId = call uuid
    * def paymentId = call uuid

    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(ledgerId)' }

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "allocated": <allocated>,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPmt>,
      "expenditures": <expenditures>,
      "netTransfers": <netTransfers>,
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": <allowableExp>
    }
    """
    When method POST
    Then status 201

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(paymentId)",
        "amount": <amount>,
        "currency": "USD",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Payment",
        "sourceInvoiceId": "#(invoiceId)"
      }]
    }
    """
    When method POST
    Then status <status>

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPmt | expenditures | allowableExp | amount | status |
      | positive   | 100        | 10           | 50         | 25          | 17           | 100          | 17     | 204    |
      | positive   | 100        | 10           | 50         | 25          | 17           | 100          | 18     | 204    |
      | positive   | 100        | 10           | 50         | 25          | 17           | 100          | 19     | 204    |

