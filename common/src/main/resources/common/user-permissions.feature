Feature: prepare data for user permissions api test

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * callonce login admin
    * def desiredPermissions = karate.get('desiredPermissions', [])

  Scenario Outline: Add desired permission
    * print "Add desired permission"
    Given path 'perms/permissions'
    And header x-okapi-tenant = __arg.tenant
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
    And header x-okapi-tenant = __arg.tenant
    And request
      """
      {
        "id":"00000000-1111-5555-9999-99999999999<id>",
        "username": '#(userName)',
        "active":true,
        "personal": {"firstName":"Karate","lastName":'#("User " + userName)'}
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
    And header x-okapi-tenant = __arg.tenant
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
    And header x-okapi-tenant = __arg.tenant
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
    And header x-okapi-tenant = __arg.tenant
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
    And header x-okapi-tenant = __arg.tenant
    And request
      """
      {
    "userId":"00000000-1111-5555-9999-999999999992",
    "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201
