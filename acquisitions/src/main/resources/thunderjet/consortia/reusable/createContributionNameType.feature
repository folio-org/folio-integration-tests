Feature:

  Background:
    * url baseUrl

  Scenario: create instance contributor name types
    Given path 'contributor-name-types'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json, text/plain'
    And request
      """
      {
        "id": "#(id)",
        "name": "#(name)"
      }
      """
    When method POST
    Then status 201