Feature: Consortium object in mod-consortia api tests

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  Scenario: Create, Read, Update a consortium for positive cases
    * def consortiumName = 'Consortium name for test'

    # create a consortium
    Given path '/consortia'
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }
