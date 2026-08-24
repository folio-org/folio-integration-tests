Feature: validate desired-state entitlement requests

  Background:
    * url baseUrl
    * def setup = karate.setupOnce()
    * if (setup.flowStatus != 'finished') karate.fail('Entitlement setup flow did not finish: ' + setup.flowStatus)
    * def masterToken = setup.masterToken
    * def currentApplicationId = setup.applicationId
    * def currentApplicationName = setup.applicationName

  @setup
  Scenario: prepare data for desired-state entitlement validation
    # Establish the tenant's initial entitlement state.
    * url baseUrl
    * configure readTimeout = 3000000
    * def applicationName = 'app-platform-minimal'
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token

    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(testTenantId)', tenantName: '#(testTenant)' }

    Given path 'applications'
    And param query = '(name=="' + applicationName + '")'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.applicationDescriptors != '#[0]'
    * def applicationId = response.applicationDescriptors[0].id

    Given path 'entitlements'
    And param async = true
    And request { tenantId: '#(testTenantId)', applications: ['#(applicationId)'] }
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method post
    Then status 201
    * def flowId = response.flowId

    Given path 'entitlement-flows', flowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    * configure retry = { count: 40, interval: 15000 }
    * retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method get
    Then status 200
    * def flowStatus = response.status

  @Positive
  Scenario: validate a desired-state upgrade request
    # Requests a higher version of the entitled application, creating an upgrade bucket.
    Given path 'entitlements', 'validate'
    And param entitlementRequestType = 'state'
    And param validator = 'ApplicationFlowValidator'
    And header Authorization = 'Bearer ' + masterToken
    And request { tenantId: '#(testTenantId)', applications: ['#(currentApplicationName + "-999.0.0")'] }
    When method post
    Then status 204

  @Negative
  Scenario: reject a desired-state upgrade to a lower version
    # A lower version than the entitled application is not a valid upgrade.
    * def lowerVersionApplicationId = currentApplicationName + '-0.0.1'
    Given path 'entitlements', 'validate'
    And param entitlementRequestType = 'state'
    And param validator = 'ApplicationFlowValidator'
    And header Authorization = 'Bearer ' + masterToken
    And request { tenantId: '#(testTenantId)', applications: ['#(lowerVersionApplicationId)'] }
    When method post
    Then status 400
    And match response.errors[0].code == 'validation_error'
    And match response.errors[0].message == 'Invalid applications provided for upgrade'

  @Negative
  Scenario: reject a desired-state request with an invalid application version
    # Application IDs in a desired state must contain a valid semantic version.
    * def invalidApplicationId = currentApplicationName + '-invalid'
    Given path 'entitlements', 'validate'
    And param entitlementRequestType = 'state'
    And param validator = 'ApplicationFlowValidator'
    And header Authorization = 'Bearer ' + masterToken
    And request { tenantId: '#(testTenantId)', applications: ['#(invalidApplicationId)'] }
    When method post
    Then status 400
    And match response.errors[0].code == 'validation_error'
    And match response.errors[0].type == 'IllegalArgumentException'
    And match response.errors[0].message == 'Invalid semantic version: source = ' + invalidApplicationId

  @Positive
  Scenario: validate a desired-state entitle request
    # Keeps the current entitlement and adds a new application, creating an entitle bucket.
    Given path 'entitlements', 'validate'
    And param entitlementRequestType = 'state'
    And param validator = 'ApplicationFlowValidator'
    And header Authorization = 'Bearer ' + masterToken
    And request { tenantId: '#(testTenantId)', applications: ['#(currentApplicationId)', 'state-validation-entitle-1.0.0'] }
    When method post
    Then status 204

  @Positive
  Scenario: validate a desired-state revoke request
    # The setup entitles currentApplicationId. Omitting it from the desired state places it in the revoke bucket,
    # while the replacement application keeps the desired state non-empty. This invokes desired-state revoke validation.
    Given path 'entitlements', 'validate'
    And param entitlementRequestType = 'state'
    And param validator = 'ApplicationFlowValidator'
    And header Authorization = 'Bearer ' + masterToken
    And request { tenantId: '#(testTenantId)', applications: ['state-validation-replacement-1.0.0'] }
    When method post
    Then status 204
