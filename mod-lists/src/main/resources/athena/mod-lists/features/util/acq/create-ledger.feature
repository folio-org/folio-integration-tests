Feature: Create ledger
  # parameters: id, code, fiscalYearId
  Background:
    * url baseUrl

  Scenario: Create ledger
    Given path 'finance/ledgers'
    And request { id: '#(id)', name: '#(code)', code: '#(code)', fiscalYearOneId: '#(fiscalYearId)', ledgerStatus: 'Active', restrictEncumbrance: false, restrictExpenditures: false }
    When method POST
    Then status 201
