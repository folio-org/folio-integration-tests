Feature:

  Background:
    * url baseUrl
    * configure cookies = null
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant':'#(testTenant)' }
    * configure headers = headersAdmin

  Scenario: Get user's id by its username
    Given path 'users'
    And param limit = 1000
    And param query = '(username=="' + user.name + '")'
    When method GET
    Then status 200
    * def userId = response.users[0].id