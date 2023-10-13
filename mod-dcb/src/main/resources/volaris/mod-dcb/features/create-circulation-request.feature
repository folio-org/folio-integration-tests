Feature: Testing Create circulation request

  Background:
    * url baseUrl
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Testing Create circulation request
    * def dcbTransactionId = '123456891'

    Given url edgeUrl
    Given path '/transactions/' + dcbTransactionId
    And request
    """
    {
      "item": {
        "id": "e2325f58-e757-43c6-a761-de634f075f71",
        "title": "Test",
        "barcode": "newdcb123",
        "pickupLocation": "Datalogisk Institut",
        "materialType": "book",
        "lendingLibraryCode": "KU"
    },
      "patron": {
          "id": "7e905a99-11ba-47b1-9d13-da0f0b108212",
          "group": "staff",
          "barcode": "11111",
          "borrowingLibraryCode": "E"
     },
    "role": "LENDER"
    }
    """
    When method POST
    Then status 201




