@ignore
Feature: submit entitlement flows and wait for them to finish

  # Each scenario submits an async request and polls the flow to a terminal state. Args: tenantId, applicationId,
  # masterToken. Returns flowResponse (the final flow, including stages).

  Background:
    * url baseUrl
    * configure readTimeout = 3000000

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
