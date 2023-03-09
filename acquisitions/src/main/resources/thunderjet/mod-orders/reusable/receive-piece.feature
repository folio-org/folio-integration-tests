Feature: Receive piece
  # parameters: pieceId, poLineId

  Background:
    * url baseUrl

  Scenario: Receive piece
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
                  locationId: "#(globalLocationsId)",
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
