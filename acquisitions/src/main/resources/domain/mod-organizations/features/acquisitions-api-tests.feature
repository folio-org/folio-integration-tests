Feature: Organizations API tests.

  Background:
    * url baseUrl

    # uncomment below line for development
    #* callonce dev {tenant: 'test_mod_organizations'}

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * print okapitokenAdmin

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

#    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
#    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*' }

    * configure headers = headersUser

    # Load global variables:
    * callonce variables

    # Define variables:
#    * def readOnlyAcqUnitId = '30265507-a5b2-4d97-a498-18d632cfe27b'
#    * def updateOnlyAcqUnitId = '1cf370b6-0002-4195-be6f-413c601d8fcc'
#    * def fullProtectedAcqUnitId = '043a8281-c0c9-47d6-b581-8105da0a8cd1'
#
#    * def noAcqOrganizationId = 'b5f7b950-b49e-424a-82dc-c0b3dacb49db'
#    * def readOnlyOrganizationId = '11f9f095-ac96-49b9-9c3a-6d387672301f'
#    * def updateOnlyOrganizationId = '1966795b-6637-4aa4-a6ca-26b59abfbe30'
#    * def fullProtectedOrganizationId = '4a183bbf-4e44-4f31-aff3-875aac921247'

    * def readOnlyAcqUnitId = callonce uuid1
    * def updateOnlyAcqUnitId = callonce uuid2
    * def fullProtectedAcqUnitId = callonce uuid3

    * def noAcqOrganizationId = callonce uuid4
    * def readOnlyOrganizationId = callonce uuid5
    * def updateOnlyOrganizationId = callonce uuid6
    * def fullProtectedOrganizationId = callonce uuid7

  # --- Create test data section start ---

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
        id: '#(readOnlyOrganizationId)',
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
        id: '#(updateOnlyOrganizationId)',
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
        id: '#(fullProtectedOrganizationId)',
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'FULL_PROTECTED_ORG',
        acqUnitIds: ['#(fullProtectedAcqUnitId)']
      }
  """
    When method POST
    Then status 201

  # --- Create test data section end ---

  # --- Create API test(s) section start ---

  Scenario: Get not protected org
    Given path '/organizations/organizations/', noAcqOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(noAcqOrganizationId)'

  Scenario: Get read-open org
    Given path '/organizations/organizations/', readOnlyOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(readOnlyOrganizationId)'

  Scenario: Get full-protected org - receive forbidden status
    Given path '/organizations/organizations/', fullProtectedOrganizationId
    When method GET
    Then status 403

  Scenario: Get all organizations before assign any units to user
    Given path '/organizations/organizations'
    When method GET
    Then status 200
    And match $.totalRecords == 2


  Scenario: Assign user to read-open unit
    * configure headers = headersAdmin
    Given path '/users'
    And param query = 'username=test-user'
    When method GET
    Then status 200
    * def userId = $.users[0].id
    * print userId

    Given path '/acquisitions-units-storage/memberships'
    And request
  """
      {
        userId: '#(userId)',
        acquisitionsUnitId: '#(readOnlyAcqUnitId)'
      }
  """
    When method POST
    Then status 201

  Scenario: Get not protected org
    Given path '/organizations/organizations/', noAcqOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(noAcqOrganizationId)'

  Scenario: Get read-open org
    Given path '/organizations/organizations/', readOnlyOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(readOnlyOrganizationId)'

  Scenario: Get full-protected org - receive forbidden status
    Given path '/organizations/organizations/', fullProtectedOrganizationId
    When method GET
    Then status 403

  Scenario: Get all organizations after assign read only protected units to user
    Given path '/organizations/organizations'
    When method GET
    Then status 200
    And match $.totalRecords == 2


  Scenario: Assign user to read-open unit
    * configure headers = headersAdmin
    Given path '/users'
    And param query = 'username=test-user'
    When method GET
    Then status 200
    * def userId = $.users[0].id
    * print userId

    Given path '/acquisitions-units-storage/memberships'
    And request
  """
      {
        userId: '#(userId)',
        acquisitionsUnitId: '#(readOnlyAcqUnitId)'
      }
  """
    When method POST
    Then status 201

  Scenario: Assign user to full-protected unit
    * configure headers = headersAdmin
    Given path '/users'
    And param query = 'username=test-user'
    When method GET
    Then status 200
    * def userId = $.users[0].id
    * print userId

    Given path '/acquisitions-units-storage/memberships'
    And request
  """
      {
        userId: '#(userId)',
        acquisitionsUnitId: '#(readOnlyAcqUnitId)'
      }
  """
    When method POST
    Then status 201
    * def acqMembershipId = $.id
    * print acqMembershipId

    Given path '/acquisitions-units-storage/memberships/', acqMembershipId
    And request
  """
      {
        id: '#(acqMembershipId)',
        userId: '#(userId)',
        acquisitionsUnitId: '#(fullProtectedAcqUnitId)'
      }
  """
    When method PUT
    Then status 204

  Scenario: Get not protected org
    Given path '/organizations/organizations/', noAcqOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(noAcqOrganizationId)'

  Scenario: Get read-open org
    Given path '/organizations/organizations/', readOnlyOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(readOnlyOrganizationId)'

  Scenario: Get full-protected org
    Given path '/organizations/organizations/', fullProtectedOrganizationId
    When method GET
    Then status 200

  Scenario: Get all organizations after assign full protected units to user
    Given path '/organizations/organizations'
    When method GET
    Then status 200
    And match $.totalRecords == 3

  # --- Create API test(s) section end ---
