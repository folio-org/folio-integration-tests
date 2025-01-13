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
    * def fundId3 = callonce uuid3
    * def budgetId1 = callonce uuid4
    * def budgetId2 = callonce uuid5
    * def budgetId3 = callonce uuid6
    * def fiscalYearId1 = callonce uuid7
    * def fiscalYearId2 = callonce uuid8
    * def fiscalYearId3 = callonce uuid9
    * def ledgerId1 = callonce uuid10
    * def ledgerId2 = callonce uuid11
    * def ledgerId3 = callonce uuid12
    * def acqUnitId = callonce uuid13

    * def userId = "00000000-1111-5555-9999-999999999992"

    * configure headers = headersAdmin

    ### Before All ###

    # Create Acq Unit and assign user (each scenario)
    * def v = callonce createAcqUnit { id: '#(acqUnitId)', name: 'Acq Unit 1', isDeleted: false, protectCreate: true, protectRead: true, protectUpdate: true, protectDelete: true }
    * def v = callonce assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }

    # Prepare finance data
    * table fiscalYears
      | id            | code      | periodStart  | periodEnd    | series   |
      | fiscalYearId1 | 'FY2044' | '2044-01-01' | '2044-12-31' | 'TESTFY1' |
      | fiscalYearId2 | 'FY2045' | '2045-01-01' | '2045-12-31' | 'TESTFY2' |
      | fiscalYearId3 | 'FY2046' | '2046-01-01' | '2046-12-31' | 'TESTFY3' |
    * def v = callonce createFiscalYear fiscalYears

    * table ledgers
      | id        | code   | name       | fiscalYearId |
      | ledgerId1 | 'LDG1' | 'Ledger 1' | fiscalYearId1   |
      | ledgerId2 | 'LDG2' | 'Ledger 2' | fiscalYearId2   |
      | ledgerId3 | 'LDG3' | 'Ledger 3' | fiscalYearId3   |
    * def v = callonce createLedger ledgers

    * table funds
      | id      | code   | ledgerId  | acqUnitIds       |
      | fundId1 | 'FND1' | ledgerId1 | []               |
      | fundId2 | 'FND2' | ledgerId2 | ['#(acqUnitId)'] |
#      | fundId3 | 'FND3' | ledgerId3 | [] |
    * def v = callonce createFund funds

    * table budgets
      | id        | fundId  | fiscalYearId  | allocated |
      | budgetId1 | fundId1 | fiscalYearId1 | 1000      |
      | budgetId2 | fundId2 | fiscalYearId2 | 2000      |
#      | budgetId3 | fundId3 | fiscalYearId3 | 2000      |
    * def v = callonce createBudget budgets

    * configure headers = headersUser

  @Positive
  Scenario: Verify GET finance data operations
    # 1. Verify get finance data with fiscal year id. FY1 -> 1 fund, FY2 -> 1 fund, FY -> 0 fund
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundId == fundId1

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundId == fundId2

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId3
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundId == '#notpresent'
    And match $.fyFinanceData[0].budgetId == '#notpresent'

    Given path 'finance/finance-data'
    And param query = '(fiscalYearId==' + fiscalYearId1 + ' and ' + 'fiscalYearId==' + fiscalYearId2 + ')'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 2. Verify get finance data details
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2
    When method GET
    Then status 200
    And match $.fyFinanceData[0].fiscalYearId == fiscalYearId2
    And match $.fyFinanceData[0].fundId == fundId2
    And match $.fyFinanceData[0].fundCode == '#present'
    And match $.fyFinanceData[0].fundName == '#present'
    And match $.fyFinanceData[0].fundDescription == '#present'
    And match $.fyFinanceData[0].fundStatus == 'Active'
    And match $.fyFinanceData[0].fundAcqUnitIds contains  acqUnitId
    And match $.fyFinanceData[0].ledgerId ==  ledgerId2
    And match $.fyFinanceData[0].ledgerCode == '#present'
    And match $.fyFinanceData[0].budgetId == budgetId2
    And match $.fyFinanceData[0].budgetName == '#present'
    And match $.fyFinanceData[0].budgetStatus == 'Active'
    And match $.fyFinanceData[0].budgetInitialAllocation == 2000
    And match $.fyFinanceData[0].budgetAllowableExpenditure == 100
    And match $.fyFinanceData[0].budgetAllowableEncumbrance == 100
    And match $.fyFinanceData[0].budgetAcqUnitIds == '#present'

    # 3. Verify get finance data with acq unit id restrictions, fiscal year id2 should be empty for user after removing acq unit
    * configure headers = headersAdmin
    * def v = call deleteUserFromAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * configure headers = headersAdmin
    * def v = call assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2
    When method GET
    Then status 200
    And match $.totalRecords == 1


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
            "budgetAcqUnitIds": [],
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
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
    And match response.message == 'Budget status is required'
    And match response.parameters[0].key == 'financeData[0].budgetStatus'

    # Verify validation for mismatched fiscal year IDs
    * def mismatchedFyData =
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
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
          },
          {
            "fiscalYearId": "#(fiscalYearId2)",
            "fiscalYearCode": "TESTFY2",
            "fundId": "#(fundId2)",
            "fundCode": "FND2",
            "fundName": "Fund 2",
            "fundDescription": "Test description",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "budgetId": "#(budgetId2)",
            "budgetName": "Budget 2",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 0,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
          },
        ],
        "updateType": "Commit",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request mismatchedFyData
    When method PUT
    Then status 400
    And match response.message contains 'Fiscal year ID must be the same as other fiscal year'

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
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
          }
        ],
        "updateType": "Commit",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request invalidAllocationChangeData
    When method PUT
    Then status 400
    And match response.message contains 'Allocation change cannot be greater than initial allocation'

  @Positive
  Scenario: Verify PUT finance data operations with COMMIT and only fund and budget fields
    # 1. Update finance data
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1
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
            "fundCode": "FND1UPDATED",
            "fundName": "Fund 1 Updated",
            "fundDescription": "UPDATED subdivided by geographic regions, to match individual selectors",
            "fundStatus": "Inactive",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": ["updatedTag1"]
            },
            "budgetId": "#(budgetId1)",
            "budgetName": "Budget 1 Updated",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 100,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
          }
        ],
        "updateType": "Commit",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request updatedFinanceData
    When method PUT
    Then status 200

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1 + ' and ' + 'fundId==' + fundId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundDescription == 'UPDATED subdivided by geographic regions, to match individual selectors'
    And match $.fyFinanceData[0].fundTags.tagList contains 'updatedTag1'
    And match $.fyFinanceData[0].budgetAllowableExpenditure == 150.0
    And match $.fyFinanceData[0].budgetAllowableEncumbrance == 160.0
    # the fields shouldn't be updated
    And match $.fyFinanceData[0].fundCode != 'FND1UPDATED'
    And match $.fyFinanceData[0].fundName != 'Fund 1 Updated'
    And match $.fyFinanceData[0].fundStatus != 'Inactive'
    And match $.fyFinanceData[0].budgetName != 'Budget 1 Updated'

    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.allocated == 1100

    Given path 'finance/transactions'
    And param query = 'transactionType==Allocation AND fiscalYearId==' + fiscalYearId1 + ' AND ' + 'toFundId==' + fundId1
    When method GET
    Then status 200
    And match $.transactions[*].amount contains 100

    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check with minus allocation
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
            "budgetAllocationChange": -200,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
          },
        ],
        "updateType": "Commit",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request updatedFinanceData
    When method PUT
    Then status 200

    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.allocated == 900

    Given path 'finance/transactions'
    And param query = 'transactionType==Allocation AND fiscalYearId==' + fiscalYearId1 + ' AND ' + 'fromFundId==' + fundId1
    When method GET
    Then status 200
    And match $.transactions[*].amount contains 200

    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    And match $.totalRecords == 1


  @Positive
  Scenario: Verify PUT finance data with PREVIEW mode
    * def previewFinanceData =
      """
      {
        "fyFinanceData": [
          {
            "fiscalYearId": "#(fiscalYearId2)",
            "fiscalYearCode": "TESTFY2",
            "fundId": "#(fundId2)",
            "fundCode": "FND2",
            "fundName": "Fund 2",
            "fundDescription": "Updated Test preview mode",
            "fundStatus": "Active",
            "fundAcqUnitIds": [],
            "fundTags": {
              "tagList": []
            },
            "budgetId": "#(budgetId2)",
            "budgetName": "Budget 2",
            "budgetStatus": "Active",
            "budgetInitialAllocation": 1000,
            "budgetAllocationChange": 500,
            "budgetAllowableExpenditure": 150.0,
            "budgetAllowableEncumbrance": 160.0,
            "budgetAcqUnitIds": [],
            "transactionDescription": "End of year adjustment",
            "transactionTag": {
              "tagList": ["Urgent"]
            }
          }
        ],
        "updateType": "Preview",
        "totalRecords": 1
      }
      """
    Given path 'finance/finance-data'
    And request previewFinanceData
    When method PUT
    Then status 200
    And match $.financeData[0].budgetAfterAllocation == 1500

    # Verify no actual changes were made
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.allocated == 1000

    Given path 'finance/funds', fundId2
    When method GET
    Then status 200
    And match $.fundDescription != 'Updated Test preview mode'


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

