Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(adminToken)' }
#    * callonce login admin
    * def desiredPermissions = karate.get('desiredPermissions', [])

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
      "id":"d4f06afe-57bf-4654-9cc1-92063010500<id>",
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
    And param query = 'childOf == []'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName
    * def additionalTable = karate.get('adminAdditionalPermissions', [])
    * def additionalPermissions = $additionalTable[*].name
    * def permissions = karate.append(permissions, additionalPermissions)

    # add permissions to admin user
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "userId":"d4f06afe-57bf-4654-9cc1-920630105001",
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
      "userId":"d4f06afe-57bf-4654-9cc1-920630105002",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

