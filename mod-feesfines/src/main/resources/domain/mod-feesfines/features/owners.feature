Feature: Fee/fine owners

  Background:
    * url baseUrl
    * def admin = { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * call login admin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get non-existent fee/fine owner
    Given path 'owners', '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'
    When method GET
    Then status 404

  Scenario: Create a fee/fine owner
    Given path 'owners'
    And request
    """
    {
      "owner": "Folio Tester",
      "desc": "Test owner",
      "id": "20fb8c3c-5a95-4272-b1e6-7d8ad35868dd"
    }
    """
    When method POST
    Then status 201
    # verify that metadata was added to owner record
    And match $.metadata == '#notnull'

  Scenario: Get fee/fine owner
    Given path 'owners', '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'
    When method GET
    Then status 200
    And match $.id == '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'

  Scenario: Update fee/fine owner
    Given path 'owners', '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'
    And request
    """
    {
      "owner": "Folio Tester",
      "desc": "Test owner - updated",
      "id": "20fb8c3c-5a95-4272-b1e6-7d8ad35868dd"
    }
    """
    When method PUT
    Then status 204

    # verify that owner description was updated
    Given path 'owners', '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'
    When method GET
    Then match $.desc == 'Test owner - updated'

  Scenario: Delete fee/fine owner
    Given path 'owners', '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'
    When method DELETE
    Then status 204