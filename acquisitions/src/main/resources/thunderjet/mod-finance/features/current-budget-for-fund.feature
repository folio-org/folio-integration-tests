Feature: Test API to get current budget by fund

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Test API to get current budget by fund
    * def fundId = call uuid
    * def fundIdWithoutBudget = call uuid
    * def budgetId = call uuid

    # 1. Create finances
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)' }
    * def v = call createFund { id: '#(fundIdWithoutBudget)', code: '#(fundIdWithoutBudget)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

    # 2. Call API to get current budget for fund
    Given path 'finance/funds', fundId , 'budget'
    When method GET
    Then status 200
    And match response.fundId == fundId

    # 3. Call API to get current Active budget for fund
    Given path 'finance/funds', fundId , 'budget'
    And param status = "Active"
    When method GET
    Then status 200
    And match response.fundId == fundId

    # 4. Call API to get current budget for fund with status that doesn't exist
    Given path 'finance/funds', fundId , 'budget'
    And param status = "Planned"
    When method GET
    Then status 404
    And match response.errors[0].code == "currentBudgetNotFound"

    # 5. Call API to get error if budget doesn't exist for fund
    Given path 'finance/funds', fundIdWithoutBudget , 'budget'
    When method GET
    Then status 404
    And match response.errors[0].code == "currentBudgetNotFound"
