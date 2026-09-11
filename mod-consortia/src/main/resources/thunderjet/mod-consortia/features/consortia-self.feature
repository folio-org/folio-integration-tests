Feature: Consortia _self endpoint access control tests

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * def selfHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

  @Negative
  Scenario: unauthenticated request to consortia _self returns 401
    Given path 'consortia', consortiumId, '_self'
    And header x-okapi-tenant = centralTenant
    And header x-okapi-user-id = centralUser1.id
    When method GET
    Then status 401

  @Positive
  Scenario: authenticated request to consortia _self returns current user consortium context
    * configure headers = selfHeaders
    Given path 'consortia', consortiumId, '_self'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.userTenants != null
