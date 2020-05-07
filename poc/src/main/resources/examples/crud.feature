Feature: CRUD example

  Background:
    * url 'http://localhost:9130'
    * def admin = { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * call login admin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

  Scenario: create fiscal year POST example
    Given path 'finance/fiscal-years'
    And request
    """
    {
        "id": '1477d5b9-0818-4c34-86d7-45b81b8cca61',
        "code": 'testcode2029',
        "name": "Test fiscal year",
        "periodStart": "2019-01-01T00:00:00Z",
        "periodEnd": "2025-12-30T23:59:59Z"
    }
    """
    When method POST
    Then status 201

  Scenario: Get fiscal year example
    Given path 'finance/fiscal-years', '1477d5b9-0818-4c34-86d7-45b81b8cca61'
    When method GET
    Then status 200
    And match response.code == 'testcode2029'

  Scenario: Update fiscal year example
    Given path 'finance/fiscal-years', '1477d5b9-0818-4c34-86d7-45b81b8cca61'
    And request
    """
    {
        "code": 'testcode2030',
        "name": "Test fiscal year",
        "periodStart": "2019-01-01T00:00:00Z",
        "periodEnd": "2025-12-30T23:59:59Z"
    }
    """
    When method PUT
    Then status 204

    # check that code has been updated
    Given path 'finance/fiscal-years', '1477d5b9-0818-4c34-86d7-45b81b8cca61'
    When method GET
    Then status 200
    And match response.code == 'testcode2030'

  Scenario: Delete fiscal year example
    Given path 'finance/fiscal-years', '1477d5b9-0818-4c34-86d7-45b81b8cca61'
    When method DELETE
    Then status 204
