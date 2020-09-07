Feature: ledger

  Background:
    * url baseUrl

  Scenario: createLedger
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)

    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(id)",
      "code": "#(id)",
      "fiscalYearOneId": "#(fiscalYearId)",
      "ledgerStatus": "Active",
      "netTransfers": 0.0,
      "acqUnitIds": [],
      "restrictEncumbrance": true,
      "restrictExpenditures": true
    }
    """
    When method POST
    Then status 201
