@ignore
Feature: helper methods for mgr-applications cleanup test

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * configure headers = null

  @loginAdmin
  Scenario: login admin user
    * call login admin
    * karate.set('adminToken', okapitoken)

  @grantMgrApplicationsPermissions
  Scenario: grant manager applications permissions to admin user
    * def adminToken = karate.get('adminToken')
    * if (!adminToken) karate.fail('adminToken is required')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(adminToken)', 'x-okapi-tenant': '#(admin.tenant)' }

    Given path 'users'
    And param query = 'username==' + admin.name
    When method GET
    Then status 200
    * def userId = response.users[0].id

    Given path 'perms/users'
    And param query = 'userId==' + userId
    When method GET
    Then status 200
    * def permissionUser = response.permissionUsers[0]
    * def permissions = permissionUser.permissions ? permissionUser.permissions : []
    * if (!permissions.includes('mgr-applications.all')) permissions.push('mgr-applications.all')

    Given path 'perms/users', permissionUser.id
    * def permissionUpdate =
      {
        id: '#(permissionUser.id)',
        userId: '#(userId)',
        permissions: '#(permissions)'
      }
    And request permissionUpdate
    When method PUT
    Then status 200

  @createApplication
  Scenario: create synthetic application
    * def adminToken = karate.get('adminToken')
    * def applicationDescriptor = karate.get('applicationDescriptor')
    * if (!adminToken) karate.fail('adminToken is required')
    * if (!applicationDescriptor) karate.fail('applicationDescriptor is required')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(adminToken)', 'x-okapi-tenant': '#(admin.tenant)' }

    Given path 'applications'
    And param check = false
    And request applicationDescriptor
    When method POST
    Then status 201

  @createModuleDiscovery
  Scenario: create module discovery
    * def adminToken = karate.get('adminToken')
    * def moduleId = karate.get('moduleId')
    * def discoveryRequest = karate.get('discoveryRequest')
    * if (!adminToken) karate.fail('adminToken is required')
    * if (!moduleId) karate.fail('moduleId is required')
    * if (!discoveryRequest) karate.fail('discoveryRequest is required')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(adminToken)', 'x-okapi-tenant': '#(admin.tenant)' }

    Given path 'modules', moduleId, 'discovery'
    And request discoveryRequest
    When method POST
    Then status 201

  @cleanupApplications
  Scenario: invoke applications cleanup
    * def adminToken = karate.get('adminToken')
    * if (!adminToken) karate.fail('adminToken is required')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(adminToken)', 'x-okapi-tenant': '#(admin.tenant)' }

    Given path 'applications', 'cleanup'
    When method POST
    Then status 200
