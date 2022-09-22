Feature: Create planned budget with expense classes when there is current budget

  Background:
    * url baseUrl
    # uncomment below line for development
   # * callonce dev {tenant: 'testfinance35'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    #Budget without expense classes and with current budget when there is current budget
    * def fundWithCurrBudgetId2 = "d573fa6e-55cb-4093-8405-3a64368f33eb"
    * def currBudgetWithoutExpenseClassesId2 = "d573fa6e-55cb-4093-8405-3a64368f34eb"
    * def plannedBudgetWithoutExpenseClassesId2 = "d573fa6e-55cb-4093-8405-3a64368f35eb"


  #Create planned budget without expense classes when there is current budget
  Scenario: Create planned budget without expense classes when there is current budget
    * call createFund { 'id': '#(fundWithCurrBudgetId2)'}
    * call createBudget { 'id': '#(currBudgetWithoutExpenseClassesId2)', 'allocated': 10000, 'fundId': '#(fundWithCurrBudgetId2)'}
    * call createBudget  {'id': '#(plannedBudgetWithoutExpenseClassesId2)', 'budgetStatus': 'Planned', 'allocated': 10000, 'fundId': '#(fundWithCurrBudgetId2)', "fiscalYearId":"#(globalPlannedFiscalYearId)"}

  Scenario: Check, that current budget doesn't have expense classes and created for current fiscal year
    Given path 'finance/budgets', currBudgetWithoutExpenseClassesId2
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[0]'
    And match $.fundId == '#(fundWithCurrBudgetId2)'
    And match $.fiscalYearId == '#(globalFiscalYearId)'

  Scenario: Check, that planned budget doesn't have expense classes and created for planned current fiscal year
    Given path 'finance/budgets', plannedBudgetWithoutExpenseClassesId2
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[0]'
    And match $.fundId == '#(fundWithCurrBudgetId2)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'



