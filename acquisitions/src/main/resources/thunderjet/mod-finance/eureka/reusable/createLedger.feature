Feature: ledger

  Background:
    * url baseUrl

  Scenario: createLedger
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def restrictEncumbrance = karate.get('restrictEncumbrance', true)
    * def restrictExpenditures = karate.get('restrictExpenditures', true)

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
      "restrictEncumbrance": #(restrictEncumbrance),
      "restrictExpenditures": #(restrictExpenditures)
    }
    """
    When method POST
    Then status 201
