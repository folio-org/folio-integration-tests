Feature: create test data

  Background:


  * configure headers = headersUser

  # Define variables :
  * def readOnlyAcqUnitId = '30265507-a5b2-4d97-a498-18d632cfe27b'
  * def updateOnlyAcqUnitId = '1cf370b6-0002-4195-be6f-413c601d8fcc'
  * def fullProtectedAcqUnitId = 'c80a3df72-6a89-41fb-b59f-4cbaca30c926'
  * def noAcqOrganizationId = 'b5f7b950-b49e-424a-82dc-c0b3dacb49db'

  Scenario: Create read-open acquisitions unit
    Given path '/acquisitions-units-storage/units'
    And request
  """
      {
        id: '#(readOnlyAcqUnitId)'
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
        id: '#(updateOnlyAcqUnitId)'
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
        id: '#(fullProtectedAcqUnitId)'
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
  Given path '/organizations'
  And request
  """
      {
        id: '#(noAcqOrganizationId)'
        name: 'Active org for API Test',
        status: 'Active',
        code: 'NO_ACQ_ORG'
      }
  """
  When method POST
  Then status 201

  Scenario: Create read-open org
    Given path '/organizations'
    And request
  """
      {
        name: '"Active org for API Test"',
        status: 'Active',
        code: 'READ_ONLY_ORG',
        acqUnitIds: '#(readOnlyAcqUnitId)'
      }
  """
    When method POST
    Then status 201

  Scenario: Create update-open org
    Given path '/organizations'
    And request
  """
      {
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'UPDATE_ONLY_ORG',
        acqUnitIds: '#(updateOnlyAcqUnitId)'
      }
  """
    When method POST
    Then status 201

  Scenario: Create full-protected org
    Given path '/organizations'
    And request
  """
      {
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'FULL_PROTECTED_ORG',
        acqUnitIds: '#(fullProtectedAcqUnitId)'
      }
  """
    When method POST
    Then status 201