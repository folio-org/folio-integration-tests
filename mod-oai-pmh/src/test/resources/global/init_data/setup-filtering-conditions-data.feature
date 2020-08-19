Feature: creates required entities within inventory storage which is used for building /oai-pmh/filtering-conditions response

  Background:
    * url baseUrl

  Scenario: Creates 'ill-policy' entity which takes part into building filtering-conditions values response.
    Given path '/ill-policies'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def illPolicy = read('classpath:samples/filtering-conditions/illPolicies.json')
    And request illPolicy
    When method POST
    Then status 201

  Scenario: Creates 'instance type' entity which takes part into building filtering-conditions values response.
    Given path '/instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def instanceType = read('classpath:samples/filtering-conditions/instanceTypes.json')
    And request instanceType
    When method POST
    Then status 201

  Scenario: Creates 'instance format' entity which takes part into building filtering-conditions values response.
    Given path '/instance-formats'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def instanceFormat = read('classpath:samples/filtering-conditions/instanceFormats.json')
    And request instanceFormat
    When method POST
    Then status 201

  Scenario: Creates 'institution' entity which is required for creating the both 'location' and 'campus' entities.
    Given path '/location-units/institutions'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def institution = read('classpath:samples/filtering-conditions/locationUnit-institution.json')
    And request institution
    When method POST
    Then status 201

  Scenario: Creates 'campus' entity which is required for creating the 'location' entity.
    Given path '/location-units/campuses'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def campus = read('classpath:samples/filtering-conditions/locationUnit-campus.json')
    And request campus
    When method POST
    Then status 201

  Scenario: Creates 'library' entity which is required for creating the 'location' entity.
    Given path '/location-units/libraries'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def library = read('classpath:samples/filtering-conditions/locationUnit-library.json')
    And request library
    When method POST
    Then status 201

  Scenario: Creates 'service point' entity which is required for creating the 'location' entity.
    Given path '/service-points'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def servicePoint = read('classpath:samples/filtering-conditions/location-servicePoint.json')
    And request servicePoint
    When method POST
    Then status 201

  Scenario: Creates 'location' entity which takes part into building filtering-conditions values response.
    Given path '/locations'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def location = read('classpath:samples/filtering-conditions/locations.json')
    And request location
    When method POST
    Then status 201

  Scenario: Creates 'material type' entity which takes part into building filtering-conditions values response.
    Given path '/material-types'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def materialType = read('classpath:samples/filtering-conditions/materialTypes.json')
    And request materialType
    When method POST
    Then status 201
