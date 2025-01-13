Feature: global finances

  Background:
    * url baseUrl
    * call login testAdmin

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * callonce variables

  Scenario: create fiscal year
    Given path 'finance/fiscal-years'
    And request
      """
      {
        "id": "ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
        "name": "TST-Fiscal Year 2025",
        "code": "FY2025",
        "description": "January 1 - December 30",
        "periodStart": "2025-01-01T00:00:00Z",
        "periodEnd": "2025-12-31T23:59:59Z",
        "series": "FY"
      }
      """
    When method POST
    Then status 201

  Scenario: create ledgers
    Given path 'finance-storage/ledgers'
    And request
      """
      {
        "id": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
        "code": "TST-LDG",
        "ledgerStatus": "Active",
        "name": "Test ledger",
        "fiscalYearOneId": "ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
        "restrictEncumbrance": false
      }
      """
    When method POST
    Then status 201

  Scenario: create planned fiscal year
    Given path 'finance/fiscal-years'
    And request
      """
      {
        "id": "ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf3",
        "name": "TST-Fiscal Year 2026",
        "code": "FY2026",
        "description": "January 1 - December 30",
        "periodStart": "2026-01-01T00:00:00Z",
        "periodEnd": "2026-12-31T23:59:59Z",
        "series": "FY"
      }
      """
    When method POST
    Then status 201

  Scenario: create ledgers with restrict encumbrance and expenditure
    Given path 'finance-storage/ledgers'
    And request
      """
      {
        "id": "5e4fbdab-f1b1-4be8-9c33-d3c41ec6a696",
        "code": "TST-LDG2",
        "ledgerStatus": "Active",
        "name": "Test ledger with restrictions",
        "fiscalYearOneId": "ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
      }
      """
    When method POST
    Then status 201

  Scenario: create funds
    * table funds
      | id                                     | code        | ledgerId                               | externalAccountNo              |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696' | 'TST-FND'   | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '1111111111111111111111111'    |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698' | 'TST-FND-2' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '22222222222222222222'         |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a638' | 'TST-FND-3' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '1111111111111111111111111-01' |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a639' | 'USHIST'    | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '1111111111111111111111111-01' |
    * def v = call createFund funds

  Scenario: create budgets
    * table budgets
      | id                                     | fundId                                 | fiscalYearId                           | allocated |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a697' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999   |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a658' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999   |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a618' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a638' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999   |
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a619' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a639' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999   |
    * def v = call createBudget budgets

  Scenario: create funds without budget
    Given path 'finance-storage/funds'
    And request
      """
      {
        "id": "c9363394-c13a-4470-bce5-3fdfce5a14cc",
        "code": "TST-FND-WO-BUDGET",
        "description": "Fund without budget for finance API Tests",
        "externalAccountNo": "2111111111111111111111111",
        "fundStatus": "Active",
        "ledgerId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
        "name": "Fund without budget for finance API Tests"
      }
      """
    When method POST
    Then status 201

  Scenario Outline: create expense classes
    Given path 'finance/expense-classes'
    And request
      """
      {
        "id": <id>,
        "code": <code>,
        "externalAccountNumberExt": <externalAccountNumberExt>,
        "name": <name>,
      }
      """
    When method POST
    Then status 201
    Examples:
      | id                                     | code   | name         | externalAccountNumberExt |
      | "1bcc3247-99bf-4dca-9b0f-7bc51a2998c2" | "Elec" | "Electronic" | "01"                     |
      | "5b5ebe3a-cf8b-4f16-a880-46873ef21388" | "Prn"  | "Print"      | "02"                     |
      | "9abc4491-b2f0-413c-be51-51675b15f366" | "Othr" | "Other"      | "03"                     |
