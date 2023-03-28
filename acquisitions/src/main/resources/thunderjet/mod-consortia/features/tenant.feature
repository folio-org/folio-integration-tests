Feature: Consortium object in mod-consortia api tests

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

  Scenario: Create, Read, Update a tenant

    # Create a tenant
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants'
    And request { "id": "1234", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method POST
    Then status 200
    And match response == { "id": "1234", "name": "test" }

    # Update a tenant
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c32', 'tenants', '1234'
    And request { "id": "1234", "name": "test", "consortiumId": "111841e3-e6fb-4191-8fd8-5674a5107c32" }
    When method PUT
    Then status 200
    And match response == { "id": "1234", "name": "test" }