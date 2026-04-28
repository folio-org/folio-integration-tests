Feature: Create library

  Scenario: Create library
    * url baseUrl
    Given path '/location-units/libraries'
    And request { name: '#(name)', code: '#(code)', campusId: '#(campusId)', isShadow: #(isShadow) }
    When method POST
    Then status 201

