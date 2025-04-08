Feature: init data for consortia

  Background:
    * url kongUrl
    * configure readTimeout = 300000
    * configure retry = { count: 20, interval: 10000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true'  }

  # Parameters: Tenant tenant, String description, String token Result: void
  @PostTenant
  Scenario: Create a new tenant
    Given path 'tenants'
    And request { id: '#(tenantId)', name: '#(tenantName)', description: '#(description)' }
    When method POST
    Then status 201

  @InstallApplications
  Scenario: Create entitlements in tenant. The same ones like in diku tenant
    * print 'Get applications of consortium tenant'
    * def testTenantId = tenantId

    * call read('classpath:common/eureka/application.feature@applicationSearch')
    * def entitlementTamplate = read('classpath:common/eureka/samples/entitlement-entity.json')
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData
    * def tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    Given url baseUrl
    Given path 'entitlements'
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And param async = true
    And param purgeOnRollback = false
    And request entitlementTamplate
    When method POST
    * def flowId = response.flowId

    * configure retry = { count: 40, interval: 30000 }
    Given path 'entitlement-flows', flowId
    * retry until response.status == "finished" || response.status == "cancelled" || response.status == "cancellation_failed" || response.status == "failed"
    When method GET
    * def failCondition = response.status
    * if (failCondition == "cancelled" || failCondition == "cancellation_failed" || failCondition == "failed") karate.fail('Entitlement creation failed.')

  # Parameters: Tenant tenant, String[] modules, String token Result: void
  @DeleteTenant
  Scenario: Get list of enabled modules for specified tenant, and then disable these modules, finally delete tenant
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteEntitlements') {testTenantId: '#(tenantId)' }
    * call read('classpath:common/eureka/destroy-data.feature@deleteTenant') {testTenantId: '#(tenantId)' }

  # Parameters: Tenant tenant, String[] applicationIds, String token Result: void
  @DeleteEntitlements
  Scenario: delete entitlements in tenant
    * configure abortedStepsShouldPass = true
    * print "---destroy entitlement---"
    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    When method GET
    * def totalAmount = response.totalRecords
    * if(totalAmount < 1) karate.abort()

    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    And param limit = totalAmount
    When method GET

    * def applicationIds = karate.map(response.entitlements, x => x.applicationId)
    * if(applicationIds.length < 1) karate.abort()
    * def entitlementTamplate = read('classpath:common/eureka/samples/entitlement-entity.json')
    Given path 'entitlements'
    And param purge = true
    And request entitlementTamplate
    When method DELETE
    Then status 200

  @PostAdmin
  Scenario: Create an admin with credentials, and add all existing permissions of enabled modules
    # create an admin
    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def token = karate.get('token')
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token':'#(token)'}
    And request
      """
      {
        id: '#(user.id)',
        username:  '#(user.username)',
        active:  true,
        barcode: '#(uuid())',
        externalSystemId: '#(uuid())',
        personal: {
          email: 'admin@gmail.com',
          firstName: 'admin first name',
          lastName: 'admin last name',
          preferredContactTypeId: '002',
          phone: '#(phone)',
          mobilePhone: '#(mobilePhone)'
        }
      }
      """
    When method POST
    Then status 201

    # specify the admin credentials
    Given path 'authn/credentials'
    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token':'#(token)'}
    And request {username: '#(user.username)', password :'#(user.password)', userId: '#(user.id)'}
    When method POST
    Then status 201

  # Uncomment when capabilities async creation will be fixed
  #    # get total amount of capabilities
  #    Given path 'capabilities'
  #    And headers {'x-okapi-tenant': '#(tenantName)', 'x-okapi-token': '#(token)'}
  #    When method GET
  #    Then status 200
  #    * def totalCapsAmount = response.totalRecords
  #
  #    # get all existing caps
  #    Given path 'capabilities'
  #    And headers {'x-okapi-tenant': '#(tenantName)', 'x-okapi-token': '#(token)'}
  #    And param limit = totalCapsAmount
  #    When method GET
  #    Then status 200
  #    * def capIds = response.capabilities[*].id
  #
  #    # add these caps to the admin
  #    * print 'Assigning cap\'s ids: ' + capIds
  #    Given path 'users/capabilities'
  #    And headers {'x-okapi-tenant': '#(tenantName)', 'x-okapi-token': '#(token)'}
  #    And request { userId: '#(user.id)', capabilityIds: '#(capIds)' }
  #    When method POST
  #    Then status 201

  # Parameters: Tenant tenant, User user, String token Result: void
  @PostUser
  Scenario: Crate a user with credentials
    # create a user
    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def token = karate.get('token')
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token':'#(token)'}
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
    And headers {'x-okapi-tenant': '#(tenantName)', 'x-okapi-token': '#(token)'}
    And request {username: '#(user.username)', password :'#(user.password)', userId: '#(user.id)'}
    When method POST
    Then status 201

  # Parameters: Tenant tenant, User user, String token, String[] capNames Result: void
  @PutCaps
  Scenario: Put additional caps to the user
    * def token = karate.get('token')
    # get users' existing capabilities
    #    Given path 'users/capabilities'
    #    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token':'#(token)'}
    #    And param query = 'userId=(' + user.userId + ')'
    #    When method GET
    #    Then status 200
    #    * def existingUserCapabilitiesIds = response.userCapabilities[*].capabilityId
    #    * if (existingUserCapabilitiesIds.length != 0) existingUserCapabilitiesIds = []

    # find capabilities by names
    * def permissions = $userPermissions[*].name
    * def retryCount = 30
    * def interval = 30000
    * def waitUntil =
      """
      function(count) {
        while (true) {
          karate.log('****************** retry left # ', count);
          var result = karate.call('classpath:common-consortia/eureka/capabilities.feature');
          var capabilityIds = result.response.capabilities.map(x => x.id);
          if (capabilityIds.length == permissions.length) {
            karate.log('***** All capabilities have been successfully found *****');
            return capabilityIds;
          }
          count--;
          if (count == 0) {
            karate.log('***** Not all capabilities found *****');
            return capabilityIds;
          }
          java.lang.Thread.sleep(interval);
        }
      }
      """
    * def capabilityIds = call waitUntil retryCount

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    # update capabilities
    Given path '/users/capabilities'
    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token':'#(token)'}
    And request {userId: '#(user.id)', capabilityIds: '#(capabilityIds)'}
    When method POST
    Then status 201

  # Parameters: User user Result: String token
  @Login
  Scenario: Login a user, then if successful set latest value for 'okapitoken'
    Given path 'authn/login'
    And header x-okapi-tenant = tenant
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 201
    * def token = $.okapiToken