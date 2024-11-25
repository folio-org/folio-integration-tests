@ignore
Feature: Create Organization
  # parameters: id?, name?, code, status? acqUnitIds?

  Background:
    * url baseUrl

  Scenario: createOrganization
    * def newId = callonce uuid
    * def id = karate.get('id', newId)
    * def name = karate.get('name', 'Active org for API Test')
    * def status = karate.get('status', 'Active')
    * def acqUnitIds = karate.get('acqUnitIds', [])
    Given path 'organizations/organizations'
    And request
      """
      {
        id: '#(id)',
        name: '#(name)',
        status: '#(status)',
        code: '#(code)',
        acqUnitIds: '#(acqUnitIds)'
      }
      """
    When method POST
    Then status 201
