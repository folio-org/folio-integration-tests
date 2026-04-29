Feature: Query member tenant instances in ECS

  Background:
    * url baseUrl
    * configure retry = { count: 3, interval: 10000 }
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def resultFields = ['instance.id', 'instance.title', 'instance.tenant_id', 'instance.shared']

  @Positive
  Scenario: Member tenant instance query returns central shared and member local instances
    * def instanceTypeId = uuid()
    * def sharedInstanceId = uuid()
    * def memberInstanceId = uuid()
    * def sharedInstanceHrid = 'fqm-mi-shared-' + sharedInstanceId
    * def memberInstanceHrid = 'fqm-mi-member-' + memberInstanceId
    * def sharedInstanceTitle = 'ECS shared instance query ' + randomMillis()
    * def sharingId = uuid()
    * def instanceTypeRequest = { id: '#(instanceTypeId)', name: 'ECS integration test type', code: 'ecs-it', source: 'local' }

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * configure retry = { count: 3, interval: 10000 }
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersConsortia
    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    * configure headers = headersUniversity
    # The shared FQM setup verifies entity types once before the query scenarios run.

    Given path 'entity-types', instanceEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    * def sharedInstanceRequest = { id: '#(sharedInstanceId)', hrid: '#(sharedInstanceHrid)', title: '#(sharedInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)', languages: ['eng'] }
    Given path 'inventory/instances'
    And request sharedInstanceRequest
    When method POST
    Then status 201

    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(sharedInstanceId)',
        sourceTenantId: '#(universityTenant)',
        targetTenantId: '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == sharedInstanceId
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant
    * def sharingInstanceId = response.id

    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = sharedInstanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR'
    When method GET
    Then status 200
    * def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.status == 'COMPLETE'

    Given path 'inventory/instances', sharedInstanceId
    When method GET
    Then status 200
    And match response.id == sharedInstanceId
    And match response.source == 'CONSORTIUM-FOLIO'

    * configure headers = headersConsortia
    Given path 'inventory/instances', sharedInstanceId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == sharedInstanceId

    * configure headers = headersUniversity
    * def memberInstanceRequest = { id: '#(memberInstanceId)', hrid: '#(memberInstanceHrid)', title: '#(sharedInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)', languages: ['eng'] }
    Given path 'inventory/instances'
    And request memberInstanceRequest
    When method POST
    Then status 201

    * def fqlQuery = '{"$and":[{"instance.title":{"$eq":"' + sharedInstanceTitle + '"}}]}'
    * def queryRequest = { entityTypeId: '#(instanceEntityTypeId)', fqlQuery: '#(fqlQuery)', fields: '#(resultFields)' }
    Given path 'query'
    And request queryRequest
    When method POST
    Then status 201
    And match response.queryId == '#present'
    * def queryId = response.queryId

    Given path 'query', queryId
    And params { includeResults: true, limit: 100, offset: 0 }
    And retry until responseStatus != 200 || response.status == 'SUCCESS' || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail('FQM member instance query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'
    * def instanceIds = karate.map(response.content, function(row) { return row['instance.id'] })
    * def tenantIds = karate.map(response.content, function(row) { return row['instance.tenant_id'] })
    And match instanceIds contains sharedInstanceId
    And match instanceIds contains memberInstanceId
    And match tenantIds contains centralTenant
    And match tenantIds contains universityTenant
