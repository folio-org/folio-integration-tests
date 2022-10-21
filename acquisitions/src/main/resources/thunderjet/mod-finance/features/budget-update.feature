Feature: Budget expense classes

  Background:
    * url baseUrl
    # uncomment below line for development
#   * callonce dev {tenant: 'testfinance3'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2


  Scenario: Budget's totals should not be changed upon budget update
    * def initialAllocation = 100.0
    * def allocationTo = 50.0
    * def allocationFrom = 30.0
    * def allocated = 100.22
    * def available = 30.11
    * def unavailable = 80.11
    * def netTransfers = 10.0
    * def awaitingPayment = 20.3
    * def encumbered = 30.2
    * def expenditures = 30.6
    * def overEncumbrance = 0.0
    * def overExpended = 0.0
    * def newAllowableEncumbrance = 110.0
    * def newAllowableExpenditure = 111.11


    * call createFund { 'id': '#(fundId)'}

    Given path '/finance-storage/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "initialAllocation": #(initialAllocation),
      "allocationTo": #(allocationTo),
      "allocationFrom": #(allocationFrom),
      "netTransfers": #(netTransfers),
      "awaitingPayment": #(awaitingPayment),
      "encumbered": #(encumbered),
      "expenditures": #(expenditures),
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": 100.0
    }
    """
    When method POST
    Then status 201

    Given path '/finance/budgets', budgetId
    And request
    """
    {
      "id": "#(budgetId)",
      "_version": "1",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "initialAllocation": #(initialAllocation),
      "allocationTo": #(allocationTo),
      "allocationFrom": #(allocationFrom),
      "allocated": 1000,
      "available": 300,
      "unavailable": 800,
      "netTransfers": 100,
      "awaitingPayment": 200,
      "encumbered": 300,
      "expenditures": 300,
      "overEncumbrance": 1000,
      "overExpended": 1234,
      "allowableEncumbrance": #(newAllowableEncumbrance),
      "allowableExpenditure": #(newAllowableExpenditure)
    }
    """
    When method PUT
    Then status 204

    Given path '/finance/budgets/', budgetId
    When method GET
    Then status 200
    And match response.initialAllocation == initialAllocation
    * match response.allocationTo == allocationTo
    * match response.allocationFrom == allocationFrom
    * match response.netTransfers == netTransfers
    * match response.awaitingPayment == awaitingPayment
    * match response.encumbered == encumbered
    * match response.expenditures == expenditures
    * match response.allowableEncumbrance == newAllowableEncumbrance
    * match response.allowableExpenditure == newAllowableExpenditure

