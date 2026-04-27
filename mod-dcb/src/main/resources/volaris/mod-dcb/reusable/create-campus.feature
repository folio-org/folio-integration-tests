Feature: Create campus

  Scenario: Create campus
    * url baseUrl
    Given path '/location-units/campuses'
    And request { name: '#(name)', code: '#(code)', institutionId: '#(institutionId)', isShadow: #(isShadow) }
    When method POST
    Then status 201

