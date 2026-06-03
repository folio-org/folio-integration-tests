Feature: CRUD operations on roles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: create, get, update, and delete a role
    # Create a role and capture its identifier.
    * def roleName = 'karate-role-' + nowMillis()
    * def updatedRoleName = roleName + '-updated'
    * def createRoleRequest =
      """
      {
        "name": "#(roleName)",
        "description": "Created by Karate",
        "type": "REGULAR"
      }
      """

    Given path 'roles'
    And request createRoleRequest
    When method post
    Then status 201
    And match response.id == '#uuid'
    And match response.name == roleName
    And match response.description == 'Created by Karate'
    And match response.type == 'REGULAR'
    * def roleId = response.id

    # Verify that the role was created by reading it directly and through a collection query.
    Given path 'roles', roleId
    When method get
    Then status 200
    And match response.id == roleId
    And match response.name == roleName

    Given path 'roles'
    And param query = 'name=="' + roleName + '"'
    When method get
    Then status 200
    And assert response.totalRecords >= 1
    And match response.roles[*].id contains roleId

    # Update the role and verify the new values were persisted.
    * def updateRoleRequest =
      """
      {
        "name": "#(updatedRoleName)",
        "description": "Updated by Karate",
        "type": "CONSORTIUM"
      }
      """
    Given path 'roles', roleId
    And request updateRoleRequest
    When method put
    Then status 204

    Given path 'roles', roleId
    When method get
    Then status 200
    And match response.id == roleId
    And match response.name == updatedRoleName
    And match response.description == 'Updated by Karate'
    And match response.type == 'CONSORTIUM'

    # Delete the role and confirm it is no longer available.
    Given path 'roles', roleId
    When method delete
    Then status 204

    Given path 'roles', roleId
    When method get
    Then status 404
    And match response.errors == '#array'

  @Positive
  Scenario: create roles in batch
    # Create two roles in one request and capture their identifiers.
    * def firstRoleName = 'karate-batch-role-1-' + nowMillis()
    * def secondRoleName = 'karate-batch-role-2-' + uuid()
    * def batchCreateRequest =
      """
      {
        "roles": [
          { "name": "#(firstRoleName)", "description": "Batch role 1", "type": "REGULAR" },
          { "name": "#(secondRoleName)", "description": "Batch role 2", "type": "REGULAR" }
        ]
      }
      """

    Given path 'roles', 'batch'
    And request batchCreateRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.roles == '#[2]'
    And match response.roles[*].name contains firstRoleName
    And match response.roles[*].name contains secondRoleName
    * def firstBatchRoleId = response.roles[0].id
    * def secondBatchRoleId = response.roles[1].id

    # Clean up the created roles.
    Given path 'roles', firstBatchRoleId
    When method delete
    Then status 204

    Given path 'roles', secondBatchRoleId
    When method delete
    Then status 204

  @Negative
  Scenario: get a role by a non-existing id
    * def missingRoleId = uuid()

    Given path 'roles', missingRoleId
    When method get
    Then status 404
    And match response.errors == '#array'