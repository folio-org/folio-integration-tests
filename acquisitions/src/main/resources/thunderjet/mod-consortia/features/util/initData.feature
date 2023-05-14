Feature: init data for 'mod-consortia'

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure retry = { count: 2, interval: 5000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }

  @PostTenant
  Scenario: Create a new tenant
    Given path '_/proxy/tenants'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
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
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request enabledModules
    When method POST
    Then status 200

  @DeleteTenant
  Scenario: deleteTenant
    Given path '_/proxy/tenants', tenant, 'modules'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200

    * set response $[*].action = 'disable'

    Given path '_/proxy/tenants', tenant, 'install'
    And param purge = true
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request response
    When method POST
    Then status 200

    Given path '_/proxy/tenants', tenant
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

  @PostUserWithCredentials
  Scenario: Crate a user with credentials
    # create a user
    Given path 'users'
    And header x-okapi-tenant = tenant
    And request {id: '#(id)', username:  '#(name)', active:  true, personal: '#(personal)'}
    When method POST
    Then status 201

    # specify user credentials
    Given path 'authn/credentials'
    And header x-okapi-tenant = tenant
    And request {username: '#(name)', password :'#(password)'}
    When method POST
    Then status 201

  @AddAdminPermissions
  Scenario: Get permissions for admin and add to new admin user
    # get permissions for admin
    Given path '/perms/permissions'
    And header x-okapi-tenant = tenant
    And param length = 1000
    And param query = 'childOf == []'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName

    # add permissions to admin user
    Given path 'perms/users'
    And header x-okapi-tenant = tenant
    And request { userId: '#(id)', permissions: '#(permissions)' }
    When method POST
    Then status 201

  @AddUserPermissions
  Scenario: Add permissions for user
    * def permissions = $userPermissions[*].name
    Given path 'perms/users'
    And header x-okapi-tenant = tenant
    And request { userId: '#(id)', permissions: '#(permissions)' }
    When method POST
    Then status 201

  @Login
  Scenario: Login a user
    Given path 'authn/login'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    And request { username: '#(name)', password: '#(password)' }
    When method POST
    Then status 201
    * def okapitoken = responseHeaders['x-okapi-token'][0]
































