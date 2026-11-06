Feature: entitlement of modules that provide no interfaces without discovery information

  # MGRENTITLE-210: a module whose descriptor has an empty `provides` has no routes, so entitlement must not
  # require discovery information for it. A module that declares `provides` still requires discovery.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def v1 = '1.0.0'
    * def v2 = '2.0.0'

  @Positive
  Scenario: entitle, upgrade and revoke an application whose only module has no provides and no discovery
    * def suffix = nowMillis()
    * def appName = 'it-virtual-app-' + suffix
    * def moduleName = 'it-virtual-module-' + suffix
    * def tenantId = uuid()
    * def tenantName = 'virtual' + suffix

    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    # Register both versions without any discovery information: the modules have no `provides`.
    * def registeredV1 = call read('@registerApplication') { applicationName: '#(appName)', version: '#(v1)', moduleName: '#(moduleName)', masterToken: '#(masterToken)' }
    * def registeredV2 = call read('@registerApplication') { applicationName: '#(appName)', version: '#(v2)', moduleName: '#(moduleName)', masterToken: '#(masterToken)' }
    * def appIdV1 = registeredV1.applicationId
    * def appIdV2 = registeredV2.applicationId

    # The same endpoint entitlement uses to load discovery: the application must have none.
    Given path 'applications', appIdV1, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.totalRecords == 0

    # AC1: entitle succeeds without discovery.
    * def entitled = call read('@submitEntitle') { tenantId: '#(tenantId)', applicationId: '#(appIdV1)', masterToken: '#(masterToken)' }
    * match entitled.flowResponse.status == 'finished'

    # AC3: upgrade succeeds without discovery for either version.
    * def upgraded = call read('@submitUpgrade') { tenantId: '#(tenantId)', applicationId: '#(appIdV2)', masterToken: '#(masterToken)' }
    * match upgraded.flowResponse.status == 'finished'

    Given path 'entitlements'
    And param query = 'tenantId==' + tenantId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match karate.map(response.entitlements, e => e.applicationId) == ['#(appIdV2)']

    # AC3: revoke succeeds without discovery.
    * def revoked = call read('@submitRevoke') { tenantId: '#(tenantId)', applicationId: '#(appIdV2)', masterToken: '#(masterToken)' }
    * match revoked.flowResponse.status == 'finished'

    Given path 'entitlements'
    And param query = 'tenantId==' + tenantId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.totalRecords == 0

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }
    * call read('@deleteApplication') { applicationId: '#(appIdV1)', masterToken: '#(masterToken)' }
    * call read('@deleteApplication') { applicationId: '#(appIdV2)', masterToken: '#(masterToken)' }

  @Negative
  Scenario: entitlement fails for a module that declares provides and has no discovery
    * def suffix = nowMillis()
    * def appName = 'it-provides-app-' + suffix
    * def moduleName = 'it-provides-module-' + suffix
    * def tenantId = uuid()
    * def tenantName = 'provides' + suffix

    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    # AC2: the module declares an interface, so discovery is required and none is registered.
    * def providesDescriptor = [{ id: 'it-provides-api', version: '1.0', handlers: [{ methods: ['GET'], pathPattern: '#("/" + moduleName + "/{id}")' }] }]
    * def registered = call read('@registerApplication') { applicationName: '#(appName)', version: '#(v1)', moduleName: '#(moduleName)', provides: '#(providesDescriptor)', masterToken: '#(masterToken)' }
    * def appId = registered.applicationId

    * def entitled = call read('@submitEntitle') { tenantId: '#(tenantId)', applicationId: '#(appId)', masterToken: '#(masterToken)' }
    * def flowResponse = entitled.flowResponse
    * match flowResponse.status == '#? _ == "failed" || _ == "cancelled"'

    * def allStages = $flowResponse.applicationFlows[*].stages[*]
    * def loaderStages = karate.filter(allStages, s => s.name.endsWith('ApplicationDiscoveryLoader'))
    * match loaderStages == '#[1]'
    * match loaderStages[0].status == 'failed'
    * match loaderStages[0].errorMessage contains 'Module discovery information is not found for application: ' + appId

    Given path 'entitlements'
    And param query = 'tenantId==' + tenantId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.totalRecords == 0

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }
    * call read('@deleteApplication') { applicationId: '#(appId)', masterToken: '#(masterToken)' }

  @ignore @registerApplication
  Scenario: register an application with a single module, optionally with provides, and no discovery
    * def provides = __arg.provides || []
    * def moduleId = __arg.moduleName + '-' + __arg.version
    * def applicationId = __arg.applicationName + '-' + __arg.version
    * def applicationDescriptor =
      """
      {
        "name": "#(__arg.applicationName)",
        "version": "#(__arg.version)",
        "modules": [ { "id": "#(moduleId)", "name": "#(__arg.moduleName)", "version": "#(__arg.version)" } ],
        "moduleDescriptors": [ { "id": "#(moduleId)", "name": "#(__arg.moduleName)", "provides": "#(provides)" } ]
      }
      """
    Given path 'applications'
    And param check = true
    And header Authorization = 'Bearer ' + __arg.masterToken
    And request applicationDescriptor
    When method post
    Then status 201

  @ignore @deleteApplication
  Scenario: delete a registered application
    Given path 'applications', __arg.applicationId
    And header Authorization = 'Bearer ' + __arg.masterToken
    And header X-Okapi-Token = __arg.masterToken
    When method delete
    Then status 204

  @ignore @submitEntitle
  Scenario: submit an entitle request and wait for the flow to reach a terminal state
    Given path 'entitlements'
    And param async = true
    And param purgeOnRollback = false
    And request { tenantId: '#(__arg.tenantId)', applications: ['#(__arg.applicationId)'] }
    And header Authorization = 'Bearer ' + __arg.masterToken
    And header X-Okapi-Token = __arg.masterToken
    When method post
    Then status 201
    * def waited = call read('@waitForFlow') { flowId: '#(response.flowId)', masterToken: '#(__arg.masterToken)' }
    * def flowResponse = waited.flowResponse

  @ignore @submitUpgrade
  Scenario: submit an upgrade request and wait for the flow to reach a terminal state
    Given path 'entitlements'
    And param async = true
    And request { tenantId: '#(__arg.tenantId)', applications: ['#(__arg.applicationId)'] }
    And header Authorization = 'Bearer ' + __arg.masterToken
    And header X-Okapi-Token = __arg.masterToken
    When method put
    Then status 200
    * def waited = call read('@waitForFlow') { flowId: '#(response.flowId)', masterToken: '#(__arg.masterToken)' }
    * def flowResponse = waited.flowResponse

  @ignore @submitRevoke
  Scenario: submit a revoke request and wait for the flow to reach a terminal state
    Given path 'entitlements'
    And param async = true
    And param purge = true
    And request { tenantId: '#(__arg.tenantId)', applications: ['#(__arg.applicationId)'] }
    And header Authorization = 'Bearer ' + __arg.masterToken
    And header X-Okapi-Token = __arg.masterToken
    When method delete
    Then status 200
    * def waited = call read('@waitForFlow') { flowId: '#(response.flowId)', masterToken: '#(__arg.masterToken)' }
    * def flowResponse = waited.flowResponse

  @ignore @waitForFlow
  Scenario: poll an entitlement flow until it reaches a terminal state
    * configure retry = { count: 40, interval: 15000 }
    Given path 'entitlement-flows', __arg.flowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + __arg.masterToken
    * retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method get
    Then status 200
    * def flowResponse = response
