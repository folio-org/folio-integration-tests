Feature: Consortium object in api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }
    * configure headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

  @SetupConsortia
  Scenario: Create a consortia
    * def consortiumName = tenant +  'name for test'

    # create a consortia
    Given path 'consortia'
    And headers { 'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)' }
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }

#  @EnableCentralOrdering
#  Scenario: Enable central ordering for a consortium
#    Given path '/orders-storage/settings'
#    And headers { 'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)' }
#    And request { key: 'ALLOW_ORDERING_WITH_AFFILIATED_LOCATIONS', value: 'true' }
#    When method POST
#    Then status 201