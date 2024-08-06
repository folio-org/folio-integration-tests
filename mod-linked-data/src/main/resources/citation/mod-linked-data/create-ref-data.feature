Feature: Create refrerence data

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create Instance Type referenece data
    Given path 'instance-types'
    And request
      """
      {
        "id": "3be866c2-33c4-4f8a-a0e7-654c674e8854",
        "name": "cartographic image",
        "code": "cri",
        "source": "rdacontent"
      }
      """
    When method post
    Then status 201