Feature: init data for consortia

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure retry = { count: 20, interval: 10000 }
    * def defaultHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true',  'x-okapi-token': '#(token)'}

  # Parameters: Tenant tenant, String description, String token Result: void
  @PostTenant
  Scenario: Create a new tenant
    Given path 'tenants'
    And headers defaultHeaders
    And request { id: '#(tenant.id)', name: '#(tenant.name)', description: '#(description)' }
    When method POST
    Then status 201

  # Parameters: Tenant tenant, String token, String prototypeTenant Result: void
  @InstallModules
  Scenario: Create entitlements in tenant. The same ones like in diku tenant
    * print 'Get applications of consortium tenant'
    * def result = call read('classpath:common/eureka/application.feature@applicationSearch') {token: '#(token)'}

    * def applicationIds = get result.appIds
    * print 'Application\'s ids:' + applicationIds
    * def tenantApplications = {tenantId: '#(tenant.id)', applications: '#(applicationIds)'}
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData
    Given url baseUrl
    Given path 'entitlements'
    And headers defaultHeaders
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And param async = true
    And param purgeOnRollback = false
    And request tenantApplications
    When method POST
    * def flowId = response.flowId

    Given path 'entitlement-flows', flowId
    And headers defaultHeaders
    When method GET
    * def failCondition = response.status
    * if (failCondition == "cancelled" || failCondition == "cancellation_failed" || failCondition == "failed") karate.abort()

    * configure retry = { count: 40, interval: 30000 }
    Given path 'entitlement-flows', flowId
    And headers defaultHeaders
    And retry until responseStatus == 200 && response.status == "finished"
    When method GET

  # Parameters: Tenant tenant, String[] modules, String token Result: void
  @DeleteTenant
  Scenario: Get list of enabled modules for specified tenant, and then disable these modules, finally delete tenant
    Given path 'tenants', tenant.id
    And headers defaultHeaders
    When method DELETE
    Then status 204

  # Parameters: Tenant tenant, String[] applicationIds, String token Result: void
  @DeleteEntitlements
  Scenario: delete entitlements in tenant
    * def tenantApplications = {tenantId: '#(tenant.id)', applications: '#(applicationIds)'}

    Given path 'entitlements'
    And headers defaultHeaders
    And retry until responseStatus == 200
    And request tenantApplications
    When method DELETE
    Then status 200

  # Parameters: Tenant tenant, User user, String token Result: void
  @SetUpAdmin
  Scenario: Create an admin with credentials, and add all existing permissions of enabled modules
    # create an admin
    * call read('classpath:common-consortia/eureka/initData.feature@PostUser') {tenant: '#(tenant)', user: '#(user)', token: '#(token)'}

    # get total amount of capabilities
    Given path 'capabilities'
    And headers defaultHeaders
    And header x-okapi-tenant = tenant.name
    When method GET
    Then status 200
    * def totalCapsAmount = get response.totalRecords

    # get all existing caps
    Given path 'capabilities'
    And headers defaultHeaders
    And header x-okapi-tenant = tenant.name
    And param limit = totalCapsAmount
    When method GET
    Then status 200
    * def capIds = get response.capabilities[*].id

    # add these caps to the admin
    * print 'Assigning cap\'s ids: ' + capIds
    Given path 'users/capabilities'
    And headers defaultHeaders
    And header x-okapi-tenant = tenant.name
    And request { userId: '#(user.id)', capabilityIds: '#(capIds)' }
    When method POST
    Then status 201

  # Parameters: Tenant tenant, User user, String token Result: void
  @PostUser
  Scenario: Crate a user with credentials
    # create a user
    Given path 'users'
    And headers defaultHeaders
    And header x-okapi-tenant = tenant.name
    And request
      """
      {
        id: '#(user.id)',
        username:  '#(user.username)',
        active:  true,
        barcode: '#(uuid())',
        externalSystemId: '#(uuid())',
        type: 'staff',
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
    And headers defaultHeaders
    And header x-okapi-tenant = tenant.name
    And request {username: '#(user.username)', password :'#(user.password)', userId: '#(user.id)'}
    When method POST
    Then status 201

  # Parameters:  User user, String token, String[] capNames Result: void
  @PutCaps
  Scenario: Put additional caps to the user
    # get users' existing capabilities
    Given path 'users/capabilities'
    And headers defaultHeaders
    And header x-okapi-tenant = user.tenant
    And param query = 'userId=(' + user.id + ')'
    When method GET
    Then status 200
    * def existingUserCapabilitiesIds = get $.response.userCapabilities[*].capabilityId
    * if (existingUserCapabilitiesIds.length != 0) existingUserCapabilitiesIds = []

    # find capabilities by names
    * def queryStr = orWhereQuery('permission', capNames)
    * print 'query to get capabilities: ' + queryStr
    Given path 'capabilities'
    And param query = queryStr
    And headers defaultHeaders
    And header x-okapi-tenant = user.tenant
    When method GET
    Then status 200
    * def capIds = $.capabilities[*].id

    * def newCapIds = capIds.concat(existingUserCapabilitiesIds)

    # update capabilities
    Given path '/users/capabilities'
    And headers defaultHeaders
    And header x-okapi-tenant = user.tenant
    And request {userId: '#(user.id)', capabilityIds: '#(newCapIds)'}
    When method POST
    Then status 201

  # Parameters: User user Result: String token
  @Login
  Scenario: Login a user, then if successful set latest value for 'okapitoken'
    Given path 'authn/login'
    And header x-okapi-tenant = user.tenant
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 201
    * def token = $.okapiToken