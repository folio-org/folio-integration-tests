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
    #Budget with expense classes and with current budget when there is current budget
    * def fundWithCurrBudgetId1 = "d573fa6e-55cb-4093-8405-3a64368f10eb"
    * def currBudgetWithExpenseClassesId = "d573fa6e-55cb-4093-8405-3a64368f11eb"
    * def plannedBudgetWithExpenseClassesId = "d573fa6e-55cb-4093-8405-3a64368f12eb"

 #Budget with expense classes and with current budget when there is current budget
  Scenario: Create planned budget with expense classes when there is current budget
    * call createFund { 'id': '#(fundWithCurrBudgetId1)'}
    * call createBudget { 'id': '#(currBudgetWithExpenseClassesId)', 'allocated': 10000, 'fundId': '#(fundWithCurrBudgetId1)', 'statusExpenseClasses': [{'expenseClassId': '1bcc3247-99bf-4dca-9b0f-7bc51a2998c2','status': 'Active'}]}
    * call createBudget  {'id': '#(plannedBudgetWithExpenseClassesId)', 'budgetStatus': 'Planned', 'allocated': 10000, 'fundId': '#(fundWithCurrBudgetId1)', "fiscalYearId":"#(globalPlannedFiscalYearId)"}

  Scenario: Check, that current budget has expense classes and created for current fiscal year
    Given path 'finance/budgets', currBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalElecExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId1)'
    And match $.fiscalYearId == '#(globalFiscalYearId)'

  Scenario: Check, that planned budget has expense classes and created for planned current fiscal year
    Given path 'finance/budgets', plannedBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalElecExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId1)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'



