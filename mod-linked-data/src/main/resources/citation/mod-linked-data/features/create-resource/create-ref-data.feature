Feature: Create refrerence data

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create Instance Type
    Given path 'instance-types'
    And request
      """
      {
        "id": "fe19bae4-da28-472b-be90-d442e2428ead",
        "name": "cartographic image",
        "code": "cri",
        "source": "rdacontent"
      }
      """
    When method post
    Then status 201