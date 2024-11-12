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
        "id": "526aa04d-9289-4511-8866-349299592c18",
        "name": "cartographic image",
        "code": "cri",
        "source": "rdacontent"
      }
      """
    When method post
    Then status 201