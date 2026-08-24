@parallel=false
Feature: Inn reach location

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testinnreachintegration1'}
#    * callonce login testAdmin
#    * def okapitokenAdmin = okapitoken

    * def proxyCall = karate.get('proxyCall', false)
    * def totalLocations = karate.get('locations', 2)
    * print 'proxyCall', proxyCall
    * def user = proxyCall == false ? testUser : testUserEdge

    * callonce login user
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)',  'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
#    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * def notExistedLocationId = callonce uuid1

  @create
  Scenario: Create inn reach location
    * print 'Create inn reach location 1'
    * def code1 = random_string()
    * def desc1 = "Steelcase Design Library" + random_string()
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "#(code1)",
      "description": "#(desc1)"
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
    And match locationResponseOne.code == code1
    And match locationResponseOne.description == desc1

    * print 'Create inn reach location 2'
    * def code2 = random_string()
    * def desc2 = "Steelcase Design Library" + random_string()
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "#(code2)",
      "description": "#(desc2)"
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
    And match locationResponseTwo.code == code2
    And match locationResponseTwo.description == desc2

    Given path '/inn-reach/locations'
    * param limit = 100000
    When method GET
    Then status 200
    * def response = $
    * def codes = get response.locations[*].code
    * def descriptions = get response.locations[*].description
    And match codes contains code1
    And match codes contains code2
    And match descriptions contains desc1
    And match descriptions contains desc2

  Scenario: Update location
    * def code1 = random_string()
    * def desc1 = "Steelcase Design Library" + random_string()
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "#(code1)",
      "description": "#(desc1)"
     }
    """
    When method POST
    Then status 201
    * def locationId = $.id

    Given path '/inn-reach/locations', locationId
    When method GET
    Then status 200
    * def location = response
    * def code2 = random_string()
    * def desc2 = "Steelcase Design Library" + random_string()
    * set location.code = code2
    * set location.description = desc2

    Given path '/inn-reach/locations', locationId
    And request location
    When method PUT
    Then status 204

    Given path '/inn-reach/locations', locationId
    When method GET
    Then status 200
    And match response.code == code2
    And match response.description == desc2

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
    * print 'Create inn reach location 1'
    * def code1 = random_string()
    * def desc1 = "SteelCase_Design_Library" + random_string()
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "#(code1)",
      "description": "#(desc1)"
     }
    """
    When method POST
    Then status 201
    * def locationId1 = $.id

    * print 'Get inn reach location by id 1'
    Given path '/inn-reach/locations', locationId1
    When method GET
    Then status 200

    * print 'Delete locations'
    Given path '/inn-reach/locations', locationId1
    When method DELETE
    Then status 204

    * print 'Get inn reach location by id 1'
    Given path '/inn-reach/locations', locationId1
    When method GET
    Then status 404

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