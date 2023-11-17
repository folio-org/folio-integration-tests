Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * callonce login admin
    * def desiredPermissions = karate.get('desiredPermissions', [])

  Scenario: create new tenant
    * print "create new tenant"
    Given call read('classpath:common/tenant.feature@create') { tenant: '#(testTenant)'}

  Scenario: get and install configured modules
    * print "get and install configured modules"
    Given call read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testTenant)'}

  Scenario Outline: Add desired permission
    * print "Add desired permission"
    Given path 'perms/permissions'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      permissionName: '#(desiredPermissionName)',
      displayName: '#(desiredPermissionName)'
    }
    """
    When method POST
    Then status 201
    Examples:
      | desiredPermissions |

  Scenario: create test users
    * print "create test users"
    Given path 'users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "id": #(testUser.id),
      "username": '#(testUser.name)',
      "active":true,
      "personal": {"firstName":"Karate","lastName":'#("User " + userName)'}
    }
    """
    When method POST
    Then status 201



  Scenario: specify user credentials
    * print "specify user credentials"

    Given path 'authn/credentials'
    And header x-okapi-tenant = testTenant
    And request {username: '#(testUser.name)', password :'#(testUser.password)'}
    When method POST
    Then status 201

  Scenario: get permissions for admin and add to new admin user
    * print "get permissions for admin and add to new admin user"

    Given path '/perms/permissions'
    And header x-okapi-tenant = testTenant
    And param length = 1000
    And param query = 'childOf == []'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName
    * def additionalTable = karate.get('adminAdditionalPermissions', [])
    * def additionalPermissions = $additionalTable[*].name
    * def permissions = karate.append(permissions, additionalPermissions)

  Scenario: add permissions for test user
    * print "add permissions for test user"
    * def permissions = $userPermissions[*].name
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "userId": #(testUser.id),
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  Scenario: enable mod-authtoken module
    * print "enable mod-authtoken module"

    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-authtoken'}], tenant: '#(testTenant)'}
