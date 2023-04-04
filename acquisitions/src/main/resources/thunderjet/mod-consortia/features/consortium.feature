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

  Scenario: Create, Read, Update a consortium

    # Post consortium
    Given path '/consortia'
    And request
    """
    {
      id: '111841e3-e6fb-4191-8fd8-5674a5107c32',
      name: 'Test'
    }
    """
    When method POST
    Then status 201

    #Get consortiums
    Given path '/consortia'
    When method GET
    Then status 200
    And match response == { consortia: '#present', totalRecords: '#present' }
    And match response.consortia[0] == { id: '#present', name: '#present' }

    # Get consortium
    Given path '/consortia/111841e3-e6fb-4191-8fd8-5674a5107c32'
    When method GET
    Then status 200
    And match response == { id: '#present', name: '#present' }

    # Put consortium
    Given path '/consortia/111841e3-e6fb-4191-8fd8-5674a5107c32'
    And request
    """
    {
      id: '111841e3-e6fb-4191-8fd8-5674a5107c32',
      name: 'Test2'
    }
    """
    When method PUT
    Then status 200

    # Get Error while trying to create a consortium
    Given path '/consortia'
    And request
    """
    {
      id: '111841e3-e6fb-4191-8fd8-5674a5107c32',
      name: 'Test'
    }
    """
    When method POST
    Then status 409
    And match response == {"errors":[{"message":"System can not have more than one consortium record","type":"-1","code":"DUPLICATE_ERROR"}]}

