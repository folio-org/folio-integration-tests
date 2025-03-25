Feature: Karate tests for FY finance bulk get/update functionality
  # for FAT-17236, MODFIN-402, MODFIN-407, MODFISTO-517

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure retry = { count: 10, interval: 1000 }
    * callonce variables

    * def fiscalYearId1 = callonce uuid { n: 1 }
    * def fiscalYearId2 = callonce uuid { n: 2 }
    * def fiscalYearId3 = callonce uuid { n: 3 }
    * def acqUnitId = callonce uuid { n: 4 }
    * def ledgerId1 = callonce uuid { n: 5 }
    * def ledgerId2 = callonce uuid { n: 6 }
    * def ledgerId3 = callonce uuid { n: 7 }
    * def fundId1 = callonce uuid { n: 8 }
    * def fundId2 = callonce uuid { n: 9 }
    * def budgetId1 = callonce uuid { n: 10 }
    * def budgetId2 = callonce uuid { n: 11 }

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
      | id        | fiscalYearId  |
      | ledgerId1 | fiscalYearId1 |
      | ledgerId2 | fiscalYearId1 |
      | ledgerId3 | fiscalYearId1 |
    * def v = callonce createLedger ledgers

    * table funds
      | id      | ledgerId  | acqUnitIds       | name     | code    |
      | fundId1 | ledgerId1 | []               | 'Fund 1' | 'FUND1' |
      | fundId2 | ledgerId2 | ['#(acqUnitId)'] | 'Fund 2' | 'FUND2' |
    * def v = callonce createFund funds

    * table budgets
      | id        | fundId  | fiscalYearId  | allocated |
      | budgetId1 | fundId1 | fiscalYearId1 | 1000      |
      | budgetId2 | fundId2 | fiscalYearId2 | 2000      |
    * def v = callonce createBudget budgets

    * configure headers = headersUser

    * def createFinanceDataEntry =
      """
      function(data) {
        return {
          fiscalYearId: data.fiscalYearId,
          fiscalYearCode: data.fiscalYearCode,
          fundId: data.fundId,
          fundCode: data.fundCode,
          fundName: data.fundName,
          fundDescription: data.fundDescription,
          fundStatus: data.fundStatus,
          fundAcqUnitIds: data.fundAcqUnitIds,
          fundTags: { tagList: data.fundTags || [] },
          ledgerId: data.ledgerId,
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
        }
      }
      """
    * def createFinanceData =
      """
      function(data) {
        return {
          fyFinanceData: [createFinanceDataEntry(data)],
          updateType: data.updateType,
          totalRecords: 1
        }
      }
      """
    * def createFinancesData =
      """
      function(rows) {
        return {
          fyFinanceData: rows.map(row => createFinanceDataEntry(row)),
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
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND1'  | 'Fund 1' | 'Test description' | 'Active'   | []             | []       | budgetId1 | budgetId1  |              | 1000              | 1000              | -1500            | 'Commit'   | 150.0                      | 160.0                      | ledgerId1 |
    * def requestBody = createFinanceData(missingBudget[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match $.errors[0].message == 'budgetStatus is required'
    And match $.errors[0].parameters[0].key == 'financeData[0].budgetStatus'

    * table incorrectBudgetStatus
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND1'  | 'Fund 1' | 'Test description' | 'Active'   | []             | []       | budgetId1 | budgetId1  | 'Hold'       | 1000              | 1000              | -1500            | 'Commit'   | 150.0                      | 160.0                      | ledgerId1 |
    * def requestBody = createFinanceData(incorrectBudgetStatus[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Budget status is incorrect'
    And match $.errors[0].code == 'budgetStatusIncorrect'
    And match $.errors[0].parameters[0].key == 'financeData[0].budgetStatus'

    * table incorrectFundStatus
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND1'  | 'Fund 1' | 'Test description' | 'Hold'     | []             | []       | budgetId1 | budgetId1  | 'Hold'       | 1000              | 1000              | -1500            | 'Commit'   | 150.0                      | 160.0                      | ledgerId1 |
    * def requestBody = createFinanceData(incorrectFundStatus[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Fund status is incorrect'
    And match $.errors[0].code == 'fundStatusIncorrect'
    And match $.errors[0].parameters[0].key == 'financeData[0].fundStatus'

    # Verify validation for mismatched fiscal year IDs
    * table twoMistmatchedFiscalYearData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND1'  | 'Fund 1' | 'Description 1' | 'Active'   | []             | []       | budgetId1 | budgetId1  | 'Active'     | 1000              | 1000              | 100              | 'Commit'   | ledgerId1 |
      | fiscalYearId2 | 'TESTFY2'      | fundId2 | 'FUND2'  | 'Fund 2' | 'Description 2' | 'Active'   | []             | []       | budgetId2 | budgetId2  | 'Active'     | 2000              | 1000              | 200              | 'Commit'   | ledgerId2 |
    * def requestBody = createFinancesData(twoMistmatchedFiscalYearData)
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match $.errors[*].message contains 'Fiscal year ID must be the same as other fiscal year ID(s) \'[' + fiscalYearId1 + ']\' in the request'

    # Verify validation for mismatched fiscal year IDs
    * table duplicateFinanceData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND1'  | 'Fund 1' | 'Description 1' | 'Active'   | []             | []       | budgetId1 | budgetId1  | 'Active'     | 1000              | 1000              | 100              | 'Commit'   | ledgerId1 |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND2'  | 'Fund 2' | 'Description 2' | 'Active'   | []             | []       | budgetId1 | budgetId1  | 'Active'     | 2000              | 1000              | 200              | 'Commit'   | ledgerId1 |
    * def requestBody = createFinancesData(duplicateFinanceData)
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 400
    And match $.errors[*].message contains 'Finance data collection contains duplicate fund, budget and fiscal year IDs'

    # Check validation for allocation change > initial allocation
    * table invalidAllocationChangeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId1 | 'FUND1'  | 'Fund 1' | 'Test description' | 'Active'   | []             | []       | budgetId1 | budgetId1  | 'Active'     | 2000              | 1000              | -1500            | 'Commit'   | 150.0                      | 160.0                      | ledgerId1 |
    * def requestBody = createFinanceData(invalidAllocationChangeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 422
    And match $.errors[*].message contains 'New total allocation cannot be negative'

    # Send incorrect value and check for ERROR log
    * def customTag = "VerificationErrorLogBugdet"
    * table invalidAllocationChangeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription    | fundStatus | fundAcqUnitIds | fundTags | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | budgetAllowableExpenditure | budgetAllowableEncumbrance | ledgerId  |
      | fiscalYearId1 | 'TESTFY1'      | fundId2 | 'FUND2'  | 'Fund 2' | 'Test description' | 'Active'   | []             | [#(customTag)]       | budgetId2 | budgetId2 | 'Active'     | 2000              | 2000              | -1500            | 'Commit'   | 150.0                      | 160.0                      | ledgerId2 |
    * def requestBody = createFinanceData(invalidAllocationChangeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    # TODO: change to 422 after fixing validation in mod-finance
    Then status 500

    # Get job id by unique fund tag
    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    * def filteredJobs = karate.filter(response.fundUpdateLogs, j => j.jobDetails.fyFinanceData[0].fundTags.tagList.includes(customTag))
    * def jobId = filteredJobs[0].id

    # Verify the job has ERROR status
    Given path 'finance-storage/fund-update-logs'
    And retry until karate.jsonPath(response, "$.fundUpdateLogs[?(@.id=='" + jobId + "')]")[0].status == 'ERROR'
    When method GET
    Then status 200


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
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription                                                           | fundStatus | fundAcqUnitIds | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | fundTags        | ledgerId  |
      | fiscalYearId1 | 'FDATAFY2044'  | fundId1 | 'FUND1'  | 'Fund 1' | 'UPDATED subdivided by geographic regions, to match individual selectors' | 'Inactive' | []             | budgetId1 | budgetId1  | 'Active'     | 1000              | 1000              | 100              | 'Commit'   | ['updatedTag1'] | ledgerId1 |
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
    And retry until karate.jsonPath(response, "$.fundUpdateLogs[?(@.jobDetails.fyFinanceData[0].fundId=='" + fundId1 + "')]")[0].status == 'COMPLETED'
    When method GET
    Then status 200
    * def log = karate.jsonPath(response, "$.fundUpdateLogs[?(@.jobDetails.fyFinanceData[0].fundId=='" + fundId1 + "')]")[0]
    * match log.status == 'COMPLETED'
    * match log.jobDetails ==  {"fyFinanceData":[{"fundId":"#(fundId1)","budgetId":"#(budgetId1)","fundCode":"FUND1","fundName":"Fund 1","fundTags":{"tagList":["updatedTag1"]},"budgetName":"#(budgetId1)","fundStatus":"Inactive","budgetStatus":"Active","fiscalYearId":"#(fiscalYearId1)","isFundChanged":true,"fiscalYearCode":"FDATAFY2044","fundAcqUnitIds":[],"ledgerId":"#(ledgerId1)","transactionTag":{"tagList":["Urgent"]},"fundDescription":"UPDATED subdivided by geographic regions, to match individual selectors","isBudgetChanged":true,"budgetAcqUnitIds":[],"budgetAfterAllocation":1100.0,"budgetAllocationChange":100.0,"transactionDescription":"End of year adjustment","budgetCurrentAllocation":1000.0,"budgetInitialAllocation":1000.0,"budgetAllowableEncumbrance":160.0,"budgetAllowableExpenditure":150.0}]}

    # Check with minus -200 allocation
    * table financeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription       | fundStatus | fundAcqUnitIds | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | fundTags        | ledgerId  |
      | fiscalYearId1 | 'FDATAFY2044'  | fundId1 | 'FUND1'  | 'Fund 1' | 'UPDATED Description' | 'Inactive' | []             | budgetId1 | budgetId1  | 'Active'     | 1000              | 1100              | -200             | 'Commit'   | ['updatedTag1'] | ledgerId1 |
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

    # negative allocation -> no change in fundStatus
    Given path 'finance/funds', fundId1
    When method GET
    Then status 200
    And match $.fund.fundStatus == 'Inactive'

    Given path 'finance-storage/fund-update-logs'
    And retry until karate.jsonPath(response, "$.fundUpdateLogs[?(@.jobDetails.fyFinanceData[0].fundDescription=='UPDATED Description')]")[0].status == "COMPLETED"
    When method GET
    Then status 200
    * def log = karate.jsonPath(response, "$.fundUpdateLogs[?(@.jobDetails.fyFinanceData[0].fundDescription=='UPDATED Description')]")[0]
    * match log.status == 'COMPLETED'

    # Check fundStatus change with positive allocation
    * table financeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription       | fundStatus | fundAcqUnitIds | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | fundTags        | ledgerId  |
      | fiscalYearId1 | 'FDATAFY2044'  | fundId1 | 'FUND1'  | 'Fund 1' | 'UPDATED Description' | 'Inactive' | []             | budgetId1 | budgetId1  | 'Active'     | 1000              | 900               | 200              | 'Commit'   | ['updatedTag1'] | ledgerId1 |
    * def requestBody = createFinanceData(financeData[0])
    Given path 'finance/finance-data'
    And request requestBody
    When method PUT
    Then status 200

    Given path 'finance/funds', fundId1
    When method GET
    Then status 200
    And match $.fund.fundStatus == 'Active'


  @Positive
  Scenario: Verify PUT finance data with PREVIEW mode
    * table financeData
      | fiscalYearId  | fiscalYearCode | fundId  | fundCode | fundName | fundDescription             | fundStatus | fundAcqUnitIds | budgetId  | budgetName | budgetStatus | initialAllocation | currentAllocation | allocationChange | updateType | ledgerId  |
      | fiscalYearId2 | 'TESTFY2'      | fundId2 | 'FUND2'  | 'Fund 2' | 'Updated Test preview mode' | 'Active'   | []             | budgetId2 | budgetId2  | 'Active'     | 2000              | 2000              | 500              | 'Preview'  | ledgerId2 |

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

    * call pause 1000

    Given path 'finance-storage/fund-update-logs'
    When method GET
    Then status 200
    And match karate.jsonPath(response, "$.fundUpdateLogs[?(@.jobDetails.fyFinanceData[0].fundDescription=='Updated Test preview mode')]") == '#[0]'


  @Positive
  Scenario: Creating a new budget for a future fiscal year
    # 1. Create a new ledger and fund
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId1)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }

    # 2. Get finance data for a planned fiscal year
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1 + ' AND ledgerId==' + ledgerId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.fyFinanceData[0].budgetId == '#notpresent'
    * def financeDataCollection = response

    # 3. Set allocation change to 100 and PUT finance data
    * set financeDataCollection.updateType = 'Commit'
    * set financeDataCollection.fyFinanceData[0].budgetAllocationChange = 100.0
    Given path 'finance/finance-data'
    And request financeDataCollection
    When method PUT
    Then status 200

    # 4. Check the new budget was created with the allocation and the Planned status
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.budgets[0].allocated == 100.0
    And match $.budgets[0].budgetStatus == 'Planned'


  @Positive
  Scenario: Creating a new budget for a current fiscal year, and new budget should change fundStatus to active
    # 1. Create a new fiscal year, ledger, fund and budget in the current fiscal year
    * def currentYear = call getCurrentYear
    * def codePrefix = call random_string
    * def code = codePrefix + currentYear
    * def fiscalYearId = call uuid
    * def periodStart = currentYear + '-01-01T00:00:00Z'
    * def periodEnd = currentYear + '-12-30T23:59:59Z'
    * def ledgerId = call uuid
    * def fundId = call uuid

    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: '#(code)', periodStart: '#(periodStart)', periodEnd: '#(periodEnd)' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }

    # 2. Get finance data for current fiscal year
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId + ' AND ledgerId==' + ledgerId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.fyFinanceData[0].budgetId == '#notpresent'
    * def financeDataCollection = response

    # 3. Set allocation change to 100 and PUT finance data
    * set financeDataCollection.updateType = 'Commit'
    * set financeDataCollection.fyFinanceData[0].fundStatus = 'Inactive'
    Given path 'finance/finance-data'
    And request financeDataCollection
    When method PUT
    Then status 200

    # 4. Check the fund status is Inactive
    Given path 'finance/funds', fundId
    When method GET
    Then status 200
    And match $.fund.fundStatus == 'Inactive'

    # 5. Set allocation change to 100 and PUT finance data
    * set financeDataCollection.updateType = 'Commit'
    * set financeDataCollection.fyFinanceData[0].budgetAllocationChange = 100.0
    Given path 'finance/finance-data'
    And request financeDataCollection
    When method PUT
    Then status 200

    # 6. Check the new budget was created with the allocation and the Active status
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.budgets[0].allocated == 100.0
    And match $.budgets[0].budgetStatus == 'Active'

    # 7. Check the fund status is Active
    Given path 'finance/funds', fundId
    When method GET
    Then status 200
    And match $.fund.fundStatus == 'Active'


  @Positive
  Scenario: Creating a new budget with a custom status
    # 1. Create a new ledger and fund
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId1)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }

    # 2. Get finance data for a planned fiscal year
    Given path 'finance/finance-data'
    And param query = 'fiscalYearId==' + fiscalYearId1 + ' AND ledgerId==' + ledgerId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.fyFinanceData[0].budgetId == '#notpresent'
    * def financeDataCollection = response

    # 3. Set budgetStatus to Inactive and PUT finance data
    * set financeDataCollection.updateType = 'Commit'
    * set financeDataCollection.fyFinanceData[0].budgetStatus = 'Inactive'
    Given path 'finance/finance-data'
    And request financeDataCollection
    When method PUT
    Then status 200

    # 4. Check the new budget was created with the allocation and the Inactive status
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.budgets[0].allocated == 0.0
    And match $.budgets[0].budgetStatus == 'Inactive'
