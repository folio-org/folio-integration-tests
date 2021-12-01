Feature: Create planned budget without expense classes when there is no current budget

  Background:
    * url baseUrl
    # uncomment below line for development
   # * callonce dev {tenant: 'test_finance35'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    #Budget without expense classes and current budget when there is no current budget
    * def fundWithoutCurrBudgetId = "d573fa6e-65cb-4093-8405-3a64368f61eb"
    * def plannedBudgetWithoutExpenseClassesId2 = "d573fa6e-65cb-4093-8405-3a64368f62eb"


  #Create planned budget without expense classes when there is no current budget
  Scenario: Create planned budget without expense classes when there is no current budget
    * call createFund { 'id': '#(fundWithoutCurrBudgetId)'}
    * call createBudget  {'id': '#(plannedBudgetWithoutExpenseClassesId2)', 'budgetStatus': 'Planned', 'allocated': 10000, 'fundId': '#(fundWithoutCurrBudgetId)', "fiscalYearId":"#(globalPlannedFiscalYearId)"}

  Scenario: Check, that planned budget doesn't have expense classes and created for planned current fiscal year. If current budget absent
    Given path 'finance/budgets', plannedBudgetWithoutExpenseClassesId2
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[0]'
    And match $.fundId == '#(fundWithoutCurrBudgetId)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'



