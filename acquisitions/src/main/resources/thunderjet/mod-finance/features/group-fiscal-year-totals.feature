Feature: Group fiscal year totals

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_finance'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def fundId3 = callonce uuid3

    * def budgetId1 = callonce uuid4
    * def budgetId2 = callonce uuid5
    * def budgetId3 = callonce uuid6

    * def group1 = callonce uuid7
    * def group2 = callonce uuid8

    * def nonExistingFiscalYear = callonce uuid9

  Scenario Outline: prepare finances for group with <groupId>
    * def groupId = <groupId>

    Given path 'finance/groups'
    And request
    """
    {
      "id": "#(groupId)",
      "status": "Active",
      "name": "#(groupId)",
      "code": "#(groupId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | groupId |
      | group1  |
      | group2  |

  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def groupId = <groupId>
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': #(globalLedgerId) }

    Given path 'finance-storage/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "initialAllocation": 0.0,
      "allocationTo": 0.0,
      "allocationFrom": 0.0,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPayment>,
      "expenditures": <expenditures>,
      "netTransfers": 0.0,
      "allowableEncumbrance": 150.0,
      "allowableExpenditure": 150.0
    }
    """
    When method POST
    Then status 201

    Given path 'finance-storage/group-fund-fiscal-years'
    And request
    """
    {
      "budgetId": "#(budgetId)",
      "groupId": '#(groupId)',
      "fiscalYearId": "#(globalFiscalYearId)",
      "fundId": "#(fundId)"
    }
    """
    When method POST
    Then status 201

    Given path 'finance-storage/transactions'
    And request
    """
    {
        "amount": <initialAllocation>,
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
      | fundId  | budgetId  | groupId | initialAllocation | encumbered | awaitingPayment | expenditures |
      | fundId1 | budgetId1 | group1  | 10000             | 231.34     | 763.23          | 242          |
      | fundId2 | budgetId2 | group2  | 24500             | 25000      | 0               | 0            |
      | fundId3 | budgetId3 | group1  | 6601.91           | 0          | 2345            | 500          |

  Scenario: Get groups by fiscalYearId before allocate money
    * configure headers = headersUser
    Given path 'finance/group-fiscal-year-summaries'
    And param query = 'fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * def groupFySummary1 = karate.jsonPath(response, '$.groupFiscalYearSummaries[*][?(@.groupId == "' + group1 + '")]')[0]
    And match groupFySummary1.initialAllocation == 16601.91
    #Sum allocationTo transactions except initial allocation
    And match groupFySummary1.allocationTo == 0.0
    #Sum allocationFrom transactions
    And match groupFySummary1.allocationFrom == 0.0
    #allocated = initialAllocation.add(allocationTo).subtract(allocationFrom)
    And match groupFySummary1.allocated == 16601.91
    And match groupFySummary1.encumbered == 231.34
    And match groupFySummary1.awaitingPayment == 3108.23
    And match groupFySummary1.expenditures == 742
    # unavailable = encumbered.add(awaitingPayment).add(expended)
    And match groupFySummary1.unavailable == 4081.57
    And match groupFySummary1.netTransfers ==  0.0
    #totalFunding = allocated.add(netTransfers)
    And match groupFySummary1.totalFunding == 16601.91
    #available = totalFunding.subtract(unavailable).max(BigDecimal.ZERO)
    And match groupFySummary1.available == 12520.34
    #cashBalance = totalFunding.subtract(expended)
    And match groupFySummary1.cashBalance == 15859.91
    #overEncumbered = encumbered.subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
    And match groupFySummary1.overEncumbrance == 0.0
    #overExpended = expended.add(awaitingPayment).subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
    And match groupFySummary1.overExpended == 0.0

  Scenario Outline: Create allocation from <fromFundId> to <toFundId>
    * def toFundId = <toFundId>
    * def fromFundId = <fromFundId>
    Given path 'finance/allocations'
    And request
    """
    {
        "amount": <amount>,
        "currency": "USD",
        "description": "To allocation",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId" : "#(fromFundId)",
        "toFundId": "#(toFundId)",
        "transactionType": "Allocation"
    }
    """
    When method POST
    Then status 201
    Examples:
      |fromFundId| toFundId | amount|
      |fundId1   | fundId2  | 420   |
      |fundId1   | fundId2  | 534   |
      |fundId3   | fundId1  | 31    |
      |fundId3   | fundId1  | 32    |

  Scenario Outline: Transfer money from <fromFundId> to <toFundId>
    * def toFundId = <toFundId>
    * def fromFundId = <fromFundId>
    Given path 'finance/transfers'
    And request
    """
    {
      "amount": <amount>,
      "currency": "USD",
      "fromFundId": "#(fromFundId)",
      "toFundId": "#(toFundId)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201
    Examples:
      |fromFundId| toFundId | amount|
      |fundId1   | fundId2  | 15    |
      |fundId1   | fundId2  | 16    |
      |fundId2   | fundId1  | 10    |
      |fundId3   | fundId1  | 33    |
      |fundId3   | fundId1  | 34    |

  Scenario Outline: Allocate only with <fromFundId>
    * def fromFundId = <fromFundId>
    Given path 'finance/allocations'
    And request
    """
    {
      "amount": <amount>,
      "currency": "USD",
      "fromFundId": "#(fromFundId)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Allocation",
      "source": "User"
    }
    """
    When method POST
    Then status 201
    Examples:
      |fromFundId| amount|
      |fundId1   | 25    |
      |fundId2   | 20    |

   Scenario: Get groups by fiscalYearId after allocate money
     Given path 'finance/group-fiscal-year-summaries'
     And param query = 'fiscalYearId==' + globalFiscalYearId
     When method GET
     Then status 200
     * def groupFySummary1 = karate.jsonPath(response, '$.groupFiscalYearSummaries[*][?(@.groupId == "' + group1 + '")]')[0]
     * def groupFySummary2 = karate.jsonPath(response, '$.groupFiscalYearSummaries[*][?(@.groupId == "' + group2 + '")]')[0]
     And match groupFySummary1.initialAllocation == 16601.91
    #Sum allocationTo transactions except initial allocation
     And match groupFySummary1.allocationTo == 0.0
    #Sum allocationFrom transactions
     And match groupFySummary1.allocationFrom == 979.0
    #allocated = initialAllocation.add(allocationTo).subtract(allocationFrom)
     And match groupFySummary1.allocated == 15622.91
     And match groupFySummary1.encumbered == 231.34
     And match groupFySummary1.awaitingPayment == 3108.23
     And match groupFySummary1.expenditures == 742
    # unavailable = encumbered.add(awaitingPayment).add(expended)
     And match groupFySummary1.unavailable == 4081.57
     And match groupFySummary1.netTransfers ==  -21.0
    #totalFunding = allocated.add(netTransfers)
     And match groupFySummary1.totalFunding == 15601.91
    #available = totalFunding.subtract(unavailable).max(BigDecimal.ZERO)
     And match groupFySummary1.available == 11520.34
    #cashBalance = totalFunding.subtract(expended)
     And match groupFySummary1.cashBalance == 14859.91
    #overEncumbered = encumbered.subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
     And match groupFySummary1.overEncumbrance == 0.0
    #overExpended = expended.add(awaitingPayment).subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
     And match groupFySummary1.overExpended == 0.0

     And match groupFySummary2.initialAllocation == 24500.0
     And match groupFySummary2.allocationTo == 954.0
     And match groupFySummary2.allocationFrom == 20.0
     And match groupFySummary2.allocated == 25434.0
     And match groupFySummary2.encumbered == 25000.0
     And match groupFySummary2.awaitingPayment == 0.0
     And match groupFySummary2.expenditures == 0.0
     And match groupFySummary2.unavailable == 25000.0
     And match groupFySummary2.netTransfers == 21.0
     And match groupFySummary2.totalFunding == 25455.0
     And match groupFySummary2.available == 455
     And match groupFySummary2.cashBalance == 25455.0
     And match groupFySummary2.overEncumbrance == 0.0
     And match groupFySummary2.overExpended == 0.0
