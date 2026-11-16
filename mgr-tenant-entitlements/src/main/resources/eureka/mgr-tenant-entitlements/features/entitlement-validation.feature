Feature: validation of entitlement requests (entitlement-validation)

  # POST /entitlements/validate dry-runs the validators that the entitle, upgrade, revoke and state flows apply.
  # Covers all four request types, each with the whole validator chain and/or a single named validator.
  # The tenant is entitled to appName in the Background, so it is the "current" application.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def support = 'classpath:eureka/mgr-tenant-entitlements/util/entitlement-test-support.feature'
    * def appName = 'app-platform-minimal'
    * def otherAppName = 'app-licenses'
    * def setup = callonce read(support + '@createEntitledTenant') { masterToken: '#(masterToken)', applicationName: '#(appName)', tenantPrefix: 'entval' }
    * def tenantId = setup.tenantId
    * def entitledAppId = setup.applicationId
    * configure afterFeature = function() { karate.call(support + '@deleteEntitledTenant', { masterToken: masterToken, tenantId: tenantId }) }
    * def otherApp = callonce read(support + '@findApplicationId') { masterToken: '#(masterToken)', applicationName: '#(otherAppName)' }
    * def otherAppId = otherApp.applicationId

  @Positive
  Scenario: validate an entitle request with the interface integrity validator
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'entitle', validator: 'InterfaceIntegrityValidator', tenantId: '#(tenantId)', applications: ['#(otherAppId)'] }

  @Positive
  Scenario: validate an entitle request with all validators
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'entitle', tenantId: '#(tenantId)', applications: ['#(otherAppId)'] }

  @Positive
  Scenario: validate an upgrade request to a higher version of the entitled application
    # Only the request validator is named: it compares names and versions, so the target version need not be registered.
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'upgrade', validator: 'UpgradeRequestValidator', tenantId: '#(tenantId)', applications: ['#(appName + "-999.0.0")'] }

  @Positive
  Scenario: validate a revoke request with the existing entitlement validator
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'revoke', validator: 'ExistingEntitlementValidator', tenantId: '#(tenantId)', applications: ['#(entitledAppId)'] }

  @Positive
  Scenario: validate a revoke request with all validators
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'revoke', tenantId: '#(tenantId)', applications: ['#(entitledAppId)'] }

  @Positive
  Scenario: validate a desired state request with all validators
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'state', tenantId: '#(tenantId)', applications: ['#(entitledAppId)', '#(otherAppId)'] }

  @Positive
  Scenario: validate a desired-state upgrade request
    # Requests a higher version of the entitled application, creating an upgrade bucket.
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'state', validator: 'ApplicationFlowValidator', tenantId: '#(tenantId)', applications: ['#(appName + "-999.0.0")'] }

  @Positive
  Scenario: validate a desired-state entitle request
    # Keeps the current entitlement and adds a new application, creating an entitle bucket.
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'state', validator: 'ApplicationFlowValidator', tenantId: '#(tenantId)', applications: ['#(entitledAppId)', 'state-validation-entitle-1.0.0'] }

  @Positive
  Scenario: validate a desired-state revoke request
    # Omitting the entitled application from the desired state places it in the revoke bucket, while the replacement
    # application keeps the desired state non-empty. This invokes desired-state revoke validation.
    * call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'state', validator: 'ApplicationFlowValidator', tenantId: '#(tenantId)', applications: ['state-validation-replacement-1.0.0'] }

  @Negative
  Scenario: reject a desired-state upgrade to a lower version
    # A lower version than the entitled application is not a valid upgrade.
    * def result = call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'state', validator: 'ApplicationFlowValidator', tenantId: '#(tenantId)', applications: ['#(appName + "-0.0.1")'], expectedStatus: 400 }
    * match result.response.errors[0].code == 'validation_error'
    * match result.response.errors[0].message == 'Invalid applications provided for upgrade'

  @Negative
  Scenario: reject a desired-state request with an invalid application version
    # Application IDs in a desired state must contain a valid semantic version.
    * def invalidApplicationId = appName + '-invalid'
    * def result = call read(support + '@validateEntitlement') { masterToken: '#(masterToken)', type: 'state', validator: 'ApplicationFlowValidator', tenantId: '#(tenantId)', applications: ['#(invalidApplicationId)'], expectedStatus: 400 }
    * match result.response.errors[0].code == 'validation_error'
    * match result.response.errors[0].type == 'IllegalArgumentException'
    * match result.response.errors[0].message == 'Invalid semantic version: source = ' + invalidApplicationId
