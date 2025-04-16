Feature: global organizations

  Background:
    * url baseUrl
    * callonce variablesCentral

  Scenario: create vendor
    Given path 'organizations-storage/organizations'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = tenantName
    And request
    """
    {
      id: '#(centralVendorId)',
      name: 'Test active vendor',
      code: 'testcode',
      isVendor: true,
      status: 'Active'
    }
    """
    When method POST
    Then status 201

  Scenario: create organization which is not a vendor
    Given path 'organizations-storage/organizations'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = tenantName
    And request
    """
    {
      id: '#(centralOrgIsNotVendorId)',
      name: 'Org is not vendor',
      code: 'OrgIsNotVendor',
      isVendor: false,
      status: 'Active'
    }
    """
    When method POST
    Then status 201
