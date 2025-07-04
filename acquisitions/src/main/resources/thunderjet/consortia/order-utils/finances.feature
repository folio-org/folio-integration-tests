@parallel=false
Feature: Central finances

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }

    # load central variables
    * callonce variablesCentral

  Scenario: Create fiscal years
    * table fiscalYears
      | id                         | code     | periodStart            | periodEnd              | series |
      | centralFiscalYearId        | 'FY2025' | '2025-01-01T00:00:00Z' | '2025-12-31T23:59:59Z' | 'FY'   |
      | centralPlannedFiscalYearId | 'FY2026' | '2026-01-01T00:00:00Z' | '2026-12-31T23:59:59Z' | 'FY'   |
    * def v = call createFiscalYear fiscalYears

  Scenario: Create ledgers
    * table ledgers
      | id                              | fiscalYearId        | restrictEncumbrance | restrictExpenditure |
      | centralLedgerId                 | centralFiscalYearId | false               | false               |
      | centralLedgerWithRestrictionsId | centralFiscalYearId | true                | true                |
    * def v = call createLedger ledgers

  Scenario: Create funds
    * table funds
      | id                       | code                         | ledgerId        | externalAccountNo              |
      | centralFundId            | centralFundCode              | centralLedgerId | '1111111111111111111111111'    |
      | centralFundId2           | centralFundCode2             | centralLedgerId | '22222222222222222222'         |
      | centralFundId3           | centralFundCode3             | centralLedgerId | '1111111111111111111111111-01' |
      | centralFundWithoutBudget | centralFundWithoutBudgetCode | centralLedgerId | '2111111111111111111111111'    |
    * def v = call createFund funds

  Scenario: Create budgets
    * table budgets
      | id               | fundId         | fiscalYearId        | allocated |
      | centralBudgetId  | centralFundId  | centralFiscalYearId | 9999999   |
      | centralBudgetId2 | centralFundId2 | centralFiscalYearId | 9999999   |
      | centralBudgetId3 | centralFundId3 | centralFiscalYearId | 9999999   |
    * def v = call createBudget budgets

  Scenario: Create expense classes
    * table expenseClasses
      | id                         | code   | name         | externalAccountNumberExt |
      | centralElecExpenseClassId  | "Elec" | "Electronic" | "01"                     |
      | centralPrnExpenseClassId   | "Prn"  | "Print"      | "02"                     |
      | centralOtherExpenseClassId | "Othr" | "Other"      | "03"                     |
    * def v = call createExpenseClass expenseClasses
