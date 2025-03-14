Feature: Test allowable encumbrance and expenditure restrictions

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser
    * call variables

    * def ledgerId = call uuid

    # the ledger needs to have restrictEncumbrance=true
    * def v = call createLedger { id: '#(ledgerId)' }


  Scenario Outline: Test allowable encumbrance: remaining encumbrance would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * def v = call createFund { id: '#(fundId)' }

    * def v = call createBudget { allowableExpenditure: 120.0 }

    * def result = call createEncumbrance { expectedStatus: <status> }
    * assert status == 204 || result.response.errors[0].code == 'budgetRestrictedEncumbranceError'

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPayment | expenditures | allowableEncumbrance | amount | status |
      | positive   | 100        | 10           | 50         | 25              | 17           | 110                  | 28     | 204    |
      | zero       | 100        | 10           | 50         | 25              | 17           | 110                  | 29     | 204    |
      | negative   | 100        | 10           | 50         | 25              | 17           | 110                  | 30     | 422    |


  Scenario Outline: Test allowable encumbrance with pending payment: remaining encumbrance would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def poLineId = call uuid

    * def v = call createFund { id: '#(fundId)' }

    * def v = call createBudget

    * def result = call createPendingPayment { expectedStatus: <status> }
    * assert status == 204 || result.response.errors[0].code == 'budgetRestrictedEncumbranceError'

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPayment | expenditures | amount | status |
      | positive   | 100        | 10           | 50         | 25              | 25           | 9      | 204    |
      | zero       | 100        | 10           | 50         | 25              | 25           | 10     | 204    |
      | negative   | 100        | 10           | 50         | 25              | 25           | 11     | 422    |


  Scenario Outline: Test allowable expenditure with pending payment: remaining expenditure would be <remaining>
    * def fundId = call uuid
    * def orderId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def poLineId = call uuid
    * def encumbranceId = call uuid
    * def pendingPaymentId = call uuid

    * def v = call createFund { id: '#(fundId)' }

    * def v = call createBudget

    * def v = call createEncumbrance { id: '#(encumbranceId)', amount: <encumbrance> }

    * def result = call createPendingPayment { releaseEncumbrance: true, expectedStatus: <status> }
    * assert status == 204 || result.response.errors[0].code == 'budgetRestrictedExpendituresError'

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | awaitingPayment | expenditures | encumbrance | amount | status |
      | positive   | 100        | 10           | 0          | 50              | 50           | 10          | 9      | 204    |
      | zero       | 100        | 10           | 0          | 50              | 50           | 10          | 10     | 204    |
      | negative   | 100        | 10           | 0          | 50              | 50           | 10          | 11     | 422    |


  Scenario Outline: Test allowable expenditure with payment: remaining expenditure would be <remaining>
    * def fundId = call uuid
    * def invoiceId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * def v = call createFund { id: '#(fundId)' }

    * def v = call createBudget

    * def v = call createPendingPayment { amount: <ppAmount> }

    * def result = call createPayment { amount: <paymentAmount>, expectedStatus: <status> }
    * assert status == 204 || result.response.errors[0].code == 'budgetRestrictedExpendituresError'

    Examples:
      | remaining  | allocated  | netTransfers | encumbered | ppAmount | paymentAmount | status |
      | positive   | 100        | 10           | 0          |  10      |  8            | 204    |
      | positive   | 100        | 10           | 0          |  10      |  9            | 204    |
      | positive   | 100        | 10           | 0          |  10      | 10            | 204    |
