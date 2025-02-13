Feature: init data for consortia

  Background:
    * url kongUrl
    * configure readTimeout = 300000
    * configure retry = { count: 20, interval: 10000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true'  }

  @PostTenant
  Scenario: Create a new tenant
    Given path '/tenants'
    And header x-okapi-token = okapitoken
    And request { id: '#(id)', name: '#(name)', description: '#(description)' }
    When method POST
    Then status 201

  @InstallModules
  Scenario: Install tenant for modules
    * print 'Get applications of diku tenant'
    * def response = call read('classpath:common/module.feature') {modules: '#(modules)'}

    * def applicationIds = get response.response.applicationDescriptors[*].id
    * print 'Application\'s ids:' + applicationIds
    * def tenantApplications = {tenantId: '#(tenant)', applications: '#(applicationIds)'}

    Given path '/entitlements'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 201
    And request tenantApplications
    When method POST
    Then status 201

  @DeleteTenant
  Scenario: Get list of enabled modules for specified tenant, and then disable these modules, finally delete tenant
    Given path '/tenants', tenant, 'modules'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200

    * set response $[*].action = 'disable'

    Given path '/tenants', tenant, 'install'
    And param purge = true
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request response
    When method POST
    Then status 200

    Given path '/tenants', tenant
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

  @SetUpAdmin
  Scenario: Create an admin with credentials, and add all existing permissions of enabled modules
    # create an admin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request
    """
    {
      id: '#(uuidStr)',
      username:  '#(username)',
      active:  true,
      barcode: '#(uuid())',
      externalSystemId: '#(uuid())',
      "type": "staff",
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
    And headers {'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)'}
    And request {username: '#(username)', password :'#(password)', userId: '#(uuidStr)'}
    When method POST
    Then status 201

    # get all existing permissions
    Given path 'roles'
    And headers {'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)'}
    And param limit = 1000
    When method GET
    Then status 200
    * def roleIds = get response.roles[*].id

    # add these permissions to the admin
    * print 'Assigning roles\' ids: ' + roleIds
    Given path 'roles/users'
    And headers {'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)'}
    And request { userId: '#(uuidStr)', roleIds: '#(roleIds)' }
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
      type: '#(type)',
      barcode: '#(uuid())',
      externalSystemId: '#(uuid())',
      personal: {
        email: 'user@gmail.com',
        firstName: 'user first name',
        lastName: 'user last name',
        preferredContactTypeId: '002',
        phone: '#(phone)',
        mobilePhone: '#(mobilePhone)'
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
    * def consortiaPermissionsTable = karate.get('consortiaPermissions', [])
    * def consortiaPermissions = $consortiaPermissionsTable[*].name
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
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)', 'Authtoken-Refresh-Cache': 'true' }
    And retry until response.totalRecords == 1
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

  @Login
  Scenario: Login a user, then if successful set latest value for 'okapitoken'
    Given path 'authn/login'
    And header x-okapi-tenant = tenant
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 201
    * def okapitoken = $.okapiToken