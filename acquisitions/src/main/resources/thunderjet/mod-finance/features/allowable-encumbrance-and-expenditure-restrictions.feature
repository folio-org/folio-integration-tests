Feature: Test allowable encumbrance and expenditure restrictions

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_finance4'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def ledgerId = callonce uuid

    # the ledger needs to have restrictEncumbrance=true
    * callonce createLedger { 'id': '#(ledgerId)'}


  Scenario Outline: Test allowable encumbrance: remaining encumbrance would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerId) }

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
      "allowableExpenditure": 100.0
    }
    """
    When method POST
    Then status 201

    Given path 'finance/order-transaction-summaries'
    And request
    """
      {
        "id": "#(orderId)",
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
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
      }
    """
    When method POST
    Then status <status>

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPmt | expenditures | allowableEnc | newEnc | status |
      | positive   | 100        | 10           | 50         | 25          | 17           | 110          | 28     | 201    |
      | zero       | 100        | 10           | 50         | 25          | 17           | 110          | 29     | 201    |
      | negative   | 100        | 10           | 50         | 25          | 17           | 110          | 30     | 400    |


  Scenario Outline: Test allowable expenditure with pending payment: remaining expenditure would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def poLineId = call uuid
    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerId) }

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

    Given path 'finance/order-transaction-summaries'
    And request
    """
      {
        "id": "#(orderId)",
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201

    Given path 'finance/encumbrances'
    And request
    """
      {
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
      }
    """
    When method POST
    Then status 201
    * def encumbranceId = $.id

    Given path 'finance/invoice-transaction-summaries'
    And request
    """
      {
        "id": "#(invoiceId)",
        "numPendingPayments": 1,
        "numPaymentsCredits": 1
      }
    """
    When method POST
    Then status 201

    Given path 'finance/pending-payments'
    And request
    """
      {
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
      }
    """
    When method POST
    Then status <status>

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPmt | expenditures | allowableExp | encumbrance | amount | status |
      | positive   | 100        | 10           | 50         | 25          | 17           | 100          | 17          | 17     | 201    |
      | zero       | 100        | 10           | 50         | 25          | 17           | 100          | 17          | 18     | 201    |
      | negative   | 100        | 10           | 50         | 25          | 17           | 100          | 18          | 19     | 400    |


  Scenario Outline: Test allowable expenditure with payment: remaining expenditure would be <remaining>
    * def fundId = call uuid
    * def invoiceId = call uuid
    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerId) }

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

    Given path 'finance/invoice-transaction-summaries'
    And request
    """
      {
        "id": "#(invoiceId)",
        "numPendingPayments": 0,
        "numPaymentsCredits": 1
      }
    """
    When method POST
    Then status 201

    Given path 'finance/payments'
    And request
    """
      {
        "amount": <amount>,
        "currency": "USD",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Payment",
        "sourceInvoiceId": "#(invoiceId)"
      }
    """
    When method POST
    Then status <status>

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPmt | expenditures | allowableExp | amount | status |
      | positive   | 100        | 10           | 50         | 25          | 17           | 100          | 17     | 201    |
      | zero       | 100        | 10           | 50         | 25          | 17           | 100          | 18     | 201    |
      | negative   | 100        | 10           | 50         | 25          | 17           | 100          | 19     | 400    |

