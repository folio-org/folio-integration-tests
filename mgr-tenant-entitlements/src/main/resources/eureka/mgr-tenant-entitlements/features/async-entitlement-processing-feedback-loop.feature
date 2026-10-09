Feature: async entitlement processing feedback loop

  # UXPROD-5714: stages stay in_progress until the owning module acks via the
  # resource-result topic. Requires follwing env variables to be set -
  #     EVENT_PUBLISHER_AWAIT_COMPLETION (mgr-tenant-entitlements)
  #     EVENT_CONFIRMATION_ENABLED (mod-roles-keycloak, mod-users-keycloak, mod-scheduler).

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def appPlatformMinimal = 'app-platform-minimal'
    * def appLicenses = 'app-licenses'
    * def appNotification = 'app-notification'
    * def publisherStageSuffixes = ['capabilitiesModuleEventPublisher', 'systemUserModuleEventPublisher', 'scheduledJobModuleEventPublisher']
    # dedicated tenant so this scenario always gets a first-time entitlement, independent of
    # whatever the shared module tenant has already entitled in other feature files.
    * def isolatedTenantId = uuid()
    * def isolatedTenantName = 'asyncfb' + nowMillis()

  @Positive
  Scenario: entitlement flow reports per-stage async processing status through to completion
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(isolatedTenantId)', tenantName: '#(isolatedTenantName)' }

    # Entitle the dedicated tenant to app-platform-minimal, app-licenses and app-notification.
    # Entitling more apps gives more publisher stages a chance to still be in_progress at the poll below.
    Given path 'applications'
    And param query = '(name=="' + appPlatformMinimal + '" or name=="' + appLicenses + '" or name=="' + appNotification + '")'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.applicationDescriptors == '#[3]'
    * def applicationIds = karate.map(response.applicationDescriptors, d => d.id)

    Given path 'entitlements'
    And param async = true
    And param tenantParameters = 'loadReference=true'
    And param purgeOnRollback = false
    And request { tenantId: '#(isolatedTenantId)', applications: '#(applicationIds)' }
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method post
    Then status 201
    * def flowId = response.flowId

    # Most modules' publisher stages have no payload and finish in a few ms; whichever module(s)
    # actually need a system user/scheduled job/capability wait on a real ack. Poll (instead of a
    # blind sleep) until at least one such stage is still in_progress, without depending on any
    # specific module.
    * configure retry = { count: 20, interval: 500 }
    Given path 'entitlement-flows', flowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    * retry until karate.filter(karate.jsonPath(response, '$.applicationFlows[*].stages[*]'), s => publisherStageSuffixes.some(suffix => s.name.endsWith(suffix)) && s.status == 'in_progress').length > 0
    When method get
    Then status 200

    # Now that we've proven a stage was genuinely mid-flight, poll to the flow's terminal state
    # and assert the final shape: every stage has a UUID id, none are left in_progress, and the
    # capability/system-user/scheduled-job stages all ended up finished.
    * configure retry = { count: 80, interval: 15000 }
    Given path 'entitlement-flows', flowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    * retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method get
    Then status 200
    * def flowResponse = response

    * match flowResponse.status == 'finished'
    * def allStages = $flowResponse.applicationFlows[*].stages[*]
    * match allStages == '#[_ > 0]'
    * match each allStages contains { id: '#string', name: '#string', status: '#string' }
    * match each allStages[*].status != 'in_progress'

    * def publisherStages = karate.filter(allStages, s => publisherStageSuffixes.some(suffix => s.name.endsWith(suffix)))
    * match publisherStages == '#[_ > 0]'
    * match each publisherStages contains { id: '#string', name: '#string', status: 'finished' }

    # Cleanup: revoke the entitlement and delete the dedicated tenant created above.
    * configure retry = { count: 40, interval: 15000 }
    Given path 'entitlements'
    And param purge = true
    And param async = true
    And request { tenantId: '#(isolatedTenantId)', applications: '#(applicationIds)' }
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 200
    * def revokeFlowId = response.flowId

    Given path 'entitlement-flows', revokeFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    * retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method get

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(isolatedTenantId)' }
