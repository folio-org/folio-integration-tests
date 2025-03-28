Feature: budget

  Background:
    * url baseUrl

  Scenario: createBudget
    * def newGeneratedBudgetId = call uuid
    * def id = karate.get('id', newGeneratedBudgetId)
    * def fundId = karate.get('fundId', globalFundId)
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def budgetStatus = karate.get('budgetStatus', 'Active')
    * def statusExpenseClasses = karate.get('statusExpenseClasses', [])
    * def allowableEncumbrance = karate.get('allowableEncumbrance', 100.0)
    * def allowableExpenditure = karate.get('allowableExpenditure', 100.0)
    * def awaitingPayment = karate.get('awaitingPayment', 0)
    * def encumbered = karate.get('encumbered', 0)
    * def expenditures = karate.get('expenditures', 0)
    * def netTransfers = karate.get('netTransfers', 0)

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "#(budgetStatus)",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": "#(allocated)",
      "awaitingPayment": "#(awaitingPayment)",
      "encumbered": "#(encumbered)",
      "expenditures": "#(expenditures)",
      "netTransfers": "#(netTransfers)",
      "allowableEncumbrance": "#(allowableEncumbrance)",
      "allowableExpenditure": "#(allowableExpenditure)",
      "statusExpenseClasses": "#(statusExpenseClasses)"
    }
    """
    When method POST
    Then status 201
