Feature: rollover
  # parameters: id, ledgerId, fromFiscalYearId, toFiscalYearId, restrictEncumbrance, restrictExpenditures, needCloseBudgets, rolloverType, budgetsRollover, encumbrancesRollover

  Background:
    * url baseUrl

  Scenario: Perform a fiscal year rollover, without checking for status or errors
    * def restrictEncumbrance = karate.get('restrictEncumbrance', false)
    * def restrictExpenditures = karate.get('restrictExpenditures', false)
    * def needCloseBudgets = karate.get('needCloseBudgets', true)
    * def rolloverType = karate.get('rolloverType', 'Commit')

    ## Fiscal year rollover
    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(id)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": "#(restrictEncumbrance)",
        "restrictExpenditures": "#(restrictExpenditures)",
        "needCloseBudgets": "#(needCloseBudgets)",
        "rolloverType": "#(rolloverType)",
        "budgetsRollover": "#(budgetsRollover)",
        "encumbrancesRollover": "#(encumbrancesRollover)"
      }
      """
    When method POST
    Then status 201


    ## Wait for rollover to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + id
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200
