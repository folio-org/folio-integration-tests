Feature: Consortium object in mod-consortia api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure retry = { count: 6, interval: 20000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  Scenario: Create, Read, Update a consortium for positive cases
    * def consortiumName = 'Consortium name for test'

    # create a consortium
    Given path '/consortia'
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }
