Feature: Create Organization
  # parameters: id?, name, code, status?

  Background:
    * url baseUrl

  Scenario: createOrganization
    * def newId = callonce uuid
    * def id = karage.get('id', orgId)
    * def status = karage.get('status', 'Active')
    Given path 'organizations/organizations'
    And request
      """
      {
        id: '#(id)',
        name: '#(name)',
        status: '#(status)',
        code: '#(code)',
      }
      """
    When method POST
    Then status 201
