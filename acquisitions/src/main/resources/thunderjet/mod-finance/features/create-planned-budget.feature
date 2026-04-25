Feature: Create a planned budget

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Create a planned budget without expense classes when there is a current budget
    * def fundWithCurrBudgetId2 = call uuid
    * def currBudgetWithoutExpenseClassesId2 = call uuid
    * def plannedBudgetWithoutExpenseClassesId2 = call uuid

    # 1. Create fund, current budget and planned budget
    * def v = call createFund { id: '#(fundWithCurrBudgetId2)' }
    * def v = call createBudget { id: '#(currBudgetWithoutExpenseClassesId2)', allocated: 10000, fundId: '#(fundWithCurrBudgetId2)' }
    * def v = call createBudget  { id: '#(plannedBudgetWithoutExpenseClassesId2)', budgetStatus: 'Planned', allocated: 10000, fundId: '#(fundWithCurrBudgetId2)', fiscalYearId: '#(globalPlannedFiscalYearId)' }

    # 2. Check that current budget doesn't have expense classes and created for current fiscal year
    Given path 'finance/budgets', currBudgetWithoutExpenseClassesId2
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[0]'
    And match $.fundId == '#(fundWithCurrBudgetId2)'
    And match $.fiscalYearId == '#(globalFiscalYearId)'

    # 3. Check that planned budget doesn't have expense classes and created for planned current fiscal year
    Given path 'finance/budgets', plannedBudgetWithoutExpenseClassesId2
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[0]'
    And match $.fundId == '#(fundWithCurrBudgetId2)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'


  Scenario: Create a planned budget using expense classes from the current budget
    * def fundWithCurrBudgetId = call uuid
    * def currBudgetWithExpenseClassesId = call uuid
    * def plannedBudgetWithExpenseClassesId = call uuid

    # 1. Create fund, current budget and planned budget
    * def v = call createFund { id: '#(fundWithCurrBudgetId)' }
    * def v = call createBudget { id: '#(currBudgetWithExpenseClassesId)', allocated: 10000, fundId: '#(fundWithCurrBudgetId)', statusExpenseClasses: [{expenseClassId: '#(globalElecExpenseClassId)', status: 'Active'}] }
    * def v = call createBudget  { id: '#(plannedBudgetWithExpenseClassesId)', budgetStatus: 'Planned', allocated: 10000, fundId: '#(fundWithCurrBudgetId)', fiscalYearId: '#(globalPlannedFiscalYearId)' }

    # 2. Check that current budget has expense classes and created for current fiscal year
    Given path 'finance/budgets', currBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalElecExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId)'
    And match $.fiscalYearId == '#(globalFiscalYearId)'

    # 3. Check that planned budget has expense classes and created for planned current fiscal year
    Given path 'finance/budgets', plannedBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalElecExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'


  Scenario: Create a planned budget with different expense classes than the ones from the current budget
    * def fundWithCurrBudgetId = call uuid
    * def currBudgetWithExpenseClassesId = call uuid
    * def plannedBudgetWithExpenseClassesId = call uuid

    # 1. Create fund, current budget and planned budget
    * def v = call createFund { id: '#(fundWithCurrBudgetId)' }
    * def v = call createBudget { id: '#(currBudgetWithExpenseClassesId)', allocated: 10000, fundId: '#(fundWithCurrBudgetId)', statusExpenseClasses: [{expenseClassId: '#(globalElecExpenseClassId)', status: 'Active'}] }
    * def v = call createBudget  { id: '#(plannedBudgetWithExpenseClassesId)', budgetStatus: 'Planned', allocated: 10000, fundId: '#(fundWithCurrBudgetId)', fiscalYearId: '#(globalPlannedFiscalYearId)', statusExpenseClasses: [{expenseClassId: '#(globalPrnExpenseClassId)', status: 'Active'}] }

    # 2. Check that current budget has expense classes and created for current fiscal year
    Given path 'finance/budgets', currBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalElecExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId)'
    And match $.fiscalYearId == '#(globalFiscalYearId)'

    # 3. Check that planned budget has expense classes which were provided in creation time
    Given path 'finance/budgets', plannedBudgetWithExpenseClassesId
    When method GET
    Then status 200
    * def statusExpenseClass = $.statusExpenseClasses[0]
    And match $.statusExpenseClasses == '#[1]'
    And match statusExpenseClass.expenseClassId == '#(globalPrnExpenseClassId)'
    And match $.fundId == '#(fundWithCurrBudgetId)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'


  Scenario: Create a planned budget without expense classes when there is no current budget
    * def fundWithoutCurrBudgetId = call uuid
    * def plannedBudgetWithoutExpenseClassesId2 = call uuid

    # 1. Create fund and planned budget
    * def v = call createFund { id: '#(fundWithoutCurrBudgetId)' }
    * def v = call createBudget  { id: '#(plannedBudgetWithoutExpenseClassesId2)', budgetStatus: 'Planned', allocated: 10000, fundId: '#(fundWithoutCurrBudgetId)', fiscalYearId: '#(globalPlannedFiscalYearId)' }

    # 2. Check that planned budget was created for the planned fiscal year but doesn't have expense classes
    Given path 'finance/budgets', plannedBudgetWithoutExpenseClassesId2
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[0]'
    And match $.fundId == '#(fundWithoutCurrBudgetId)'
    And match $.fiscalYearId == '#(globalPlannedFiscalYearId)'
