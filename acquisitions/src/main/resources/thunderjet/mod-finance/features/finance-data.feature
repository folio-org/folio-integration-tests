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
    * def fundId2 = callonce uuid2
    * def fundId3 = callonce uuid10
    * def budgetId1 = callonce uuid3
    * def budgetId2 = callonce uuid4
    * def budgetId3 = callonce uuid11
    * def fiscalYearId1 = callonce uuid5
    * def fiscalYearId2 = callonce uuid6
    * def fiscalYearId3 = callonce uuid12
    * def ledgerId1 = callonce uuid7
    * def ledgerId2 = callonce uuid8
    * def ledgerId3 = callonce uuid13
    * def acqUnitId = callonce uuid9

    * def userId = "00000000-1111-5555-9999-999999999992"

    * configure headers = headersAdmin

    ### Before All ###

    # Create Acq Unit and assign user (each scenario)
    * def v = callonce createAcqUnit { id: '#(acqUnitId)', name: 'Acq Unit 1', isDeleted: false, protectCreate: true, protectRead: true, protectUpdate: true, protectDelete: true }
    * def v = call assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }

    # Prepare finance data
    * table fiscalYears
      | id            | code      | periodStart  | periodEnd    | series   |
      | fiscalYearId1 | 'FY2044' | '2044-01-01' | '2044-12-31' | 'TESTFY' |
      | fiscalYearId2 | 'FY2045' | '2045-01-01' | '2045-12-31' | 'TESTFY' |
      | fiscalYearId3 | 'FY2046' | '2046-01-01' | '2046-12-31' | 'TESTFY' |
    * def v = callonce createFiscalYear fiscalYears

    * table ledgers
      | id        | code   | name       | fiscalYearOneId |
      | ledgerId1 | 'LDG1' | 'Ledger 1' | fiscalYearId1   |
      | ledgerId2 | 'LDG2' | 'Ledger 2' | fiscalYearId1   |
      | ledgerId3 | 'LDG2' | 'Ledger 2' | fiscalYearId3   |
    * def v = callonce createLedger ledgers

    * table funds
      | id      | code   | ledgerId  | acqUnitIds       |
      | fundId1 | 'FND1' | ledgerId1 | []               |
      | fundId2 | 'FND2' | ledgerId2 | ['#(acqUnitId)'] |
      | fundId3 | 'FND3' | ledgerId2 | [] |
    * def v = callonce createFund funds

    * table budgets
      | id        | fundId  | fiscalYearId  | allocated |
      | budgetId1 | fundId1 | fiscalYearId1 | 1000      |
      | budgetId2 | fundId2 | fiscalYearId1 | 2000      |
      | budgetId3 | fundId3 | fiscalYearId3 | 2000      |
    * def v = callonce createBudget budgets

    * configure headers = headersUser

  @Positive
  Scenario: Verify GET finance data operations
    # 1. Verify get finance data with fiscal year id. fiscal year id1 has 2 funds and fiscal year id2 has 0 funds
    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId1))'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId2))'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 4. Verify get finance data with two fiscal year ids that do not exist
    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId1) and fiscalYearId==#(fiscalYearId2))'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 2. Verify get finance data details
    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==7a4c4d30-3b63-4102-8e2d-3ee5792d7d02)'
    When method GET
    Then status 200
    And match $.fyFinanceData[*].fiscalYearId contains '#(fiscalYearId1)'
    And match $.fyFinanceData[*].fundId contains '#(fundId1)'
    And match $.fyFinanceData[*].fundCode contains 'FND1'
    And match $.fyFinanceData[*].fundName contains 'Fund 1'
    And match $.fyFinanceData[0].fundDescription != null
    And match $.fyFinanceData[*].fundStatus contains 'Active'
    And match $.fyFinanceData[*].fundAcqUnitIds contains '#(acqUnitId)'
    And match $.fyFinanceData[*].budgetId contains '#(budgetId1)'
    And match $.fyFinanceData[*].budgetName contains 'Budget 1'
    And match $.fyFinanceData[*].budgetStatus contains 'Active'
    And match $.fyFinanceData[*].budgetInitialAllocation contains 1000
    And match $.fyFinanceData[*].budgetAllowableExpenditure contains 100
    And match $.fyFinanceData[*].budgetAllowableEncumbrance contains 100
    And match $.fyFinanceData[*].budgetAcqUnitIds != null

    # 3. Verify get finance data with fiscal year id and acq unit id restrictions
    * configure headers = headersAdmin
    * def v = call deleteUserFromAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    # fiscal year id2 should be skipped after acq unit restriction
    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId1))'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.fyFinanceData[0].fiscalYearId == fiscalYearId1
    And match $.fyFinanceData[0].fundId == fundId1
    And match $.fyFinanceData[0].fundAcqUnitIds[0] == acqUnitId
    And match $.fyFinanceData[0].budgetId == budgetId1

  @Positive
  Scenario: Verify PUT finance data operations with COMMIT and only fund and budget fields
    # 1. Update finance data
    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId1))'
    When method GET
    Then status 200
    * def financeDataCollection = response

    * def updatedFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "UPDATED",
            "fundName": "Fund 1 Updated",
            "fundDescription": "UPDATED subdivided by geographic regions, to match individual selectors",
            "fundStatus": "Inactive",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag1"]
            },
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1 Updated",
            "budgetStatus": "Inactive",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": []
          },
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId2)",
            "fundCode": "FND2",
            "fundName": "Fund 2",
            "fundDescription": "UPDATED WAITING FOR ADMIN APPROVAL; use for Canada once CANLATHIST is inactivated",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag2"]
            },
            "budgetId": "#(budgetId2)",
            "budgetName": "Budget 2",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 2000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 250.0,
            "budgetAllowableEncumbrance": 260.0,
            "budgetAcqUnitIds": []
          }
        ],
        "updateType": "Commit",
        "totalRecords": 2
      }
      """
    Given path 'finance/finance-data'
    And request updatedFinanceData
    When method PUT
    Then status 204

    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId1) and fundId==#(fundId1))'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundDescription == 'UPDATED subdivided by geographic regions, to match individual selectors'
    And match $.fyFinanceData[0].fundTags.tagList contains 'updatedTag1'
    And match $.fyFinanceData[0].budgetStatus == 'Inactive'
    And match $.fyFinanceData[0].budgetAllowableExpenditure == 150.0
    And match $.fyFinanceData[0].budgetAllowableEncumbrance == 160.0
    # the fields shouldn't be updated
    And match $.fyFinanceData[0].fundCode != 'UPDATED'
    And match $.fyFinanceData[0].fundName != 'Fund 1 Updated'
    And match $.fyFinanceData[0].fundStatus != 'Inactive'
    And match $.fyFinanceData[0].fundAcqUnitIds == []
    And match $.fyFinanceData[0].budgetName == 'Budget 1 Updated'

    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==#(fiscalYearId1) and fundId==#(fundId2))'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundDescription == 'UPDATED WAITING FOR ADMIN APPROVAL; use for Canada once CANLATHIST is inactivated'
    And match $.fyFinanceData[0].fundTags.tagList contains 'updatedTag2'
    And match $.fyFinanceData[0].budgetStatus == 'Active'
    And match $.fyFinanceData[0].budgetAllowableExpenditure == 250.0
    And match $.fyFinanceData[0].budgetAllowableEncumbrance == 260.0


  @Positive
  Scenario: Verify PUT finance data with changing allocation
    * def updatedFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "FND1",
            "fundName": "Fund 1",
            "fundDescription": "UPDATED subdivided by geographic regions, to match individual selectors",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag1"]
            },
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 100,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": []
          },
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId2)",
            "fundCode": "FND2",
            "fundName": "Fund 2",
            "fundDescription": "UPDATED WAITING FOR ADMIN APPROVAL; use for Canada once CANLATHIST is inactivated",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag2"]
            },
            "budgetId": "#(budgetId2)",
            "budgetName": "Budget 2",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 2000,
            "budgetAllocationChange": 100,
            "budgetAllowableExpenditure": 250.0,
            "budgetAllowableEncumbrance": 260.0,
            "budgetAcqUnitIds": []
          }
        ],
        "updateType": "Commit",
        "totalRecords": 2
      }
      """
    Given path 'finance/finance-data'
    And request updatedFinanceData
    When method PUT
    Then status 204

    Given path 'finance/budget', budgetId1
    When method GET
    Then status 200
    And match response.currentAllocation == 1100
    * print response

    Given path 'finance/transactions'
    And param query = '(budgetId==#(budgetId1))'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * print response


  @Negative
  Scenario: Check verification ERRORS in updating finance data
    * def updatedFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "FND1",
            "fundName": "Fund 1",
            "fundDescription": "UPDATED subdivided by geographic regions, to match individual selectors",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag1"]
            },
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": []
          }
        ],
        "updateType": "Commit",
        "totalRecords": 2
      }
      """
    Given path 'finance/finance-data'
    And request updatedFinanceData
    When method PUT
    Then status 400
    And match response.message == 'Validation errors'
    And match response.errors contains 'budgetStatus: must


    # Check validation for missing required fields
    * def invalidFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "FND1"
          }
        ],
        "updateType": "Commit",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request invalidFinanceData
    When method PUT
    Then status 422
    And match response.errors[*].message contains 'Budget status is required'
    And match response.errors[*].message contains 'Budget initial allocation is required'

    # Verify validation for mismatched fiscal year IDs
    * def mismatchedFyData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId2)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "FND1",
            "fundName": "Fund 1",
            "fundDescription": "Test description",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "Test transaction",
            "transactionTag": "test-tag"
          }
        ],
        "updateType": "Commit",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request mismatchedFyData
    When method PUT
    Then status 422
    And match response.errors[0].message contains 'Fiscal year ID must be the same as other fiscal year ID'

    # Check validation for allocation change > initial allocation
    * def invalidAllocationChangeData =
    """
    {
      "fyFinanceData": [
        {
          "fiscalYearId": "#(fiscalYearId1)",
          "fiscalYearCode": "TESTFY1",
          "fundId": "#(fundId1)",
          "fundCode": "FND1",
          "fundName": "Fund 1",
          "fundDescription": "Test description",
          "fundStatus": "Active",
          "fundAcqUnitIds": [],
          "budgetId": "#(budgetId1)",
          "budgetName": "Budget 1",
          "budgetStatus": "Active",
          "budgetInitialAllocation": 1000,
          "budgetAllocationChange": -1500,
          "budgetAllowableExpenditure": 150.0,
          "budgetAllowableEncumbrance": 160.0,
          "budgetAcqUnitIds": [],
          "transactionDescription": "Test transaction",
          "transactionTag": "test-tag"
        }
      ],
      "updateType": "Commit",
      "totalRecords": 1
    }
    """
  Given path 'finance/finance-data'
  And request invalidAllocationChangeData
  When method PUT
  Then status 422
  And match response.errors[0].message contains 'Allocation change should not be more than initial allocation'

  @Positive
  Scenario: Verify PUT finance data with PREVIEW mode
    * def previewFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "FND1",
            "fundName": "Fund 1",
            "fundDescription": "Updated Test preview mode",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 500,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "Preview transaction",
            "transactionTag": "test-tag"
          }
        ],
        "updateType": "Preview",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request previewFinanceData
    When method PUT
    Then status 204

    # Verify no actual changes were made
    Given path 'finance/budget', budgetId1
    When method GET
    Then status 200
    And match response.currentAllocation == 1000

    Given path 'finance/funds', fundId1
    When method GET
    Then status 200
    And match response.fundDescription != 'Updated Test preview mode'

    Given path 'finance/fund-update-log'
    And param query = '(fundId==#(fundId1))'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  @Positive
  Scenario: Verify Action log after finance data update.
    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    * print response

  @Ignore @UpdateFinanceData
  Scenario:
    * def updatedFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId1)",
            "fundCode": "FND1",
            "fundName": "Fund 1",
            "fundDescription": "UPDATED subdivided by geographic regions, to match individual selectors",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag1"]
            },
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1",
            "budgetStatus": "Inactive",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": []
          },
          {
            "fiscalYearId": "#(fiscalYearId1)",
            "fiscalYearCode": "TESTFY1",
            "fundId": "#(fundId2)",
            "fundCode": "FND2",
            "fundName": "Fund 2",
            "fundDescription": "UPDATED WAITING FOR ADMIN APPROVAL; use for Canada once CANLATHIST is inactivated",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag2"]
            },
            "budgetId": "#(budgetId2)",
            "budgetName": "Budget 2",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 2000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 250.0,
            "budgetAllowableEncumbrance": 260.0,
            "budgetAcqUnitIds": []
          }
        ],
        "updateType": "Preview",
        "totalRecords": 2
      }
      """

    Given path 'finance/finance-data'
    And request updatedFinanceData
    When method PUT
    Then status 204

