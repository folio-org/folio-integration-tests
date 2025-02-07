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

    * def fundId1 = callonce uuid { n: 1 }
    * def fundId2 = callonce uuid { n: 2 }
    * def fundId3 = callonce uuid { n: 3 }
    * def budgetId1 = callonce uuid { n: 4 }
    * def budgetId2 = callonce uuid { n: 5 }
    * def budgetId3 = callonce uuid { n: 6 }
    * def fiscalYearId1 = callonce uuid { n: 7 }
    * def fiscalYearId2 = callonce uuid { n: 8 }
    * def fiscalYearId3 = callonce uuid { n: 9 }
    * def ledgerId1 = callonce uuid { n: 10 }
    * def ledgerId2 = callonce uuid { n: 11 }
    * def ledgerId3 = callonce uuid { n: 12 }
    * def acqUnitId = callonce uuid { n: 13 }

    * def userId = "00000000-1111-5555-9999-999999999992"

    * configure headers = headersAdmin

    ### Before All ###

    # Create Acq Unit and assign user (each scenario)
    * def v = callonce createAcqUnit { id: '#(acqUnitId)', name: '#(acqUnitId)', isDeleted: false, protectCreate: true, protectRead: true, protectUpdate: true, protectDelete: true }
    * def v = callonce assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }

    # Prepare finance data
    * table fiscalYears
      | id            | code          | periodStart  | periodEnd    | series    |
      | fiscalYearId1 | 'FDATAFY2044' | '2044-01-01' | '2044-12-31' | 'FDATAFY' |
      | fiscalYearId2 | 'FDATAFY2045' | '2045-01-01' | '2045-12-31' | 'FDATAFY' |
      | fiscalYearId3 | 'FDATAFY2046' | '2046-01-01' | '2046-12-31' | 'FDATAFY' |
    * def v = callonce createFiscalYear fiscalYears

    * table ledgers
      | id        | code   | name       | fiscalYearId   |
      | ledgerId1 | 'LDG1' | 'Ledger 1' | fiscalYearId1  |
      | ledgerId2 | 'LDG2' | 'Ledger 2' | fiscalYearId1  |
      | ledgerId3 | 'LDG3' | 'Ledger 3' | fiscalYearId1  |
    * def v = callonce createLedger ledgers

    * table funds
      | id      | code   | ledgerId  | acqUnitIds       |
      | fundId1 | 'FND1' | ledgerId1 | []               |
      | fundId2 | 'FND2' | ledgerId2 | ['#(acqUnitId)'] |
    * def v = callonce createFund funds

    * table budgets
      | id        | fundId  | fiscalYearId  | allocated |
      | budgetId1 | fundId1 | fiscalYearId1 | 1000      |
      | budgetId2 | fundId2 | fiscalYearId2 | 2000      |
    * def v = callonce createBudget budgets

    * configure headers = headersUser

    * def createFinanceData =
      """
      function(data) {
        return {
          fyFinanceData: [{
            fiscalYearId: data.fiscalYearId,
            fiscalYearCode: data.fiscalYearCode,
            fundId: data.fundId,
            fundCode: data.fundCode,
            fundName: data.fundName,
            fundDescription: data.fundDescription,
            fundStatus: data.fundStatus,
            fundAcqUnitIds: data.fundAcqUnitIds,
            fundTags: { tagList: data.fundTags || [] },
            budgetId: data.budgetId,
            budgetName: data.budgetName,
            budgetStatus: data.budgetStatus,
            budgetInitialAllocation: data.initialAllocation,
            budgetCurrentAllocation: data.currentAllocation,
            budgetAllocationChange: data.allocationChange,
            budgetAllowableExpenditure: 150.0,
            budgetAllowableEncumbrance: 160.0,
            budgetAcqUnitIds: [],
            transactionDescription: "End of year adjustment",
            transactionTag: { tagList: ['Urgent'] }
          }],
          updateType: data.updateType,
          totalRecords: 1
        }
      }
      """
    * def createFinancesData =
      """
      function(rows) {
        return {
          fyFinanceData: rows.map(row => ({
            fiscalYearId: row.fiscalYearId,
            fiscalYearCode: row.fiscalYearCode,
            fundId: row.fundId,
            fundCode: row.fundCode,
            fundName: row.fundName,
            fundDescription: row.fundDescription,
            fundStatus: row.fundStatus,
            fundAcqUnitIds: row.fundAcqUnitIds,
            fundTags: { tagList: row.fundTags || [] },
            budgetId: row.budgetId,
            budgetName: row.budgetName,
            budgetStatus: row.budgetStatus,
            budgetInitialAllocation: row.initialAllocation,
            budgetCurrentAllocation: row.currentAllocation,
            budgetAllocationChange: row.allocationChange,
            budgetAllowableExpenditure: 150.0,
            budgetAllowableEncumbrance: 160.0,
            budgetAcqUnitIds: [],
            transactionDescription: "End of year adjustment",
            transactionTag: { tagList: ['Urgent'] }
          })),
          updateType: rows[0].updateType,
          totalRecords: rows.length
        }
      }
      """

  @Positive
  Scenario: Verify GET finance data operations
    # 1. Verify get finance data by fiscal year id and ledger id.
    # fiscalYearId1 & ledgerId1 -> 1 fund, fiscalYearId2 & ledgerId2 -> 1 fund, fiscalYearId3 & ledgerId3 -> 0, fiscalYearId2 & ledgerId1 -> 1
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1 + ' AND ledgerId==' + ledgerId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundId == fundId1

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND ledgerId==' + ledgerId2
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundId == fundId2

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId3 + ' AND ledgerId==' + ledgerId3
    When method GET
    Then status 200
    And match $.totalRecords == 0
    And match $.fyFinanceData == '#[0]'

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND ledgerId==' + ledgerId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match $.fyFinanceData[0].fundId == fundId1

    # 2. Verify get finance data details
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND ledgerId==' + ledgerId2
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
    And match $.fyFinanceData[0].budgetCurrentAllocation == 2000
    And match $.fyFinanceData[0].budgetAllowableExpenditure == 100
    And match $.fyFinanceData[0].budgetAllowableEncumbrance == 100
    And match $.fyFinanceData[0].budgetAcqUnitIds == '#present'

    # 3. Verify get finance data with acq unit id restrictions, fiscal year id2 should be empty for user after removing acq unit
    * configure headers = headersAdmin
    * def v = call deleteUserFromAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND ledgerId==' + ledgerId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * configure headers = headersAdmin
    * def v = call assignUserToAcqUnit { userId: '#(userId)', acquisitionsUnitId: '#(acqUnitId)' }
    * configure headers = headersUser

    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND ledgerId==' + ledgerId2
    When method GET
    Then status 200
    And match $.totalRecords == 1


  @Negative
  Scenario: Check verification ERRORS in updating finance data
    * table missingBudget
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FND1'   | 'Fund 1' | 'Test description' | 'Active'   | []             | []       | budgetId1 | 'Budget 1' |              | 1000              | 1000              | -1500            | 'Commit'   | 150.0                      | 160.0                      |
    * def requestBody = createFinanceData(missingBudget[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match response.message == 'Budget status is required'
    And match response.parameters[0].key == 'financeData[0].budgetStatus'

    # Verify validation for mismatched fiscal year IDs
    * table twoMistmatchedFiscalYearData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName  | fundDescription   | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName  | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FND1'   | 'Fund 1'  | 'Description 1'   | 'Active'   | []             | []       | budgetId1 | 'Budget 1'  | 'Active'     | 1000              | 1000              | 100             | 'Commit'   |
      | fiscalYearId2 | 'TESTFY2'      | fundId2 | 'FND2'   | 'Fund 2'  | 'Description 2'   | 'Active'   | []             | []       | budgetId2 | 'Budget 2'  | 'Active'     | 2000              | 1000              | 200             | 'Commit'   |
    * def requestBody = createFinancesData(twoMistmatchedFiscalYearData)
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match response.message contains 'Fiscal year ID must be the same as other fiscal year'

    # Check validation for allocation change > initial allocation
    * table invalidAllocationChangeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FND1'   | 'Fund 1' | 'Test description' | 'Active'   | []             | []       | budgetId1 | 'Budget 1' | 'Active'     | 2000              | 1000              | -1500            | 'Commit'   | 150.0                      | 160.0                      |
    * def requestBody = createFinanceData(invalidAllocationChangeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match response.message contains 'Allocation change cannot be greater than current allocation'

    # Send incorrect value and check for ERROR log
    * table invalidAllocationChangeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FND1'   | 'Fund 1' | 'Test description' | 'Active'   | []             | []       | budgetId1 | 'Budget 1' | 'Active'     | 2000              | 2000              | -1500            | 'Commit'   | 150.0                      | 160.0                      |
    * def requestBody = createFinanceData(invalidAllocationChangeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 422

    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.fundUpdateLogs[0].status contains 'ERROR'


  @Positive
  Scenario: Verify PUT finance data operations with COMMIT and only fund and budget fields
    # 1. Update finance data and Verify changes
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1
    When method GET
    Then status 200
    * def financeDataCollection = response

    # 1.2 Set allocation change to 100 and update fund and budget fields
    * table financeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode      | fundName         | fundDescription                                                           | fundStatus | fundAcqUnitIds | budgetId  | budgetName         | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | fundTags        |
      | fiscalYearId1 | 'FDATAFY2044'  | fundId1 | 'FND1UPDATED' | 'Fund 1 Updated' | 'UPDATED subdivided by geographic regions, to match individual selectors' | 'Inactive' | []             | budgetId1 | 'Budget 1 Updated' | 'Active'     | 1000              | 1000              | 100              | 'Commit'   | ['updatedTag1'] |
    * def requestBody = createFinanceData(financeData[0])
    Given path 'finance/finance-data'
    And request requestBody
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
    And match $.fyFinanceData[0].fundStatus == 'Inactive'
    # the fields shouldn't be updated
    And match $.fyFinanceData[0].fundCode != 'FND1UPDATED'
    And match $.fyFinanceData[0].fundName != 'Fund 1 Updated'
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
    And match $.totalRecords == 2
    And match $.fundUpdateLogs[*].status contains 'COMPLETED'
    And match $.fundUpdateLogs[*].jobDetails contains {"fyFinanceData":[{"fundId":"#(fundId1)","budgetId":"#(budgetId1)","fundCode":"FND1UPDATED","fundName":"Fund 1 Updated","fundTags":{"tagList":["updatedTag1"]},"budgetName":"Budget 1 Updated","fundStatus":"Inactive","budgetStatus":"Active","fiscalYearId":"#(fiscalYearId1)","fiscalYearCode":"FDATAFY2044","fundAcqUnitIds":[],"transactionTag":{"tagList":["Urgent"]},"fundDescription":"UPDATED subdivided by geographic regions, to match individual selectors","budgetAcqUnitIds":[],"budgetAfterAllocation":1100.0,"budgetAllocationChange":100.0,"transactionDescription":"End of year adjustment","budgetInitialAllocation":1000.0,"budgetCurrentAllocation":1000.0,"budgetAllowableEncumbrance":160.0,"budgetAllowableExpenditure":150.0}]}

    # Check with minus -200 allocation
    * table financeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription       | fundStatus | fundAcqUnitIds | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | fundTags        |
      | fiscalYearId1 | 'FDATAFY2044'  | fundId1 | 'FND1'   | 'Fund 1' | 'UPDATED Description' | 'Active'   | []             | budgetId1 | 'Budget 1' | 'Active'     | 1000              | 1100              | -200             | 'Commit'   | ['updatedTag1'] |
    * def requestBody = createFinanceData(financeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 200

    # allocation = 1100 - 200
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
    And match $.totalRecords == 3
    And match $.fundUpdateLogs[*].status contains 'COMPLETED'
    And match $.fundUpdateLogs[*].jobDetails contains {"fyFinanceData":[{"fundId":"#(fundId1)","budgetId":"#(budgetId1)","fundCode":"FND1","fundName":"Fund 1","fundTags":{"tagList":["updatedTag1"]},"budgetName":"Budget 1","fundStatus":"Active","budgetStatus":"Active","fiscalYearId":"#(fiscalYearId1)","fiscalYearCode":"FDATAFY2044","fundAcqUnitIds":[],"transactionTag":{"tagList":["Urgent"]},"fundDescription":"UPDATED Description","budgetAcqUnitIds":[],"budgetAfterAllocation":900.0,"budgetAllocationChange":-200.0,"transactionDescription":"End of year adjustment","budgetInitialAllocation":1000.0,"budgetCurrentAllocation":1100.0,"budgetAllowableEncumbrance":160.0,"budgetAllowableExpenditure":150.0}]}


  @Positive
  Scenario: Verify PUT finance data with PREVIEW mode
    * table financeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription             | fundStatus | fundAcqUnitIds | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType |
      | fiscalYearId2 | 'TESTFY2'      | fundId2 | 'FND2'   | 'Fund 2' | 'Updated Test preview mode' | 'Active'   | []             | budgetId2 | 'Budget 2' | 'Active'     | 2000              | 2000              | 500              | 'Preview'  |

    * def requestBody = createFinanceData(financeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 200
    And match $.fyFinanceData[0].budgetAfterAllocation == 2500

    # Verify no actual changes were made in fund, budget and logs

    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.allocated != 2500

    Given path 'finance/funds', fundId2
    When method GET
    Then status 200
    And match $.fund.description != 'Updated Preview Description'

    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    And match $.totalRecords == 3
