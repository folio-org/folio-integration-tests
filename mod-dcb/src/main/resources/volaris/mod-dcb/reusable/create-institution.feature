Feature: Create institution

  Scenario: Create institution
    * url baseUrl
    Given path '/location-units/institutions'
    And request { name: '#(name)', code: '#(code)', isShadow: #(isShadow) }
    When method POST
    Then status 201

