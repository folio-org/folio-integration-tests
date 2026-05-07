Feature: Query member tenant holdings in ECS

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 3, interval: 15000 }
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'
    * def resultFields = ['holdings.id', 'holdings.instance_id', 'holdings.tenant_id', 'holdings.tenant_name', 'instance.title']

  @Positive
  Scenario: [Holdings] [Member tenant] Query returns local holdings and holdings for shared instances
    * def instanceTypeId = uuid()
    * def holdingsSourceId = uuid()
    * def sharedInstanceId = uuid()
    * def universityInstanceId = uuid()
    * def sharedInstanceHrid = 'fqm-mh-shared-' + sharedInstanceId
    * def universityInstanceHrid = 'fqm-mh-local-' + universityInstanceId
    * def sharingId = uuid()
    * def universityInstitutionId = uuid()
    * def universityCampusId = uuid()
    * def universityLibraryId = uuid()
    * def universityServicePointId = uuid()
    * def universityLocationId = uuid()
    * def universityLocalHoldingId = uuid()
    * def universitySharedHoldingId = uuid()
    * def sharedInstanceTitle = 'FQM ECS member holdings shared instance'
    * def universityInstanceTitle = 'FQM ECS member holdings university instance'
    * def instanceTypeRequest = { id: '#(instanceTypeId)', name: 'FQM ECS member holdings instance type', code: 'fqm-mh-it', source: 'rdacarrier' }
    * def holdingsSourceRequest = { id: '#(holdingsSourceId)', name: 'FQM ECS member holdings source', source: 'local' }

    * call login consortiaAdmin
    * configure retry = { count: 3, interval: 15000 }
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure headers = headersConsortia

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    * call login universityUser1
    * configure retry = { count: 3, interval: 15000 }
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }
    * configure headers = headersUniversity

    Given path 'entity-types', holdingsEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request { id: '#(sharedInstanceId)', hrid: '#(sharedInstanceHrid)', title: '#(sharedInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
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
    Given path 'holdings-sources'
    And request holdingsSourceRequest
    When method POST
    Then status 201

    Given path 'location-units/institutions'
    And request { id: '#(universityInstitutionId)', name: 'FQM ECS member holdings institution', code: 'fqm-mh-ui' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(universityCampusId)', institutionId: '#(universityInstitutionId)', name: 'FQM ECS member holdings campus', code: 'fqm-mh-uc' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(universityLibraryId)', campusId: '#(universityCampusId)', name: 'FQM ECS member holdings library', code: 'fqm-mh-ul' }
    When method POST
    Then status 201

    Given path 'locations'
    And request { id: '#(universityLocationId)', name: 'FQM ECS member holdings location', code: 'fqm-mh-uloc', institutionId: '#(universityInstitutionId)', campusId: '#(universityCampusId)', libraryId: '#(universityLibraryId)', primaryServicePoint: '#(universityServicePointId)', servicePointIds: ['#(universityServicePointId)'] }
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(universityInstanceId)', hrid: '#(universityInstanceHrid)', title: '#(universityInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request { id: '#(universityLocalHoldingId)', instanceId: '#(universityInstanceId)', permanentLocationId: '#(universityLocationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request { id: '#(universitySharedHoldingId)', instanceId: '#(sharedInstanceId)', permanentLocationId: '#(universityLocationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201

    * def expectedHoldingIds = ['#(universityLocalHoldingId)', '#(universitySharedHoldingId)']
    * def fqlQuery = '{\"holdings.id\":{\"$in\":[\"' + universityLocalHoldingId + '\",\"' + universitySharedHoldingId + '\"]}}'
    * def queryRequest = { entityTypeId: '#(holdingsEntityTypeId)', fqlQuery: '#(fqlQuery)', fields: '#(resultFields)' }

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
    * if (response.status == 'FAILED') karate.fail('FQM member holdings query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'

    * def queriedHoldings = karate.filter(response.content, function(row) { return expectedHoldingIds.indexOf(row['holdings.id']) > -1 })
    * assert karate.sizeOf(queriedHoldings) == 2

    And match queriedHoldings contains deep { 'holdings.id': '#(universityLocalHoldingId)', 'holdings.instance_id': '#(universityInstanceId)', 'holdings.tenant_id': '#(universityTenant)', 'holdings.tenant_name': 'University tenants name', 'instance.title': '#(universityInstanceTitle)' }
    And match queriedHoldings contains deep { 'holdings.id': '#(universitySharedHoldingId)', 'holdings.instance_id': '#(sharedInstanceId)', 'holdings.tenant_id': '#(universityTenant)', 'holdings.tenant_name': 'University tenants name', 'instance.title': '#(sharedInstanceTitle)' }
