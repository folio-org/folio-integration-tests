Feature: fund

  Background:
    * url baseUrl

  Scenario: createRolloverError

    * def ledgerId = karate.get('ledgerId', globalLedgerId)
    * def purchaseOrderId = karate.get('ledgerId', globalLedgerId)
    * def globalFiscalYearId = karate.get('ledgerId', globalLedgerId)

    Given path 'finance-storage/ledger-rollovers-errors'
    And request
    """
      {
        "id": "#(id)",
        "ledgerRolloverId": "#(ledgerRolloverId)",
        "errorType": "Order",
        "failedAction": "Create Encumbrance",
        "errorMessage": "Not enough money available in the Fund to create encumbrance",
        "details": {
          "purchaseOrderId": "#(purchaseOrderId)",
          "poLineId": "#(poLineId)",
          "polNumber": "10000-1",
          "amount": 1346.11,
          "fundId": "#(fundId)",
          "fundCode": "HIST"
        },
        "metadata": {
          "createdDate": "2020-07-19T10:00:00.000+0000",
          "createdByUserId": "28d1057c-d137-11e8-a8d5-f2801f1b9fd1"
        }
      }
    """
    When method POST
    Then status 201
