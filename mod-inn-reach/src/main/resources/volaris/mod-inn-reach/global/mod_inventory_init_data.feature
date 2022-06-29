Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  Scenario: create instance
    * def instanceId = '601a8dc4-dee7-48eb-b03f-d02fdf0debd0'
    * def snapshotId = uuid()

    * call read(globalPath + 'mod_srs_init_data.feature@PostSnapshot')
    * call read(globalPath + 'mod_srs_init_data.feature@PostMarcBibRecord')

    Given path '/instance-storage/instances'
    And request read(samplesPath + 'inventory/instance.json')
    When method POST
    Then status 201
