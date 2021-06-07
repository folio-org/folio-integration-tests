Feature: init data for inventory
  Background:
    * url baseUrl
    * configure headers = baseHeaders

  Scenario: Create inventory instances
    Given path '/instance-storage/batch/synchronous'
    And request read('samples/instances.json')
    When method POST
    Then status 201
    # Wait to let mod-search add instances to index
    Then call pause(1500)