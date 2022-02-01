Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token' : #(adminToken)}
    * table okapiPermissionsTable
      | name                              |
      |'okapi.proxy.modules.post'|
      |'okapi.proxy.modules.put'|
      |'okapi.proxy.modules.delete'|
      |'okapi.proxy.pull.modules.post'|
      |'okapi.proxy.tenants.put'|
      |'okapi.proxy.tenants.delete'|
      |'okapi.proxy.tenants.modules.post'|
      |'okapi.proxy.tenants.modules.enabled.post'|
      |'okapi.proxy.tenants.upgrade.post'|
      |'okapi.proxy.tenants.install.post'|
      |'okapi.proxy.tenants.modules.enabled.delete'|
      |'okapi.env.delete'|
      |'okapi.env.list'|
      |'okapi.modules'|
      |'okapi.env'|
      |'okapi.deployment.post'|
      |'okapi.deployment.get'|
      |'okapi.deployment.delete'|
      |'okapi.discovery.post'|
      |'okapi.discovery.get'|
      |'okapi.discovery.put'|
      |'okapi.discovery.delete'|
      |'okapi.discovery.nodes.put'|
      |'okapi.discovery.health.get'|
      |'okapi.discovery.nodes.get'|
      |'okapi.env.post'|
      |'okapi.env.get'|
      |'okapi.all'|
      |'okapi.deploy'|
      |'okapi.tenants'|
      |'okapi.tenantmodules'|
      |'users.item.post'|
      |'okapi.proxy.tenants.post'|
      |'okapi.proxy.tenants.delete'|

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









