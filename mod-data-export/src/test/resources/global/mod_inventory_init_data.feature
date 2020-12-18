Feature: init data for mod-configuration

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  Scenario: create instance type
    Given path 'instance-types'
    And header x-okapi-token = okapitokenAdmin
    And request
    """
     {
          "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
          "name": "still image",
          "code": "sti",
          "source": "rdacarrier"
      }
    """
    When method POST
    Then status 201

  Scenario: create instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:samples/instance.json')
    And request instance
    When method POST
    Then status 201