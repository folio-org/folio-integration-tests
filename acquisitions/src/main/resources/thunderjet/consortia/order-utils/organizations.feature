Feature: Global organizations

  Background:
    * url baseUrl

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }

    * callonce variablesCentral

  Scenario: Create vendor
    Given path 'organizations/organizations'
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

  Scenario: Create organization which is not a vendor
    Given path 'organizations/organizations'
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
