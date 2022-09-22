Feature: prepare data for api test

  Background:
    * url baseUrl
    * call login admin
    * def adminToken = okapitoken
    * configure retry = { count: 10, interval: 3000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token' : #(adminToken)}
    * table okapiPermissionsTable
      | name                                         |
      | 'okapi.all'                                  |
      | 'users.item.post'                            |

  Scenario: get userId
    Given path 'users'
    And param query = 'username==' + admin.name
    And header x-okapi-token = adminToken
    When method GET
    Then status 200
    * def userId = response.users[0].id
    * print 'admin user id', userId

    Given path 'perms/users'
    And param query = 'userId==' + userId

    When method GET
    Then status 200
    * def permissionId = response.permissionUsers[0].id
    * print 'permissionId', permissionId
    * def permissions = $.permissionUsers[*].permissions[*]
    * def okapiPerms = $okapiPermissionsTable[*].name
    * def permissions = karate.append(permissions, okapiPerms)

    Given path 'perms/users',permissionId
    And request
    """
    {
        "id": #(permissionId),
        "userId": #(userId),
        "permissions": #(permissions)
    }
    """
    When method PUT
    Then status 200
