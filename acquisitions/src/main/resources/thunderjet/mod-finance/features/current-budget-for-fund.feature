Feature: Test API to get current budget by fund

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundId = callonce uuid1
    * def fundIdWithoutBudget = callonce uuid2
    * def budgetId = callonce uuid3

  Scenario: Create finances
    * call createFund { 'id': '#(fundId)', 'code': '#(fundId)'}
    * call createFund { 'id': '#(fundIdWithoutBudget)', 'code': '#(fundIdWithoutBudget)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

  Scenario: Call API to get current budget for fund
    Given path 'finance/funds', fundId , 'budget'
    When method GET
    Then status 200
    And match response.fundId == fundId

  Scenario: Call API to get current Active budget for fund
    Given path 'finance/funds', fundId , 'budget'
    And param status = "Active"
    When method GET
    Then status 200
    And match response.fundId == fundId

  Scenario: Call API to get current budget for fund with status that doesn't exist
    Given path 'finance/funds', fundId , 'budget'
    And param status = "Planned"
    When method GET
    Then status 404
    And match response.errors[0].code == "currentBudgetNotFound"

  Scenario: Call API to get error if budget doesn't exist for fund
    Given path 'finance/funds', fundIdWithoutBudget , 'budget'
    When method GET
    Then status 404
    And match response.errors[0].code == "currentBudgetNotFound"


