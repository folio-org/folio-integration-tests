Feature: Create budget
  # parameters: id, fundId, fiscalYearId, expenseClassIds?
  Background:
    * url baseUrl

  Scenario: Create budget
    * def expenseClassIds = karate.get('expenseClassIds', [])
    * def statusExpenseClasses = karate.map(expenseClassIds, function(expenseClassId) { return { expenseClassId: expenseClassId, status: 'Active' } })
    Given path 'finance/budgets'
    And request { id: '#(id)', name: '#(id)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId)', budgetStatus: 'Active', allocated: 1000, statusExpenseClasses: '#(statusExpenseClasses)' }
    When method POST
    Then status 201
