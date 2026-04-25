Feature: Base URL operations for linked-data

  Background:
    * url baseUrl
    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testAdminHeaders

  @putBaseUrl
  Scenario: Configure FOLIO front-end base URL
    Given path 'base-url'
    And request
      """
      {
        "baseUrl": "#(foliioUiUrl)"
      }
      """
    When method PUT
    * assert responseStatus == 201
