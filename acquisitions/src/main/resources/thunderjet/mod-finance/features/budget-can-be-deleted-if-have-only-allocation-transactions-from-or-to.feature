@parallel=false
Feature: Budget can be deleted if have only allocation transactions From or To

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def ledgerId = callonce uuid1
    * def fundIdWithFromAllocation = callonce uuid1
    * def fundIdWithToAllocation = callonce uuid2

    * def budgetIdFromAllocation = callonce uuid3
    * def budgetIdWithToAllocation = callonce uuid4

    * def fromAllocationId = callonce uuid5
    * def toAllocationId = callonce uuid6

  Scenario: Create ledger  
    * call createLedger { 'id': '#(ledgerId)'}

  Scenario Outline: Create funds and budget <budgetId> for <fundId>
    * def fundId = <fundId>
    * def ledgerId = <ledgerId>
    * def budgetId = <budgetId>
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}
  Examples:
    | fundId                      | budgetId                  | ledgerId |
    | fundIdWithFromAllocation    | budgetIdFromAllocation    | ledgerId |
    | fundIdWithToAllocation      | budgetIdWithToAllocation  | ledgerId |


  Scenario Outline: Create allocation <allocationId> for <fundId>
    * def fundId = <fundId>
    * def allocationId = <allocationId>
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(allocationId)",
        "amount": 25,
        "currency": "USD",
        "description": "To allocation",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "toFundId": "#(fundId)",
        "transactionType": "Allocation"
      }]
    }
    """
    When method POST
    Then status 204
    Examples:
      | fundId                      | allocationId     |
      | fundIdWithFromAllocation    | fromAllocationId |
      | fundIdWithToAllocation      | toAllocationId   |

  Scenario Outline: Verify that budget <budgetId> only with allocation transaction can be deleted and money were not spent
    * def budgetId = <budgetId>
    Given path 'finance/budgets', budgetId
    When method DELETE
    Then status 204
  Examples:
    | budgetId                  |
    | budgetIdFromAllocation    |
    | budgetIdWithToAllocation  |

  Scenario Outline: Verify that budget <budgetId> was deleted
    * def budgetId = <budgetId>
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 404
    Examples:
      | budgetId                  |
      | budgetIdFromAllocation    |
      | budgetIdWithToAllocation  |

  Scenario Outline: Verify that allocation transactions <allocationId> was deleted
    * def allocationId = <allocationId>
    Given path 'finance/transactions', allocationId
    When method GET
    Then status 404
    Examples:
      | allocationId     |
      | fromAllocationId |
      | toAllocationId   |
