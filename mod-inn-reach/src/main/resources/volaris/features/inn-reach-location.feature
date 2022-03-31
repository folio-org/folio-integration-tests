@parallel=false
Feature: Inn reach location

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_inn_reach_integration1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * def notExistedLocationId = callonce uuid1

  Scenario: Create inn reach location
    * configure headers = headersUser
    * print 'Create inn reach location 1'
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "scdes",
      "description": "Steelcase Design Library"
     }
    """
    When method POST
    Then status 201
    * def locationId1 = $.id

    * print 'Get central server by id 1'
    Given path '/inn-reach/locations', locationId1
    When method GET
    Then status 200

    * def locationResponseOne = $
    And match locationResponseOne.code == "scdes"
    And match locationResponseOne.description == "Steelcase Design Library"

    * print 'Create inn reach location 2'
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "plgen",
      "description": "GVSU Pew Library General Collection"
     }
    """
    When method POST
    Then status 201
    * def locationId2 = $.id

    * print 'Get central server by id 2'
    Given path '/inn-reach/locations', locationId2
    When method GET
    Then status 200

    * def locationResponseTwo = $
    And match locationResponseTwo.code == "plgen"
    And match locationResponseTwo.description == "GVSU Pew Library General Collection"

  Scenario: Get locations
    * print 'Get locations'
    * configure headers = headersUser
    Given path '/inn-reach/locations'
    When method GET
    Then status 200
    And match response.totalRecords == 2

  Scenario: Check not existed location
    * configure headers = headersUser
    * print 'Check not existed location'
    Given path '/inn-reach/locations', notExistedLocationId
    When method GET
    Then status 404

  Scenario: Update location
    * configure headers = headersUser
    * print 'Update location'
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "ongen",
      "description": "GVSU Steelcase Library General Collection"
     }
    """
    When method POST
    Then status 201
    * def locationId = $.id

    Given path '/inn-reach/locations', locationId
    When method GET
    Then status 200
    * def locationResponseBefore = $
    * set locationResponseBefore.code = "xxgen"
    * set locationResponseBefore.description = "WV New Library General Collection"

    Given path '/inn-reach/locations', locationId
    And request locationResponseBefore
    When method PUT
    Then status 204

    Given path '/inn-reach/locations', locationId
    When method GET
    Then status 200
    * def locationResponseAfter = $
    * set locationResponseAfter.code = "xxgen"
    * set locationResponseAfter.code = "WV New Library General Collection"

  Scenario: Delete location
    * configure headers = headersUser
    * print 'Delete location'
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "eugen",
      "description": "EU Simple Library General Collection"
     }
    """
    When method POST
    Then status 201
    * def locationId = $.id

    Given path '/inn-reach/locations', locationId
    When method GET
    Then status 200
    * def locationResponseBefore = $
    * set locationResponseBefore.code = "eugen"
    * set locationResponseBefore.description = "EU Simple Library General Collection"

    Given path '/inn-reach/locations', locationId
    When method DELETE
    Then status 204
