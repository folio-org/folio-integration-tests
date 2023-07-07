Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * callonce login admin
    * def desiredPermissions = karate.get('desiredPermissions', [])
    * def modAuthtoken = ''

  Scenario: create new tenant
    * if (useExistingTenant) karate.abort()
    * print "create new tenant"
    Given call read('classpath:common/tenant.feature@create') { tenant: '#(testTenant)'}

  Scenario: get and install configured modules
    * if (useExistingTenant) karate.abort()
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

  Scenario: disable 'mod-authtoken' if 'useExistingTenant' = true
    * if (useExistingTenant == false) karate.abort()
    Given path '_/proxy/tenants', existingTenant, 'modules'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200

    * def fun = function(module) { return module.id.includes('mod-authtoken') }
    * def response = karate.filter(response, fun)
    * set response $[*].action = 'disable'
    * modAuthtoken = response[0].id

    Given path '_/proxy/tenants', existingTenant, 'install'
    And param purge = true
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request response
    When method POST
    Then status 200

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
    * if (useExistingTenant) karate.abort()
    * print "enable mod-authtoken module"
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-authtoken'}], tenant: '#(testTenant)'}

  Scenario: enable mod-authtoken module if 'useExistingTenant' = true
    * if (useExistingTenant == false) karate.abort()
    Given path '_/proxy/tenants', existingTenant, 'install'
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request {id: '#(modAuthtoken)', action :'enable'}
    When method POST
    Then status 200
