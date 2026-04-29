Feature: Reinstall FQM entity types for cross-tenant consortia tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000

  @Positive
  Scenario: Initialize FQM entity types with ECS-aware source views
    # Re-install after consortia configuration exists so ECS-aware source views use the real central tenant ID.
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    Given path 'entity-types', 'install'
    And param forceRecreateViews = true
    When method POST
    Then status 204

    * call login universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }
    Given path 'entity-types', 'install'
    And param forceRecreateViews = true
    When method POST
    Then status 204

    * call login collegeUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json' }
    Given path 'entity-types', 'install'
    And param forceRecreateViews = true
    When method POST
    Then status 204
