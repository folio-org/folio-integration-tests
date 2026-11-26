Feature: Keycloak custom login and identity provider api tests

  # Covers:
  #   DELETE /consortia/{consortiumId}/tenants/{tenantId}/custom-login
  #   POST /consortia/{consortiumId}/tenants/{tenantId}/identity-provider with optional 'baseUrl'
  # Keycloak is changed only when unified login (SINGLE_TENANT_UX) is enabled, so scenarios that verify
  # created flows / identity providers are skipped when it is disabled on the environment.

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # keycloak helpers
    * def kc = 'classpath:thunderjet/mod-consortia/features/reusable/keycloak-admin.feature'
    * def browserFlowOf = function(realm) { return karate.call(kc + '@GetBrowserFlow', { realm: realm }).browserFlow }
    * def flowsOf = function(realm) { return karate.call(kc + '@GetFlowAliases', { realm: realm }).flowAliases }
    * def bindBrowserFlow = function(realm, flow) { karate.call(kc + '@BindBrowserFlow', { realm: realm, flow: flow }) }
    * def collegeIdp = function() { return karate.call(kc + '@GetIdentityProvider', { realm: centralTenant, alias: collegeTenant + '-keycloak-oidc' }) }
    * def idpUrlsOf = function(config) { return karate.filterKeys(config, ['issuer', 'authorizationUrl', 'tokenUrl', 'logoutUrl', 'userInfoUrl', 'jwksUrl']) }
    * def expectedIdpUrls =
      """
      function(baseUrl) {
        var realmUrl = baseUrl + '/realms/' + collegeTenant;
        var oidcUrl = realmUrl + '/protocol/openid-connect';
        return { issuer: realmUrl, authorizationUrl: oidcUrl + '/auth', tokenUrl: oidcUrl + '/token',
                 logoutUrl: oidcUrl + '/logout', userInfoUrl: oidcUrl + '/userinfo', jwksUrl: oidcUrl + '/certs' };
      }
      """

    # identity provider of a member tenant is created on tenant setup only if unified login is enabled
    * def initialIdp = callonce collegeIdp
    * def unifiedLoginEnabled = initialIdp.idpStatus == 200
    * print 'Unified login enabled: ', unifiedLoginEnabled

  @Positive
  Scenario: Remove custom login of central tenant and set it up again
    * if (!unifiedLoginEnabled) karate.abort()

    Given path 'consortia', consortiumId, 'tenants', centralTenant, 'custom-login'
    When method DELETE
    Then status 204
    And match browserFlowOf(centralTenant) == 'browser'
    And match flowsOf(centralTenant) !contains 'custom-browser'

    # repeated removal does nothing
    Given path 'consortia', consortiumId, 'tenants', centralTenant, 'custom-login'
    When method DELETE
    Then status 204

    Given path 'consortia', consortiumId, 'tenants', centralTenant, 'custom-login'
    When method POST
    Then status 201
    And match browserFlowOf(centralTenant) == 'custom-browser'
    And match flowsOf(centralTenant) contains 'custom-browser'

  @Positive
  Scenario: Remove custom login flow that exists but is not bound to the realm
    * if (!unifiedLoginEnabled) karate.abort()

    # set up custom login from scratch, then unbind it directly in keycloak
    Given path 'consortia', consortiumId, 'tenants', centralTenant, 'custom-login'
    When method DELETE
    Then status 204

    Given path 'consortia', consortiumId, 'tenants', centralTenant, 'custom-login'
    When method POST
    Then status 201

    * bindBrowserFlow(centralTenant, 'browser')
    * match flowsOf(centralTenant) contains 'custom-browser'

    Given path 'consortia', consortiumId, 'tenants', centralTenant, 'custom-login'
    When method DELETE
    Then status 204
    And match browserFlowOf(centralTenant) == 'browser'
    And match flowsOf(centralTenant) !contains 'custom-browser'

  @Positive
  Scenario: Create identity provider with provided base URL
    * if (!unifiedLoginEnabled) karate.abort()

    Given path 'consortia', consortiumId, 'tenants', collegeTenant, 'identity-provider'
    When method DELETE
    Then status 204

    Given path 'consortia', consortiumId, 'tenants', collegeTenant, 'identity-provider'
    And request { createProvider: true, migrateUsers: true, baseUrl: 'https://college.example.org/' }
    When method POST
    Then status 201
    And match idpUrlsOf(collegeIdp().idp.config) == expectedIdpUrls('https://college.example.org')

    # without base URL identity provider is created with configured base URL
    Given path 'consortia', consortiumId, 'tenants', collegeTenant, 'identity-provider'
    When method DELETE
    Then status 204

    Given path 'consortia', consortiumId, 'tenants', collegeTenant, 'identity-provider'
    And request { createProvider: true, migrateUsers: true }
    When method POST
    Then status 201
    And match idpUrlsOf(collegeIdp().idp.config) == idpUrlsOf(initialIdp.idp.config)

  @Positive
  Scenario: Existing identity provider is not changed by request with another base URL
    * if (!unifiedLoginEnabled) karate.abort()

    Given path 'consortia', consortiumId, 'tenants', collegeTenant, 'identity-provider'
    And request { createProvider: true, migrateUsers: false, baseUrl: 'https://another.example.org' }
    When method POST
    Then status 201
    And match idpUrlsOf(collegeIdp().idp.config) == idpUrlsOf(initialIdp.idp.config)

  @Negative
  Scenario: Attempt to remove custom login with non-existing consortium or tenant
    Given path 'consortia', uuid(), 'tenants', centralTenant, 'custom-login'
    When method DELETE
    Then status 404

    Given path 'consortia', consortiumId, 'tenants', 'non-existing-tenant', 'custom-login'
    When method DELETE
    Then status 404

  @Negative
  Scenario: Attempt to create identity provider with invalid base URL
    Given path 'consortia', consortiumId, 'tenants', collegeTenant, 'identity-provider'
    And request { createProvider: true, migrateUsers: true, baseUrl: 'college.example.org' }
    When method POST
    Then status 422
    And match response.errors[0].message contains 'baseUrl'
