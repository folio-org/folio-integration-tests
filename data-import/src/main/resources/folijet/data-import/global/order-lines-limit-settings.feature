@ignore
Feature: Util feature for managing PO lines limit settings

  Background:
    * url baseUrl
    * def userHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }

  @setPoLinesLimit
  Scenario: Create PO lines limit setting
    # parameters: poLineLimit
    # returns: created poLines limit setting

    Given path '/orders-storage/settings'
    And headers userHeaders
    And request
      """
      {
        "key": "poLines-limit",
        "value": "#(__arg.poLineLimit)"
      }
      """
    When method POST
    Then status 201