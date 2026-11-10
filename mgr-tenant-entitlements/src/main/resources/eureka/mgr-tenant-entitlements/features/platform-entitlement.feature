Feature: platform application entitlement

  # POST/PUT /entitlements/platform entitle or upgrade platform-scoped applications for the whole deployment.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def registerApp = 'classpath:eureka/mgr-tenant-entitlements/features/util/platform-app-register.feature'
    * def flowIdHeader = 'x-mgr-tenant-entitlement-flow-id'

  @Positive
  Scenario: entitle a platform application and repeat the request
    * def name = 'it-pa-entitle-' + nowMillis()
    * def app = call read(registerApp) { masterToken: '#(masterToken)', name: '#(name)', version: '1.0.0', scope: 'platform' }

    # entitled for the whole deployment, flow record stored
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(app.id)'] }
    When method post
    Then status 201
    And match response.totalRecords == 1
    And match response.platformEntitlements[*].applicationId == [ '#(app.id)' ]
    * def flowId = response.flowId

    Given path 'entitlement-flows', flowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'finished'
    And match response.type == 'platform_entitle'

    # the repeated request completes without duplicates
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(app.id)'] }
    When method post
    Then status 201
    And match response.totalRecords == 1
    And match response.platformEntitlements[*].applicationId == [ '#(app.id)' ]

    Given path 'entitlement-flows', response.flowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'finished'

  @Negative
  Scenario: reject a second version while another version is entitled
    * def name = 'it-pa-second-' + nowMillis()
    * def v1 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(name)', version: '1.0.0', scope: 'platform' }
    * def v2 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(name)', version: '2.0.0', scope: 'platform' }

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method post
    Then status 201

    # the second version is rejected and the flow is cancelled
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v2.id)'] }
    When method post
    Then status 400
    And match karate.toString(response) contains 'Another version of the application is already entitled'
    * def rejectedFlowId = responseHeaders[flowIdHeader][0]

    Given path 'entitlement-flows', rejectedFlowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'cancelled'

    # The first version is still the only entitled one: its entitle request is still an accepted retry.
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method post
    Then status 201

  @Positive
  Scenario: upgrade replaces the entitled version and the same upgrade can be repeated
    * def name = 'it-pa-upgrade-' + nowMillis()
    * def v1 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(name)', version: '1.0.0', scope: 'platform' }
    * def v2 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(name)', version: '2.0.0', scope: 'platform' }

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method post
    Then status 201

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v2.id)'] }
    When method put
    Then status 200
    And match response.platformEntitlements[*].applicationId == [ '#(v2.id)' ]

    Given path 'entitlement-flows', response.flowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'finished'
    And match response.type == 'platform_upgrade'

    # repeat of the same upgrade
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v2.id)'] }
    When method put
    Then status 200

    # Version 1 is no longer entitled: entitling it is now a second-version conflict with v2.
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method post
    Then status 400
    And match karate.toString(response) contains 'Another version of the application is already entitled'

  @Negative
  Scenario: reject an upgrade whose new version breaks a dependent platform application
    # dependent-1.0.0 requires base ^1.0.0, so base 2.0.0 must be rejected.
    * def suffix = nowMillis()
    * def baseName = 'it-pa-base-' + suffix
    * def dependentName = 'it-pa-dependent-' + suffix
    * def base1 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(baseName)', version: '1.0.0', scope: 'platform' }
    * def base2 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(baseName)', version: '2.0.0', scope: 'platform' }
    * def dependencies = [{ name: '#(baseName)', version: '^1.0.0' }]
    * def dependent = call read(registerApp) { masterToken: '#(masterToken)', name: '#(dependentName)', version: '1.0.0', scope: 'platform', dependencies: '#(dependencies)' }

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(base1.id)', '#(dependent.id)'] }
    When method post
    Then status 201

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(base2.id)'] }
    When method put
    Then status 400
    * def failedFlowId = responseHeaders[flowIdHeader][0]

    Given path 'entitlement-flows', failedFlowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'cancelled'

    # No version change was applied: base 1.0.0 is still entitled, so its entitle request is an accepted retry.
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(base1.id)'] }
    When method post
    Then status 201

  @Negative
  Scenario: reject regular applications on the platform endpoint
    * def suffix = nowMillis()
    * def regularName = 'it-ra-' + suffix
    * def platformName = 'it-pa-mixed-' + suffix
    * def regular = call read(registerApp) { masterToken: '#(masterToken)', name: '#(regularName)', version: '1.0.0', scope: 'regular' }
    * def platform = call read(registerApp) { masterToken: '#(masterToken)', name: '#(platformName)', version: '1.0.0', scope: 'platform' }

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(regular.id)'] }
    When method post
    Then status 400
    And match karate.toString(response) contains 'Application is not platform-scoped'

    # One regular application rejects the whole request, so the platform application is not entitled either.
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(platform.id)', '#(regular.id)'] }
    When method post
    Then status 400
    And match karate.toString(response) contains 'Application is not platform-scoped'
    * def mixedFlowId = responseHeaders[flowIdHeader][0]

    Given path 'entitlement-flows', mixedFlowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'cancelled'

  @Negative
  Scenario: reject a platform application in a desired-state write
    * def suffix = nowMillis()
    * def stateName = 'it-pa-state-' + suffix
    * def tenantName = 'platformstate' + suffix
    * def platform = call read(registerApp) { masterToken: '#(masterToken)', name: '#(stateName)', version: '1.0.0', scope: 'platform' }
    * def tenantId = uuid()
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    Given path 'entitlements', 'state'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(platform.id)'] }
    When method put
    Then status 400
    And match karate.toString(response) contains 'Desired state request contains platform-scoped applications'

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }
