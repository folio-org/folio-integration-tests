Feature: Budget can not be deleted if have other than allocation transactions

  Background:
    * url baseUrl
    # uncomment below line for development
    * callonce dev {tenant: 'test_finance3'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def ledgerId = callonce uuid1
    * def fundIdWithFromAllocation = callonce uuid1
    * def fundIdWithToAllocation = callonce uuid2

    * def budgetIdFromAllocation = callonce uuid3
    * def budgetIdWithToAllocation = callonce uuid4

    * def fromAllocationId = callonce uuid5
    * def toAllocationId = callonce uuid6

#    * def ledgerId = "65eab5a6-017f-468d-8391-0c90e3dc2ca0"
#    * def fundIdWithFromAllocation = "65eab5a6-016f-468d-8361-0c90e3dc3ca1"
#    * def fundIdWithToAllocation = "65eab5a6-016f-468d-8362-0c90e3dc4ca2"
#
#    * def budgetIdFromAllocation = "55eab5a4-016f-468d-8397-0c90e3dc5ca1"
#    * def budgetIdWithToAllocation = "35eab5a4-016f-468d-8397-0c90e3dc5ca2"
#
#    * def fromAllocationId = "65eab5a6-016f-468c-8395-0c90e3dc6ca6"
#    * def toAllocationId = "65eab5a6-016f-468c-8396-0c90e3dc8ca8"

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
    Given path 'finance/allocations'
    And request
    """
    {
        "id": "#(allocationId)",
        "amount": 25,
        "currency": "USD",
        "description": "To allocation",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "toFundId": "#(fundId)",
        "transactionType": "Allocation"
    }
    """
    When method POST
    Then status 201
    Examples:
      | fundId                      | allocationId     |
      | fundIdWithFromAllocation    | fromAllocationId |
      | fundIdWithToAllocation      | toAllocationId   |

  Scenario: Transfer money from first budget to second
    Given path 'finance-storage/transactions'
    And request
    """
    {
      "amount": "25",
      "currency": "USD",
      "fromFundId": "#(fundIdWithFromAllocation)",
      "toFundId": "#(fundIdWithToAllocation)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201

  Scenario Outline: Verify that budget <budgetId> only with allocation transaction can be deleted and money were not spent
    * def budgetId = <budgetId>
    Given path 'finance/budgets', budgetId
    When method DELETE
    Then status 400
    And match response.errors[0].code == "transactionIsPresentBudgetDeleteError"
  Examples:
    | budgetId                  |
    | budgetIdFromAllocation    |
    | budgetIdWithToAllocation  |