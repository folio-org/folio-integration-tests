Feature: global finances

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # load global variables
    * callonce variables

  Scenario: create fiscal year
    * table fiscalYears
      | id                                     | code     | periodStart            | periodEnd              | series
      | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 'FY2024' | '2024-01-01T00:00:00Z' | '2024-12-31T23:59:59Z' | 'FY'
      | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf3' | 'FY2025' | '2025-01-01T00:00:00Z' | '2025-12-31T23:59:59Z' | 'FY'
    * def v = call createFiscalYear fiscalYears

  Scenario: create ledgers
    * table ledgers
      | id                                     | fiscalYearId                           | restrictEncumbrance  | restrictExpenditure
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | false                | false
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec6a696' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | true                 | true
    * def v = call createLedger ledgers

  Scenario: create funds
    * table funds
      | id                                     | code                | ledgerId                               | externalAccountNo
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696' | 'TST-FND'           | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '1111111111111111111111111'
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698' | 'TST-FND-2'         | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '22222222222222222222'
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a638' | 'TST-FND-3'         | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '1111111111111111111111111-01'
      | 'c9363394-c13a-4470-bce5-3fdfce5a14cc' | 'TST-FND-WO-BUDGET' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695' | '2111111111111111111111111'
    * def v = call createFund funds

  Scenario: create budgets
    * table budgets
      | id                                     | fundId                                 | fiscalYearId                           | allocated
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a697' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a658' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999
      | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a618' | '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a638' | 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2' | 9999999
    * def v = call createBudget budgets

  Scenario: create expense classes
    * table expenseClasses
      | id                                     | code   | name         | externalAccountNumberExt |
      | "1bcc3247-99bf-4dca-9b0f-7bc51a2998c2" | "Elec" | "Electronic" | "01"                     |
      | "5b5ebe3a-cf8b-4f16-a880-46873ef21388" | "Prn"  | "Print"      | "02"                     |
      | "9abc4491-b2f0-413c-be51-51675b15f366" | "Othr" | "Other"      | "03"                     |
    * def v = call createExpenseClass expenseClasses
