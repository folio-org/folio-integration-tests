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
      id: 'c6dace5d-4574-411e-8ba1-036102fcdc9b',
      name: 'Test active vendor',
      code: 'testcode',
      isVendor: true,
      status: 'Active'
    }
    """
    When method POST
    Then status 201
