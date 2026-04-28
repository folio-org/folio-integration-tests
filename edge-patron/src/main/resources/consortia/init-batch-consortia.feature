@parallel=false
Feature: Initialize batch ECS request data

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Prepare data for batch
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }

    # Evict mod-search stale USER_TENANTS_CACHE (populated during @InstallApplications before consortium setup)
    # BEFORE creating items. This ensures Kafka events from inventory creation are processed with a fresh
    # central-tenant lookup, so university tenant items are indexed in the central OpenSearch index
    # (not in the university's own index).
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then status 200

    * call read('classpath:utils/inventory.feature')
    * call read('classpath:utils/inventory-university.feature')

    # Share university instance to central tenant to enable mod-search consortium item search indexing.
    # Headers must use universityTenantName so the final source='CONSORTIUM-FOLIO' check runs in the source tenant.
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json, text/plain' }
    * configure retry = { count: 30, interval: 5000 }
    * call read('classpath:reusable/shareInstance.feature') { instanceId: '#(universityInstanceId)', sourceTenantId: '#(universityTenantName)', targetTenantId: '#(centralTenantName)', consortiumId: '#(consortiumId)' }

    * call read('classpath:utils/configuration.feature')
    * call karate.read('classpath:reusable/createLoanPolicies.feature')

    # Setup circulation policies and rules for university tenant
    # Required for mod-tlr secondary request creation (Page/Recall/Hold in university tenant).
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json, text/plain' }

    * call karate.read('classpath:reusable/createLoanPolicies.feature')

    # Create patron group in central tenant
    * def ecsPatronGroupId = 'ac34d2dc-0010-1111-bbbb-6f7264657273'
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    Given path 'groups'
    And request { "id": "#(ecsPatronGroupId)", "group": "ecs-patron", "desc": "ECS patron group for consortium requests" }
    When method POST
    * print 'POST groups central status:', responseStatus
    * if (responseStatus != 201 && responseStatus != 422) karate.fail('Unexpected status creating patron group in central tenant: ' + responseStatus)

    # update central user to have the created patron group
    Given path 'users', centralUser.id
    When method GET
    Then status 200
    * def centralUserRecord = response
    * centralUserRecord.patronGroup = ecsPatronGroupId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'text/plain' }
    Given path 'users', centralUser.id
    And request centralUserRecord
    When method PUT
    Then status 204

    # enable title-level requests (TLR) feature
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def tlrConfig = read('classpath:consortia/samples/tlr-config-entry-request.json')
    Given path 'circulation/settings'
    And request tlrConfig
    When method POST
    Then status 201

    # enable Multi-Item Requesting Feature setting for the patron to get batch request information in the response of patron/account API
    Given path 'patron/settings'
    And request
      """
      {
        "scope": "mod-patron",
        "key": "isMultiItemRequestingFeatureEnabled",
        "value": {
          "enabled": "true"
        }
      }
      """
    When method POST
    Then status 201

    # Create same patron group in university tenant
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    Given path 'groups'
    And request { "id": "#(ecsPatronGroupId)", "group": "ecs-patron", "desc": "ECS patron group for consortium requests" }
    When method POST
    * if (responseStatus != 201 && responseStatus != 422) karate.fail('Unexpected status creating patron group in university tenant: ' + responseStatus)

