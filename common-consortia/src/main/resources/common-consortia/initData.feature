Feature: init data for consortia

  Background:
    * url kongUrl
    * configure readTimeout = 300000
    * configure retry = { count: 1, interval: 10000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true'  }

  @PostTenant
  Scenario: Create a new tenant
    Given path '/tenants'
    And header x-okapi-token = token
    And request { id: '#(tenant.id)', name: '#(tenant.name)', description: '#(description)' }
    When method POST
    Then status 201

  @InstallModules
  Scenario: Create entitlements in tenant. The same ones like in diku tenant
    * print 'Get applications of diku tenant'
    * def response = call read('classpath:common/module.feature') {modules: '#(modules)', prototypeTenant: '#(prototypeTenant)', token: '#(token)'}

    * def applicationIds = get response.response.applicationDescriptors[*].id
    * print 'Application\'s ids:' + applicationIds
    * def tenantApplications = {tenantId: '#(tenant.id)', applications: '#(applicationIds)'}

    Given path '/entitlements'
    And header x-okapi-token = token
    And retry until responseStatus == 201
    And request tenantApplications
    When method POST
    Then status 201

  @InstallApplications
  Scenario: Create entitlements in tenant. The same ones like in diku tenant
    * print 'Application\'s ids:' + applicationIds
    * def tenantApplications = {tenantId: '#(tenant.id)', applications: '#(applicationIds)'}

    Given path '/entitlements'
    And header x-okapi-token = token
    And retry until responseStatus == 201
    And request tenantApplications
    When method POST
    Then status 201

  @DeleteTenant
  Scenario: Get list of enabled modules for specified tenant, and then disable these modules, finally delete tenant
    * print 'Get applications of #() tenant'
    * def response = call read('classpath:common/module.feature') {modules: '#(modules)', tenantName: '#(tenant.name)', token: '#(token)'}

    * def applicationIds = get response.response.applicationDescriptors[*].id

    * if (applicationIds.length != 0) karate.call('classpath:common-consortia/initData.feature@DeleteEntitlements', {tenant: '#(tenant)', applicationIds: '#(applicationIds)', token: '#(token)'})

    Given path '/tenants', tenant.id
    And header x-okapi-token = token
    When method DELETE
    Then status 204

  @DeleteEntitlements
  Scenario: delete entitlements in tenant
    * def tenantApplications = {tenantId: '#(tenant.id)', applications: '#(applicationIds)'}

    Given path '/entitlements'
    And header x-okapi-token = token
    And retry until responseStatus == 200
    And request tenantApplications
    When method DELETE
    Then status 200

  @SetUpAdmin
  Scenario: Create an admin with credentials, and add all existing permissions of enabled modules
    # create an admin
    * call read('classpath:common-consortia/initData.feature@PostUser') {tenant: '#(tenant)', user: '#(user)', token: '#(token)'}

    # specify the admin credentials
    Given path 'authn/credentials'
    And headers {'x-okapi-tenant': '#(tenant.name)', 'x-okapi-token': '#(token)'}
    And request {username: '#(user.username)', password :'#(user.password)', userId: '#(user.userId)'}
    When method POST
    Then status 201

    # get all existing roles
    Given path 'roles'
    And headers {'x-okapi-tenant': '#(tenant.name)', 'x-okapi-token': '#(token)'}
    And param limit = 1000
    When method GET
    Then status 200
    * def roleIds = get response.roles[*].id

    # add these permissions to the admin
    * print 'Assigning roles\' ids: ' + roleIds
    Given path 'roles/users'
    And headers {'x-okapi-tenant': '#(tenant.name)', 'x-okapi-token': '#(token)'}
    And request { userId: '#(user.userId)', roleIds: '#(roleIds)' }
    When method POST
    Then status 201

  @PostUser
  Scenario: Crate a user with credentials
    # create a user
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant.name)', 'x-okapi-token':'#(token)'}
    And request
      """
      {
        id: '#(user.userId)',
        username:  '#(user.username)',
        active:  true,
        barcode: '#(uuid())',
        externalSystemId: '#(uuid())',
        "type": "staff",
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
    And headers {'x-okapi-tenant': '#(tenant.name)', 'x-okapi-token': '#(token)'}
    And request {username: '#(user.username)', password :'#(user.password)', userId: '#(user.userId)'}
    When method POST
    Then status 201

  @PostPermissions
  Scenario: Post specified permissions to the user
    * def consortiaPermissionsTable = karate.get('consortiaPermissions', [])
    * def consortiaPermissions = $consortiaPermissionsTable[*].name
    * def permissions = karate.get('extPermissions', consortiaPermissions)
    Given path 'perms/users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(id)', permissions: '#(permissions)' }
    When method POST
    Then status 201

  @PutRoles
  Scenario: Put additional permissions to the user
    # get users' existing capabilities
    Given path 'users/capabilities'
    And headers {'x-okapi-tenant':'#(tenant.name)', 'x-okapi-token':'#(token)'}
    And param query = 'userId=(' + user.id + ')'
    When method GET
    Then status 200
    * def existingUserCapabilitiesIds = get $.response.userCapabilities[*].capabilityId

    # find capabilities by names
    * def queryStr = orWhereQuery('permission', desiredCapabilities)
    * print 'query to get capabilities: ' + queryStr
    Given path 'capabilities'
    And param query = queryStr
    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * def capabIds = $.capabilities[*].id

    * def newCapabIds = capabIds.push(existingUserCapabilitiesIds)

    # update capabilities
    Given path '/users/capabilities'
    And headers {'x-okapi-tenant':'#(tenant.name)', 'x-okapi-token':'#(token)'}
    And request {userId: '#(user.userId)', capabilityIds: '#(newCapabIds)'}
    When method POST
    Then status 201

  @Login
  Scenario: Login a user, then if successful set latest value for 'okapitoken'
    Given path 'authn/login'
    And header x-okapi-tenant = user.tenant
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 201
    * def token = $.okapiToken