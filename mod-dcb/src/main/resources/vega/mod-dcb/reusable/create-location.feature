Feature: Create location

  Scenario: Create location
    * url baseUrl
    Given path '/locations'
    And request
      """
      {
        "isActive": true,
        "institutionId": "#(institutionId)",
        "campusId": "#(campusId)",
        "libraryId": "#(libraryId)",
        "servicePointIds": ["#(servicePointId)"],
        "name": "#(name)",
        "code": "#(code)",
        "discoveryDisplayName": "#(name)",
        "details": {},
        "primaryServicePoint": "#(servicePointId)",
        "isShadow": #(isShadow)
      }
      """
    When method POST
    Then status 201

