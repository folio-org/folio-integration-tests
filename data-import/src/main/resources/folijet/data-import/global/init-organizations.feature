Feature: global organizations

  Background:
    * url baseUrl

  Scenario: create vendor
    Given path 'organizations-storage/organizations'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      id: 'd0fb5aa0-cdf1-11e8-a8d5-f2801f1b9fd1',
      name: 'Test vendor',
      code: 'testcode',
      isVendor: true,
      status: 'Active'
    }
    """
    When method POST
    Then status 201