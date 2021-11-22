Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure readTimeout = 190000
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

  Scenario Outline: create test users
    * print "create test users"
    * def userName = <name>

    Given path 'users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "id":"00000000-1111-5555-9999-99999999999<id>",
      "username": '#(userName)',
      "active":true,
      "personal": {"firstName":"Admin","lastName":"Orders API Tests"}
    }
    """
    When method POST
    Then status 201

    Examples:
      | name           | id |
      | testAdmin.name | 1  |
      | testUser.name  | 2  |


  Scenario Outline: specify user credentials
    * print "specify user credentials"

    * def userName = <name>
    * def password = <pass>

    Given path 'authn/credentials'
    And header x-okapi-tenant = testTenant
    And request {username: '#(userName)', password :'#(password)'}
    When method POST
    Then status 201

    Examples:
      | name           | pass               |
      | testAdmin.name | testAdmin.password |
      | testUser.name  | testUser.password  |

  Scenario: get permissions for admin and add to new admin user
    * print "get permissions for admin and add to new admin user"

    Given path '/perms/permissions'
    And header x-okapi-tenant = testTenant
    And param length = 1000
    And param query = '(subPermissions="" NOT subPermissions ==/respectAccents []) and (cql.allRecords=1 NOT childOf <>/respectAccents [])'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName
    * print permissions
    * def additional = $adminAdditionalPermissions[*].name
    * def permissions = karate.append(permissions, additional)

    # add permissions to admin user
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "userId":"00000000-1111-5555-9999-999999999991",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  Scenario: add permissions for test user
    * print "add permissions for test user"
    * def permissions = $userPermissions[*].name
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "userId":"00000000-1111-5555-9999-999999999992",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  Scenario: enable mod-authtoken module
    * print "enable mod-authtoken module"

    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-authtoken'}], tenant: '#(testTenant)'}
