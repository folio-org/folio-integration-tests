Feature: prepare data for api test


  Background:
    * url baseUrl
    * configure readTimeout = 3000000

  @createTenant
  Scenario: create new tenant
    * print "---create new tenant---"
    Given call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(testTenantId)', tenantName: '#(testTenant)'}

  @createEntitlement
  Scenario: create entitlement
    * print "---create entitlement---"
    * call read('classpath:common/eureka/application.feature@applicationSearch')
    * def entitlementTamplate = read('classpath:common/eureka/samples/entitlement-entity.json')
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData
    * def tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    Given url baseUrl
    Given path 'entitlements'
    And param tenantParameters = tenantParameters
    And param async = true
    And param purgeOnRollback = false
    And request entitlementTamplate
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And header x-okapi-token = keycloakMasterToken
    When method POST
    * def flowId = response.flowId

    * configure retry = { count: 40, interval: 30000 }
    Given path 'entitlement-flows', flowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + keycloakMasterToken
    * retry until response.status == "finished" || response.status == "cancelled" || response.status == "cancellation_failed" || response.status == "failed"
    When method GET
    * def failCondition = response.status
    * if (failCondition == "cancelled" || failCondition == "cancellation_failed" || failCondition == "failed") karate.fail('Entitlement creation failed.')

  @getAuthorizationToken
  Scenario: get authorization token for new tenant
    * print "---extracting authorization token---"
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token

    Given url baseKeycloakUrl
    And path 'admin', 'realms', testTenant, 'clients'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    Then status 200
    * def clientId = response.filter(x => x.clientId == 'sidecar-module-access-client')[0].id

    Given url baseKeycloakUrl
    And path 'admin', 'realms', testTenant, 'clients', clientId, 'client-secret'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    Then status 200
    * def sidecarSecret = response.value

    Given url baseKeycloakUrl
    And path 'realms', testTenant, 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = 'sidecar-module-access-client'
    And form field client_secret = sidecarSecret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * karate.set('accessToken', response.access_token)

  @createTestUser
  Scenario: create test user
    * print "---create test users---"
    * def userName = testUser.name
    * def accessToken = karate.get('accessToken')
    Given path 'users-keycloak', 'users'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accessToken)'}
    And request
      """
      {
        "username": '#(userName)',
        "active":true,
        "departments": [],
        "proxyFor": [],
        "type": "patron",
        "personal": {"firstName":"Karate","lastName":'#("User " + userName)'}
      }
      """
    When method POST
    Then status 201
    * karate.set("userId", response.id)

  @specifyUserCredentials
  Scenario: specify user credentials
    * print "---specify user credentials---"
    * def userName = testUser.name
    * def userId = karate.get('userId')
    * def password = testUser.password
    * def accesstoken = karate.get('accessToken')
    Given path 'authn', 'credentials'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And request {username: '#(userName)', "userId": '#(userId)', password :'#(password)'}
    When method POST
    Then status 201

  @addUserCapabilities
  Scenario: add permissions for test user
    * print "---add permissions for test user---"

    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    When method GET
    Then status 200
    * def totalAmount = response.totalRecords
    * if (totalAmount == 0) karate.fail('The tenant has 0 entitlements, so there is no point in looking for capabilities.')


    * print "search requered capabilities ids"
    * def permissions = $userPermissions[*].name
    * def retryCount = 30
    * def interval = 30000
    * def waitUntil =
        """
        function(count) {
          while (true) {
            karate.log('****************** retry left # ', count);
            var chunkSize = 50;
            var capabilityIds = []
            var permissionsFound = []
            var missingPermissions = []

            for (let i = 0; i < permissions.length; i += chunkSize) {
              var permissionsBatch = userPermissions.slice(i, i + chunkSize);
              var result = karate.call('classpath:common/eureka/capabilities.feature@getCapabilities', {userPermissions: permissionsBatch});
              var foundCapabilities = result.response.capabilities;

              // Track which permissions were found
              for (let j = 0; j < foundCapabilities.length; j++) {
                permissionsFound.push(foundCapabilities[j].permission);
              }

              // Add capability IDs
              capabilityIds = capabilityIds.concat(foundCapabilities.map(x => x.id));
            }

            // Find missing permissions
            missingPermissions = permissions.filter(p => !permissionsFound.includes(p));

            karate.log('capabilityIds: # #', capabilityIds.length, capabilityIds);
            if (missingPermissions.length > 0) {
              karate.log('***** Missing capabilities for permissions: *****');
              for (let i = 0; i < missingPermissions.length; i++) {
                karate.log('Missing capability for permission: ' + missingPermissions[i]);
              }
            }

            if (capabilityIds.length == permissions.length) {
              karate.log('***** All capabilities have been successfully found *****');
              return capabilityIds;
            }

            count--;
            if (count == 0) {
              karate.log('***** Not all capabilities found. Missing ' + missingPermissions.length + ' capabilities *****');
              return capabilityIds;
            }

            java.lang.Thread.sleep(interval);
          }
        }
        """
    * def capabilityIds = call waitUntil retryCount

    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    * def accesstoken = karate.get('accessToken')
    * def userId = karate.get('userId')

    * print "send userCapability request"
    Given path 'users', 'capabilities'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And request { "userId": '#(userId)', "capabilityIds" : '#(capabilityIds)' }
    When method POST
    Then status 201

    * print "---add capability sets for test user---"
    * def loadCapabilitySetIds =
    """
      function() {
        var capabilitySetIds = []
        var chunkSize = 50;
        for (let i = 0; i < permissions.length; i += chunkSize) {
          var permissionsBatch = userPermissions.slice(i, i + chunkSize);
          var result = karate.call('classpath:common/eureka/capabilities.feature@getCapabilitySets', {userPermissions: permissionsBatch});
          var foundCapabilitySets = result.response.capabilitySets;
          capabilitySetIds = capabilitySetIds.concat(foundCapabilitySets.map(x => x.id));
        }

        return capabilitySetIds;
      }
    """
    * def capabilitySetIds = call loadCapabilitySetIds
    * if (capabilitySetIds.length == 0) karate.log('No capability sets found for the user');
    * if (capabilitySetIds.length > 0) karate.call('classpath:common/eureka/capabilities.feature@postCapabilitySets', {capabilitySetIds: capabilitySetIds});
