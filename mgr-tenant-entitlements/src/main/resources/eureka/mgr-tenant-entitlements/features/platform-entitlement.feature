@parallel=false
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
  Scenario: entitle - a platform application is entitled and the repeated request completes
    * def name = 'platform-app-entitle-' + nowMillis()
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
  Scenario: entitle - a second version is rejected while another version is entitled
    * def name = 'platform-app-second-' + nowMillis()
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
  Scenario: upgrade - the entitled version is replaced and the same upgrade can be repeated
    * def name = 'platform-app-upgrade-' + nowMillis()
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
  Scenario: upgrade - a new version that breaks a dependent platform application is rejected
    # dependent-1.0.0 requires base ^1.0.0, so base 2.0.0 must be rejected.
    * def suffix = nowMillis()
    * def baseName = 'platform-app-base-' + suffix
    * def dependentName = 'platform-app-dependent-' + suffix
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

  @Positive
  Scenario: entitle - an application is entitled without its optional dependency
    * def suffix = nowMillis()
    * def optionalName = 'platform-app-optional-' + suffix
    * def dependentName = 'platform-app-optional-dependent-' + suffix
    * def dependencies = [{ name: '#(optionalName)', version: '^1.0.0', optional: true }]
    * def optionalParent = call read(registerApp) { masterToken: '#(masterToken)', name: '#(optionalName)', version: '1.0.0', scope: 'platform' }
    * def dependent = call read(registerApp) { masterToken: '#(masterToken)', name: '#(dependentName)', version: '1.0.0', scope: 'platform', dependencies: '#(dependencies)' }

    # the optional parent is not entitled, and the dependent is still accepted
    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(dependent.id)'] }
    When method post
    Then status 201
    And match response.platformEntitlements[*].applicationId == [ '#(dependent.id)' ]

    Given path 'entitlement-flows', response.flowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'finished'

  @Negative
  Scenario: entitle - an application is rejected without its required dependency
    * def suffix = nowMillis()
    * def requiredName = 'platform-app-required-' + suffix
    * def dependentName = 'platform-app-required-dependent-' + suffix
    * def dependencies = [{ name: '#(requiredName)', version: '^1.0.0' }]
    * def requiredParent = call read(registerApp) { masterToken: '#(masterToken)', name: '#(requiredName)', version: '1.0.0', scope: 'platform' }
    * def dependent = call read(registerApp) { masterToken: '#(masterToken)', name: '#(dependentName)', version: '1.0.0', scope: 'platform', dependencies: '#(dependencies)' }

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(dependent.id)'] }
    When method post
    Then status 400
    * def failedFlowId = responseHeaders[flowIdHeader][0]

    Given path 'entitlement-flows', failedFlowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'cancelled'

  @Positive
  Scenario: upgrade - a new version outside the range of an optional dependent is accepted
    # dependent-1.0.0 optionally uses base ^1.0.0, so base 2.0.0 does not block the upgrade.
    * def suffix = nowMillis()
    * def baseName = 'platform-app-opt-base-' + suffix
    * def dependentName = 'platform-app-opt-dependent-' + suffix
    * def base1 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(baseName)', version: '1.0.0', scope: 'platform' }
    * def base2 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(baseName)', version: '2.0.0', scope: 'platform' }
    * def dependencies = [{ name: '#(baseName)', version: '^1.0.0', optional: true }]
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
    Then status 200
    And match response.platformEntitlements[*].applicationId == [ '#(base2.id)' ]

    Given path 'entitlement-flows', response.flowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'finished'
    And match response.type == 'platform_upgrade'

  @Negative
  Scenario: entitle - regular applications are rejected on the platform endpoint
    * def suffix = nowMillis()
    * def regularName = 'regular-app-' + suffix
    * def platformName = 'platform-app-mixed-' + suffix
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
  Scenario: entitle - a platform application is rejected in a desired-state write
    * def suffix = nowMillis()
    * def stateName = 'platform-app-state-' + suffix
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

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }

  @Negative
  Scenario: entitle - a platform application is rejected in a tenant entitle request
    * def suffix = nowMillis()
    * def tenantEntitleName = 'platform-app-tenant-entitle-' + suffix
    * def tenantName = 'platformtenantent' + suffix
    * def platform = call read(registerApp) { masterToken: '#(masterToken)', name: '#(tenantEntitleName)', version: '1.0.0', scope: 'platform' }
    * def tenantId = uuid()
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    Given path 'entitlements'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(platform.id)'] }
    When method post
    Then status 400
    And match karate.toString(response) contains 'Tenant request contains platform-scoped applications'
    * def entitleFlowId = responseHeaders[flowIdHeader][0]

    Given path 'entitlement-flows', entitleFlowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'cancelled'

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }

  @Negative
  Scenario: upgrade - a regular application upgraded to a platform-scoped version is rejected
    # v1 is entitled while the application is regular, v2 of the same application is platform-scoped.
    * def suffix = nowMillis()
    * def upgradeName = 'platform-app-tenant-upgrade-' + suffix
    * def tenantName = 'platformtenantupg' + suffix
    * def v1 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(upgradeName)', version: '1.0.0', scope: 'regular' }
    * def v2 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(upgradeName)', version: '2.0.0', scope: 'platform' }
    * def tenantId = uuid()
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    Given path 'entitlements'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(v1.id)'] }
    When method post
    Then status 201

    Given path 'entitlements'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(v2.id)'] }
    When method put
    Then status 400
    And match karate.toString(response) contains 'Tenant request contains platform-scoped applications'
    * def upgradeFlowId = responseHeaders[flowIdHeader][0]

    # PUT /entitlements always runs with ignoreErrors=true, so the flow is failed, not cancelled
    Given path 'entitlement-flows', upgradeFlowId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.status == 'failed'

    # the tenant keeps the regular version: revoking v1 succeeds only while its entitlement exists,
    # so this also cleans up
    Given path 'entitlements'
    And param purge = true
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(v1.id)'] }
    When method delete
    Then status 200

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }

  @Negative
  Scenario: entitle and upgrade - platform requests are rejected while a tenant entitlement is in progress
    # A platform request fails fast with 409 and Retry-After while any tenant flow is not terminal.
    * def suffix = nowMillis()
    * def name = 'platform-app-busy-' + suffix
    * def v1 = call read(registerApp) { masterToken: '#(masterToken)', name: '#(name)', version: '1.0.0', scope: 'platform' }
    * def tenantId = uuid()
    * def tenantName = 'platformbusy' + suffix
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    # app-platform-minimal has many modules, which keeps the tenant flow running long enough to send the platform requests
    Given path 'applications'
    And param query = '(name=="app-platform-minimal")'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.applicationDescriptors == '#[1]'
    * def applicationIds = karate.map(response.applicationDescriptors, d => d.id)

    Given path 'entitlements'
    And param async = true
    And param tenantParameters = 'loadReference=true'
    And param purgeOnRollback = false
    And request { tenantId: '#(tenantId)', applications: '#(applicationIds)' }
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method post
    Then status 201
    * def tenantFlowId = response.flowId

    # in async mode the flow row is written after the response, so wait until the flow is in progress
    * configure retry = { count: 20, interval: 500 }
    Given path 'entitlement-flows', tenantFlowId
    And header Authorization = 'Bearer ' + masterToken
    * retry until responseStatus == 200 && response.status == 'in_progress'
    When method get
    Then status 200

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method post
    Then status 409
    And match responseHeaders['Retry-After'][0] == '#regex [0-9]+'

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method put
    Then status 409
    And match responseHeaders['Retry-After'][0] == '#regex [0-9]+'

    # once the tenant flow is terminal the platform request is accepted
    * configure retry = { count: 30, interval: 5000 }
    Given path 'entitlement-flows', tenantFlowId
    And header Authorization = 'Bearer ' + masterToken
    * retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method get
    Then status 200
    And match response.status == 'finished'

    Given path 'entitlements', 'platform'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { applications: ['#(v1.id)'] }
    When method post
    Then status 201
    And match response.platformEntitlements[*].applicationId == [ '#(v1.id)' ]

    # cleanup: revoke the tenant entitlement and delete the tenant
    Given path 'entitlements'
    And param purge = true
    And param async = true
    And request { tenantId: '#(tenantId)', applications: '#(applicationIds)' }
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 200
    * def revokeFlowId = response.flowId

    Given path 'entitlement-flows', revokeFlowId
    And header Authorization = 'Bearer ' + masterToken
    * retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method get

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }
