Feature: Organizations API tests.

  Background:
    * url baseUrl

    # uncomment below line for development
    #* callonce dev {tenant: 'testmodorgs'}

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*' }

    * configure headers = headersUser
    * callonce variables

    * def readOnlyAcqUnitId = callonce uuid1
    * def updateOnlyAcqUnitId = callonce uuid2
    * def fullProtectedAcqUnitId = callonce uuid3
    * table acqUnitsData
      | id                     | name             | isDeleted | protectRead | protectCreate | protectUpdate | protectDelete |
      | readOnlyAcqUnitId      | 'read only'      | false     | false       | true          | true          | true          |
      | updateOnlyAcqUnitId    | 'update only'    | false     | true        | true          | false         | true          |
      | fullProtectedAcqUnitId | 'full protected' | false     | true        | true          | true          | true          |
    * def v = callonce createAcqUnit acqUnitsData


    * def noAcqOrganizationId = callonce uuid4
    * def readOnlyOrganizationId = callonce uuid5
    * def updateOnlyOrganizationId = callonce uuid6
    * def fullProtectedOrganizationId = callonce uuid7
    * def notUniqueAccountOrganizationId = callonce uuid8
    * table organizationsData
      | id                          | code                 | status   | acqUnitIds                    |
      | noAcqOrganizationId         | 'NO_ACQ_ORG'         | 'Active' | []                            |
      | readOnlyOrganizationId      | 'READ_ONLY_ORG'      | 'Active' | ['#(readOnlyAcqUnitId)']      |
      | updateOnlyOrganizationId    | 'UPDATE_ONLY_ORG'    | 'Active' | ['#(updateOnlyAcqUnitId)']    |
      | fullProtectedOrganizationId | 'FULL_PROTECTED_ORG' | 'Active' | ['#(fullProtectedAcqUnitId)'] |
    * def v = callonce createOrganization organizationsData

  @Positive
  Scenario: Get not protected org
    Given path '/organizations/organizations/', noAcqOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(noAcqOrganizationId)'

  @Positive
  Scenario: Get read-open org
    Given path '/organizations/organizations/', readOnlyOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(readOnlyOrganizationId)'

  @Negative
  Scenario: Get full-protected org - receive forbidden status
    Given path '/organizations/organizations/', fullProtectedOrganizationId
    When method GET
    Then status 403

  @Positive
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

  @Positive
  Scenario: Get not protected org
    Given path '/organizations/organizations/', noAcqOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(noAcqOrganizationId)'

  @Positive
  Scenario: Get read-open org
    Given path '/organizations/organizations/', readOnlyOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(readOnlyOrganizationId)'

  @Negative
  Scenario: Get full-protected org - receive forbidden status
    Given path '/organizations/organizations/', fullProtectedOrganizationId
    When method GET
    Then status 403

  @Positive
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

  @Positive
  Scenario: Get not protected org
    Given path '/organizations/organizations/', noAcqOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(noAcqOrganizationId)'

  @Positive
  Scenario: Get read-open org
    Given path '/organizations/organizations/', readOnlyOrganizationId
    When method GET
    Then status 200
    And match $.id == '#(readOnlyOrganizationId)'

  @Positive
  Scenario: Get full-protected org
    Given path '/organizations/organizations/', fullProtectedOrganizationId
    When method GET
    Then status 200

  @Positive
  Scenario: Get all organizations after assign full protected units to user
    Given path '/organizations/organizations'
    When method GET
    Then status 200
    And match $.totalRecords == 3

  @Negative
  Scenario: Post organization with account number duplicate
    Given path '/organizations/organizations'
    And request
      """
      {
        id: '#(notUniqueAccountOrganizationId)',
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'ORG',
        accounts:[{name:'Serials',accountNo:'xxxx7859',accountStatus:'Active'},{name:'TestAccount',accountNo:'xxxx7859',accountStatus:'Active'}]
      }
      """
    When method POST
    Then status 422

  @Negative
  Scenario: Put organization with account number duplicate
    Given path '/organizations/organizations'
    And request
      """
      {
        id: '#(notUniqueAccountOrganizationId)',
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'ORG'
      }
      """
    When method POST
    Then status 201

    Given path '/organizations/organizations', notUniqueAccountOrganizationId
    And request
      """
      {
        id: '#(notUniqueAccountOrganizationId)',
        name: 'Active org for API Test"',
        status: 'Active',
        code: 'ORG',
        accounts:[{name:'Serials',accountNo:'xxxx7859',accountStatus:'Active'},{name:'TestAccount',accountNo:'xxxx7859',accountStatus:'Active'}]
      }
      """
    When method PUT
    Then status 422
    And match response.errors[0].code == "accountNumberMustBeUnique"