Feature: Karate tests for FY finance bulk get/update functionality
  # for FAT-17236

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * callonce variables
    * def fundId1 = callonce uuid1
    * def budgetId1 = callonce uuid2

    ### Before All: Prepare finance data ###
    * configure headers = headersAdmin
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }
    * configure headers = headersUser

  Scenario: Verify finance data operations
    # Verify get finance data
    Given path 'finance/finance-data'
    And headers headersUser
    And param query = '(fiscalYearId==7a4c4d30-3b63-4102-8e2d-3ee5792d7d02)'
    When method get
    Then status 200
    And match response.totalRecords == 21

    # Verify get finance data with no records
    Given path 'finance/finance-data'
    And headers headersUser
    And param query = '(fiscalYearId==9b1d00d1-1f3d-4f1c-8e4b-0f1e3b7b1b1b)'
    When method get
    Then status 200
    And match response.totalRecords == 0

    # Verify get finance data details
    Given path 'finance/finance-data'
    And headers headersUser
    And param query = '(fiscalYearId==7a4c4d30-3b63-4102-8e2d-3ee5792d7d02)'
    When method get
    Then status 200
    And match response.fyFinanceData[0].fiscalYearId == '7a4c4d30-3b63-4102-8e2d-3ee5792d7d02'
    And match response.fyFinanceData[0].fundId != null
    And match response.fyFinanceData[0].fundCode != null
    And match response.fyFinanceData[0].fundName != null
    And match response.fyFinanceData[0].fundDescription != null
    And match response.fyFinanceData[0].fundStatus != null
    And match response.fyFinanceData[0].fundAcqUnitIds != null
    And match response.fyFinanceData[0].budgetId != null
    And match response.fyFinanceData[0].budgetName != null
    And match response.fyFinanceData[0].budgetStatus != null
    And match response.fyFinanceData[0].budgetInitialAllocation != null
    And match response.fyFinanceData[0].budgetAllowableExpenditure != null
    And match response.fyFinanceData[0].budgetAllowableEncumbrance != null
    And match response.fyFinanceData[0].budgetAcqUnitIds != null

    # Verify get finance data with fiscal year and acq unit ids
    * def acqUnitId = call uuid
    * def fiscalYearId = call uuid
    Given path 'finance/finance-data'
    And headers headersUser
    When method get
    Then status 200
    And match response.fyFinanceData[0].fiscalYearId == fiscalYearId
    And match response.fyFinanceData[0].fundAcqUnitIds[0] == acqUnitId
    And match response.fyFinanceData[0].budgetAcqUnitIds[0] == acqUnitId
