@ignore
Feature: Check budget after cancelling order
  # parameters: fundId

  Background: checkBudgetAfterCancellingOrder
    * url baseUrl

  Scenario: Check budget after cancelling order
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 1000
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0