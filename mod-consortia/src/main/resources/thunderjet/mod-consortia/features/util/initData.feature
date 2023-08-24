Feature: init data for 'mod-consortia'

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure retry = { count: 10, interval: 10000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }

  @PostTenant
  Scenario: Create a new tenant
    Given path '_/proxy/tenants'
    And header x-okapi-token = okapitoken
    And request { id: '#(id)', name: '#(name)', description: '#(description)' }
    When method POST
    Then status 201

  @InstallModules
  Scenario: Install tenant for modules
    * def response = call read('classpath:common/module.feature') __arg.modules

    * def modulesWithVersions = $response[*].response[-1].id
    * def enabledModules = karate.map(modulesWithVersions, function(x) {return {id: x, action: 'enable'}})
    * print enabledModules
    # tenantParams should be declared in your karate-config file as following tenantParams: {loadReferenceData : true}
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData

    Given path '_/proxy/tenants', tenant, 'install'
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request enabledModules
    When method POST
    Then status 200

  @DeleteTenant
  Scenario: Get list of enabled modules for specified tenant, and then disable these modules, finally delete tenant
    Given path '_/proxy/tenants', tenant, 'modules'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200

    * set response $[*].action = 'disable'

    Given path '_/proxy/tenants', tenant, 'install'
    And param purge = true
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request response
    When method POST
    Then status 200

    Given path '_/proxy/tenants', tenant
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

  @SetUpAdmin
  Scenario: Create an admin with credentials, and add all existing permissions of enabled modules
    # create an admin
    Given path 'users'
    And header x-okapi-tenant = tenant
    And request
    """
    {
      id: '#(id)',
      username:  '#(username)',
      active:  true,
      personal: {
        email: 'admin@gmail.com',
        firstName: 'admin first name',
        lastName: 'admin last name',
        preferredContactTypeId: '002'
        }
    }
    """
    When method POST
    Then status 201

    # specify the admin credentials
    Given path 'authn/credentials'
    And header x-okapi-tenant = tenant
    And request {username: '#(username)', password :'#(password)'}
    When method POST
    Then status 201

    # get all existing permissions
    Given path '/perms/permissions'
    And header x-okapi-tenant = tenant
    And param length = 1000
    And param query = 'childOf == []'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName

    # add these permissions to the admin
    Given path 'perms/users'
    And header x-okapi-tenant = tenant
    And request { userId: '#(id)', permissions: '#(permissions)' }
    When method POST
    Then status 201

  @PostUser
  Scenario: Crate a user with credentials
    # create a user
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request
    """
    {
      id: '#(id)',
      username:  '#(username)',
      active:  true,
      personal: {
        email: 'user@gmail.com',
        firstName: 'user first name',
        lastName: 'user last name',
        preferredContactTypeId: '002'
        }
    }
    """
    When method POST
    Then status 201

    # specify user credentials
    Given path 'authn/credentials'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request {username: '#(username)', password :'#(password)'}
    When method POST
    Then status 201

  @PostPermissions
  Scenario: Post specified permissions to the user
    * def consortiaPermissions = $consortiaPermissions[*].name
    * def permissions = karate.get('extPermissions', consortiaPermissions)
    Given path 'perms/users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(id)', permissions: '#(permissions)' }
    When method POST
    Then status 201

  @PutPermissions
  Scenario: Put additional permissions to the user
    # get users' existing permissions
    Given path 'perms/users'
    And param query = 'userId=' + id
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    # add new permissions to existing ones
    * def newPermissions = karate.get('desiredPermissions', [])
    * def permissionEntry = $.permissionUsers[0]
    * def updatedPermissions = karate.append(newPermissions, permissionEntry.permissions)
    And set permissionEntry.permissions = updatedPermissions

    # update user permissions
    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200