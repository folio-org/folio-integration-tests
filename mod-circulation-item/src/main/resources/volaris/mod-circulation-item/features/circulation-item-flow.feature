Feature: creating/updating item Scenarios

  Background:
    * url baseUrl
    * def user = testUser
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    # using global variables
    * callonce variables

  Scenario: Validate locationId exists when creating item with effectiveLocationId
    * print 'Validate locationId exists when creating item with effectiveLocationId'

    * def locationData = call read('classpath:volaris/mod-circulation-item/reusable/pre-requisites.feature@CreateDummyLocation')
    * def effectiveLocationId = locationData.response.id

    * def circulationItemId = call uuid
    * def barcode = call random_string
    * def circulationItemRequest = read('classpath:volaris/mod-circulation-item/features/samples/create-dcb-circulation-item.json')

    Given path '/circulation-item/' + circulationItemId
    And request circulationItemRequest
    When method POST
    Then status 201
    * assert response.effectiveLocationId == effectiveLocationId


  Scenario: Validate dcb default locationId is set when creating item with null effectiveLocationId
    * print 'Validate dcb default locationId is set when creating item with null effectiveLocationId'

    * print 'DCB_DEFAULT_LOCATION_ID  is: '+ DCB_DEFAULT_LOCATION_ID

    * def circulationItemId = call uuid
    * def barcode = call random_string
    * def effectiveLocationId = null
    * def circulationItemRequest = read('classpath:volaris/mod-circulation-item/features/samples/create-dcb-circulation-item.json')

    Given path '/circulation-item/' + circulationItemId
    And request circulationItemRequest
    When method POST
    Then status 201
    * assert response.effectiveLocationId == DCB_DEFAULT_LOCATION_ID


  Scenario: Validate 400 bad request when non-existed effectiveLocationId is passed
    * print 'Validate 400 bad request when non-existed effectiveLocationId is passed'

    * def circulationItemId = call uuid
    * def barcode = call random_string
    * def effectiveLocationId = 'WRONG_NO_EXISTED_LOCATION_ID'
    * def circulationItemRequest = read('classpath:volaris/mod-circulation-item/features/samples/create-dcb-circulation-item.json')

    Given path '/circulation-item/' + circulationItemId
    And request circulationItemRequest
    When method POST
    Then status 400
    And match response.errors[0].message == "EffectiveLocationId does not exist: " + effectiveLocationId

