Feature: Consortium object in mod-consortia api tests

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  @CreateConsortium
  Scenario: Create, Read, Update a consortium for positive cases
    * def consortiumName = 'Consortium name for test'

    # create a consortium
    Given path '/consortia'
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }

  @EnableCentralOrdering
  Scenario: Enable central ordering for a consortium
    Given path '/orders-storage/settings'
    And request { key: 'ALLOW_ORDERING_WITH_AFFILIATED_LOCATIONS', value: 'true' }
    When method POST
    Then status 201