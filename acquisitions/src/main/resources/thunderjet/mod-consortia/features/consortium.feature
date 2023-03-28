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
      id: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      name: 'Test'
    }
    """
    When method POST
    Then status 200
    Then print '\n' , response

    #Get consortiums
    Given path '/consortia'
    When method GET
    Then status 200
    And match response == { consortia: '#present', totalRecords: '#present' }
    And match response.consortia[0] == { id: '#present', name: '#present' }
    Then print '\n' , response

    # Get consortium
    Given path '/consortia/111841e3-e6fb-4191-8fd8-5674a5107c33'
    When method GET
    Then status 200
    And match response == { id: '#present', name: '#present' }
    Then print '\n' , response

    # Put consortium
    Given path '/consortia/111841e3-e6fb-4191-8fd8-5674a5107c33'
    And request
    """
    {
      id: '111841e3-e6fb-4191-8fd8-5674a5107c33',
      name: 'Test2'
    }
    """
    When method PUT
    Then status 200
    Then print '\n' , response

