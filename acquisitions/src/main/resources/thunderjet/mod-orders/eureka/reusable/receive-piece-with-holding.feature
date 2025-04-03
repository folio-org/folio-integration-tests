@ignore
Feature: Receive piece with Holding ID
  # parameters: pieceId, poLineId, holdingId

  Background:
    * url baseUrl

  Scenario: Receive piece with Holding ID
    * def holdingId = karate.get('holdingId', globalHoldingId1)
    * def tenantId = karate.get('tenantId', null)
    Given path 'orders/check-in'
    And request
    """
      {
        toBeCheckedIn: [
          {
            checkedIn: 1,
            checkInPieces: [
              {
                id: "#(pieceId)",
                itemStatus: "In process",
                displayOnHolding: false,
                enumeration: "#(pieceId)",
                chronology: "#(pieceId)",
                supplement: true,
                discoverySuppress: true,
                holdingId: "#(holdingId)",
                receivingTenantId: "#(tenantId)",
                createItem: "true"
              }
            ],
            poLineId: "#(poLineId)"
          }
        ],
        totalRecords: 1
      }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1
