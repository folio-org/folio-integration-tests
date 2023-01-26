# For https://issues.folio.org/browse/MODFIN-264
@parallel=false
Feature: Budget and fund optimistic locking

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def groupId1 = callonce uuid3
    * def groupId2 = callonce uuid4


  Scenario: Create fund and budget
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active' }


  Scenario Outline: Create groups
    * def groupId = <groupId>
    Given path '/finance/groups'
    And request
    """
    {
      "id": "#(groupId)",
      "code": "#(groupId)",
      "name": "#(groupId)",
      "status": "Active"
    }
    """
    When method POST
    Then status 201

    Examples:
      | groupId  |
      | groupId1 |
      | groupId2 |


  Scenario: Optimistic locking test for budget expense classes
    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    * def initialBudget = $

    * copy budget1 = initialBudget
    * set budget1.statusExpenseClasses = [ { 'expenseClassId': '#(globalElecExpenseClassId)' } ]

    * copy budget2 = initialBudget
    * set budget2.statusExpenseClasses = [ { 'expenseClassId': '#(globalPrnExpenseClassId)' } ]

    Given path '/finance/budgets', budgetId
    And request budget1
    When method PUT
    Then status 204

    Given path '/finance/budgets', budgetId
    And request budget2
    When method PUT
    Then status 409

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.statusExpenseClasses == '#[1]'
    And match $.statusExpenseClasses[0].expenseClassId == '#(globalElecExpenseClassId)'


  Scenario: Optimistic locking test for fund groups
    Given path '/finance/funds', fundId
    When method GET
    Then status 200
    * def initialCompositeFund = $

    * copy compositeFund1 = initialCompositeFund
    * set compositeFund1.groupIds = ['#(groupId1)']

    * copy compositeFund2 = initialCompositeFund
    * set compositeFund2.groupIds = ['#(groupId2)']

    Given path '/finance/funds', fundId
    And request compositeFund1
    When method PUT
    Then status 204

    Given path '/finance/funds', fundId
    And request compositeFund2
    When method PUT
    Then status 409

    Given path '/finance/funds', fundId
    When method GET
    Then status 200
    And match $.groupIds == '#[1]'
    And match $.groupIds[0] == '#(groupId1)'


  Scenario: Test rollback with a budget update using a bad expense class id
    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    * def initialBudget = $

    * copy budget = initialBudget
    * set budget.name = 'other name'
    * set budget.statusExpenseClasses = [ { 'expenseClassId': '00000000-0000-1000-8000-000000000000' } ]

    Given path '/finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 400

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.name == initialBudget.name
    And match $.statusExpenseClasses == initialBudget.statusExpenseClasses
    And assert response._version > initialBudget._version


  Scenario: Test rollback with a fund update using a bad group id
    Given path '/finance/funds', fundId
    When method GET
    Then status 200
    * def initialCompositeFund = $

    * copy compositeFund = initialCompositeFund
    * set compositeFund.fund.code = 'other_code'
    * set compositeFund.groupIds = ['00000000-0000-1000-8000-000000000000']

    Given path '/finance/funds', fundId
    And request compositeFund
    When method PUT
    Then status 422

    Given path '/finance/funds', fundId
    When method GET
    Then status 200
    And match $.fund.code == initialCompositeFund.fund.code
    And match $.groupIds == initialCompositeFund.groupIds
    And assert response.fund._version > initialCompositeFund.fund._version
