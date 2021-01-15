Feature: rollover

  Background:
    * url baseUrl

  Scenario: createRollover

    * def ledgerId = karate.get('ledgerId', globalLedgerId)
    * def fiscalYearId = karate.get('ledgerId', globalFiscalYearId)
    * def plannedFiscalYearId = karate.get('ledgerId', globalPlannedFiscalYearId)
    * def approvalsFundTypeId = karate.get('ledgerId', globalFundType)

    Given path 'finance-storage/ledger-rollovers'
    And request
    """
      {
        "id": "#(id)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(plannedFiscalYearId)",
        "restrictEncumbrance": false,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "fundTypeId": "#(approvalsFundTypeId)",
            "rolloverAllocation": true,
            "rolloverAvailable": true,
            "adjustAllocation": 5,
            "addAvailableTo": "Available",
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Expended",
            "increaseBy": 5
          },
          {
            "orderType": "One-time",
            "basedOn": "Expended",
            "increaseBy": 4
          }
        ]
      }


    """
    When method POST
    Then status 201
