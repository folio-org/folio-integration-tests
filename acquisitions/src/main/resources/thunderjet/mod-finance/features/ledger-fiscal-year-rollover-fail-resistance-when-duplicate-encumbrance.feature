# for https://folio-org.atlassian.net/browse/MODFISTO-461
Feature: Verify fault tolerance ledger fiscal year rollover when occurred duplicate encumbrance

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fromFiscalYearId = callonce uuid1
    * def toFiscalYearId = callonce uuid2
    * def ledgerId = callonce uuid3
    * def rolloverId = callonce uuid4
    * def fundId = callonce uuid5
    * def budgetId = callonce uuid6
    * def orderId = callonce uuid7
    * def poLineId = callonce uuid8
    * def duplicateEncumbranceId = callonce uuid9

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

    * configure retry = { count: 10, interval: 5000 }

  Scenario: Verify fault tolerance ledger fiscal year rollover when occurred duplicate encumbrance
    * print "Prepare fiscal year with #(fromFiscalYearId) for rollover"
    * def code = fromYear
    * def periodStart = code + '-01-01T00:00:00Z'
    * def periodEnd = code + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fromFiscalYearId), code: #(codePrefix + code), periodStart: #(periodStart), periodEnd: #(periodEnd) }


    * print "Prepare fiscal year with #(toFiscalYearId) for rollover"
    * def code = toYear
    * def periodStart = code + '-01-01T00:00:00Z'
    * def periodEnd = code + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(toFiscalYearId), code: #(codePrefix + code), periodStart: #(periodStart), periodEnd: #(periodEnd) }


    * print "Prepare finances"
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fromFiscalYearId) }
    * def v = call createFund { id: #(fundId),  code: #(fundId), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), fiscalYearId: #(fromFiscalYearId), allocated: 100 }


    * print "Create and open an order"
    * configure headers = headersAdmin
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }
    * def v = call openOrder { orderId: "#(orderId)" }
    * configure headers = headersUser


    * print "Create a duplicate encumbrance"
    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + fromFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def duplicateEncumbrance = response.transactions[0]
    * set duplicateEncumbrance.id = duplicateEncumbranceId
    * set duplicateEncumbrance.encumbrance.status = 'Released'
    * remove duplicateEncumbrance._version
    * remove duplicateEncumbrance.metadata

    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [ #(duplicateEncumbrance) ]
    }
    """
    When method POST
    Then status 204


    * print "Start rollover #(rolloverId) for ledger #(ledgerId)"
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "adjustAllocation": 0.0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "addAvailableTo" : "Available"
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "One-time",
            "basedOn": "InitialAmount",
            "increaseBy": 0
          }
        ]
      }
    """
    When method POST
    Then status 201


    * print "Wait for rollover to end"
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


    * print "Check rollover logs for rolloverId=#(rolloverId)"
    Given path 'finance/ledger-rollovers-logs', rolloverId
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Commit'


    * print "Check rollover statuses rolloverId=#(rolloverId)"
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


    * print "Check that only one encumbrance was created in new fiscal year"
    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.totalRecords == 1