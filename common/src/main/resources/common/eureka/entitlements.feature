Feature: prepare data for api test


  Background:
    * url baseUrl
    * configure readTimeout = 3000000

  @createEntitlementResponse
  Scenario: create entitlement response
    * print "---create entitlement response---"
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
    * def response = response