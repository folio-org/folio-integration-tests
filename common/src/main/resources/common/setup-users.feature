Feature: prepare data for api test


  Background:
    * url baseUrl
    * configure readTimeout = 3000000

  Scenario: create new tenant
    * print "---create new tenant---"
    Given call read('classpath:common/tenant.feature@create') { tenantId: '#(testTenantId)', tenantName: '#(testTenant)'}

  Scenario: create entitlement
    * print "---create entitlement---"
    * call read('classpath:common/application.feature@applicationsearch')
    * def entitlementTamplate = read('classpath:common/samples/entitlement-entity.json')
    Given url baseUrl
    Given path 'entitlements'
    And request entitlementTamplate
    When method POST

    * configure retry = { count: 20, interval: 30000 }
    Given path 'entitlement-flows'
    And param query = 'tenantId==' + testTenantId
    And retry until responseStatus == 200 && response.flows[0].status == "finished"
    When method GET

  Scenario: get authorization token for new tenant
    * print "---extracting authorization token---"
    Given url baseKeycloakUrl
    And path 'realms', 'master', 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = 'folio-backend-admin-client'
    And form field client_secret = clientSecret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * def accessToken = response.access_token

    Given url baseKeycloakUrl
    And path 'admin', 'realms', testTenant, 'clients'
    And header Authorization = 'Bearer ' + accessToken
    When method GET
    Then status 200
    * def clientId = response.filter(x => x.clientId == 'sidecar-module-access-client')[0].id

    Given url baseKeycloakUrl
    And path 'admin', 'realms', testTenant, 'clients', clientId, 'client-secret'
    And header Authorization = 'Bearer ' + accessToken
    When method GET

  Scenario: add permissions for test user
    * print "---add permissions for test user---"
    * def accesstoken = karate.get('accessToken')
    * def userId = karate.get('userId')
    * def permissions = $userPermissions[*].name
    * def queryParam = function(field, values) { return '(' + field + '==(' + values.map(x => '"' + x + '"').join(' or ') + '))' }

    * print "search requered capabilities ids"
    Given path 'capabilities'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And param query = queryParam('permission', permissions)
    When method GET
    Then status 200
    * def capabilityIds = response.capabilities.map(x => x.id)

    * print "send userCapability request"
    Given path 'users', 'capabilities'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And request { "userId": '#(userId)', "capabilityIds" : '#(capabilityIds)' }
    When method POST
    Then status 201
