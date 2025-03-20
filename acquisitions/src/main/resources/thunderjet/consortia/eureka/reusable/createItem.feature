Feature: Create Item

  Background:
    * url baseUrl

  Scenario: createItem
    * def itemId = call uuid
    * def id = karate.get('id', itemId)
    * def status = karate.get('status', 'Available')
    Given path 'inventory/items'
    And request
    """
    {
      "id": "#(id)",
      "holdingsRecordId": "#(holdingId)",
      "barcode": "#(barcode)",
      "status": {
        "name": "#(status)"
      },
      "materialType": {
        "id": "#(materialTypeId)"
      },
      "permanentLoanType": {
        "id": "#(permanentLoanTypeId)"
      },
      "permanentLocation": {
        "id": "#(permanentLocationId)"
      }
    }
    """
    When method POST
    Then status 201
