Feature: create test data

  Background:
   * url baseUrl
   * callonce loginAdmin testAdmin
   * def okapitokenAdmin = okapitoken
   * callonce loginRegularUser testUser
   * def okapitokenUser = okapitoken

   * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
   * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*' }

   * configure headers = headersUser

   # Load global variables:
   * callonce variables


   # Define variables :
   * def readOnlyAcqUnitId = 'fdf31bcb-ffd2-5142-adac-8b0cc1c262f6'
   * def updateOnlyAcqUnitId = 'fdf31bcb-ffd2-5142-adac-8b0cc1c262f7'
   * def fullProtectedAcqUnitId = 'fdf31bcb-ffd2-5142-adac-8b0cc1c262f8'
   * def noAcqOrganizationId = 'fdf31bcb-ffd2-5142-adac-8b0cc1c262f9'

  Scenario: Create read-open acquisitions unit
    Given path '/acquisitions-units-storage/units'
    And request
  """
      {
        id: '#(readOnlyAcqUnitId)',
        name: 'read only',
        isDeleted: false,
        protectCreate: true,
        protectRead: false,
        protectUpdate: true,
        protectDelete: true
      }
  """
    When method POST
    Then status 201

  Scenario: Create update-open acquisitions unit
    Given path '/acquisitions-units-storage/units'
    And request
  """
      {
        id: '#(updateOnlyAcqUnitId)',
        name: 'update only',
        isDeleted: false,
        protectCreate: true,
        protectRead: true,
        protectUpdate: false,
        protectDelete: true
      }
  """
    When method POST
    Then status 201

  Scenario: Create full-protected acquisitions unit
    Given path '/acquisitions-units-storage/units'
    And request
  """
      {
        id: '#(fullProtectedAcqUnitId)',
        name: 'full protected',
        isDeleted: false,
        protectCreate: true,
        protectRead: true,
        protectUpdate: true,
        protectDelete: true
      }
  """
    When method POST
    Then status 201

  Scenario: Create no-acq org
  Given path '/organizations/organizations'
  And request
  """
      {
        id: '#(noAcqOrganizationId)',
        name: 'Active org for API Test',
        status: 'Active',
        code: 'NO_ACQ_ORG'
      }
  """
  When method POST
  Then status 201

  Scenario: Create read-open org
    Given path '/organizations/organizations'
    And request
  """
      {
        name: '"Active org for API Test"',
        status: 'Active',
        code: 'READ_ONLY_ORG',
        acqUnitIds: ['#(readOnlyAcqUnitId)']
      }
  """
    When method POST
    Then status 201

  Scenario: Create update-open org
    Given path '/organizations/organizations'
    And request
  """
      {
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'UPDATE_ONLY_ORG',
        acqUnitIds: ['#(updateOnlyAcqUnitId)']
      }
  """
    When method POST
    Then status 201

  Scenario: Create full-protected org
    Given path '/organizations/organizations'
    And request
  """
      {
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'FULL_PROTECTED_ORG',
        acqUnitIds: ['#(fullProtectedAcqUnitId)']
      }
  """
    When method POST
    Then status 201