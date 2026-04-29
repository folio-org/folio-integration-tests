Feature: Ensure FQM entity types are consistently installed for ECS tenants

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 3, interval: 15000 }
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'

  @InstallFqmEntityTypesForTenant
  Scenario: Install and verify FQM entity types for a tenant
    * print 'Install FQM entity types for tenant ' + tenant
    * call login user
    * configure retry = { count: 3, interval: 15000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    Given path 'entity-types', 'install'
    And param forceUpdateViews = true
    When method POST
    Then status 204

    Given path 'entity-types', instanceEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200

    Given path 'entity-types', holdingsEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200
