Feature: Create planned and current budgets with expense classes

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_finance'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundWithCurrBudgetId = "9b7b6e76-b7ca-4d36-a377-2155bdf0b33f"
    * def currBudgetWithExpenseClassesId = "9b7b6e76-b7ca-4d36-a377-2155bdf0b34f"
    * def plannedBudgetWithExpenseClassesId = "9b7b6e76-b7ca-4d36-a377-2155bdf0b35f"

  Scenario: Create planned and current budgets with expense classes
    * call createFund { 'id': '#(fundWithCurrBudgetId)'}
    * call createBudget { 'id': '#(currBudgetWithExpenseClassesId)', 'allocated': 10000, 'fundId': '#(fundWithCurrBudgetId)', 'statusExpenseClasses': [{'expenseClassId': '#(globalElecExpenseClassId)','status': 'Active'}]}
    * call createBudget  {'id': '#(plannedBudgetWithExpenseClassesId)', 'budgetStatus': 'Planned', 'allocated': 10000, 'fundId': '#(fundWithCurrBudgetId)', "fiscalYearId":"#(globalPlannedFiscalYearId)", 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active'}]}

  Scenario: Check, that current budget has expense classes and created for current fiscal year
    Given path 'finance/budgets', currBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalElecExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId)'
    And match $.fiscalYearId == '#(globalFiscalYearId)'

  Scenario: Check, that planned budget has expense classes which were provided in creation time
    Given path 'finance/budgets', plannedBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalPrnExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'