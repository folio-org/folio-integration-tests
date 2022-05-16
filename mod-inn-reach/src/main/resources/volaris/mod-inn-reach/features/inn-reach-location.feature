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

  @create
  Scenario: Create inn reach location
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

    * print 'Get inn reach location by id 1'
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

    * print 'Get inn reach location by id 2'
    Given path '/inn-reach/locations', locationId2
    When method GET
    Then status 200

    * def locationResponseTwo = $
    And match locationResponseTwo.code == "plgen"
    And match locationResponseTwo.description == "GVSU Pew Library General Collection"

    Given path '/inn-reach/locations'
    When method GET
    Then status 200
    And match response.totalRecords == 2

  Scenario: Update location
    Given path '/inn-reach/locations'
    When method GET
    Then status 200
    * def location = response.locations[0]
    * def locationId = location.id
    * set location.code = "xxgec"
    * set location.description = "WV New Library General Collection"

    Given path '/inn-reach/locations', locationId
    And request location
    When method PUT
    Then status 204

    Given path '/inn-reach/locations', locationId
    When method GET
    Then status 200
    And match response.code == "xxgec"
    And match response.description == "WV New Library General Collection"

    * print 'Attempting to update location without code'
    * remove location.code
    Given path '/inn-reach/locations', locationId
    And request location
    When method PUT
    Then status 400
    And match $.validationErrors[0].fieldName == 'code'
    And match $.validationErrors[0].message == 'must not be null'
    And match $.message == 'Validation failed'

  Scenario: Create invalid inn reach location
    * print 'Create invalid inn reach location'

    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "invalid",
      "description": "Bad test library"
     }
    """
    When method POST
    Then status 400
    And match $.validationErrors[0].fieldName == 'code'
    And match $.validationErrors[0].message == 'size must be between 0 and 5'
    And match $.message == 'Validation failed'

  @delete
  Scenario: Delete
    * print 'Delete locations'
    Given path '/inn-reach/locations'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    * def id1 = get response.locations[0].id
    * def id2 = get response.locations[1].id

    Given path '/inn-reach/locations', id1
    When method DELETE
    Then status 204

    Given path '/inn-reach/locations', id2
    When method DELETE
    Then status 204

    Given path '/inn-reach/locations'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Check not existed location
    * print 'Check not existed location'
    Given path '/inn-reach/locations', notExistedLocationId
    When method GET
    Then status 404

  Scenario: Attempting to create location without code
    * configure headers = headersUser
    * print 'Attempting to create location'
    Given path 'inn-reach/locations'
    And request
    """
     {
      "description": "EU Simple Library General Collection"
     }
    """
    When method POST
    Then status 400
    And match $.validationErrors[0].fieldName == 'code'
    And match $.validationErrors[0].message == 'must not be null'
    And match $.message == 'Validation failed'

