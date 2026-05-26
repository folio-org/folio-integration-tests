Feature: Cross-tenant holdings queries in mod-fqm-manager

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 3, interval: 15000 }
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'
    * def resultFields = ['holdings.id', 'holdings.instance_id', 'holdings.tenant_id', 'holdings.tenant_name', 'instance.title']

  @Positive @C543848
  Scenario: [Holdings] [Central tenant] Query returns holdings for local and shared instances from all tenants
    * def instanceTypeId = uuid()
    * def holdingsSourceId = uuid()
    * def centralInstitutionId = uuid()
    * def centralCampusId = uuid()
    * def centralLibraryId = uuid()
    * def centralServicePointId = uuid()
    * def centralLocationId = uuid()
    * def universityInstitutionId = uuid()
    * def universityCampusId = uuid()
    * def universityLibraryId = uuid()
    * def universityServicePointId = uuid()
    * def universityLocationId = uuid()
    * def collegeInstitutionId = uuid()
    * def collegeCampusId = uuid()
    * def collegeLibraryId = uuid()
    * def collegeServicePointId = uuid()
    * def collegeLocationId = uuid()
    * def centralInstanceId = uuid()
    * def universityInstanceId = uuid()
    * def universitySharedInstanceId = uuid()
    * def universitySharingId = uuid()
    * def collegeInstanceId = uuid()
    * def collegeSharedInstanceId = uuid()
    * def collegeSharingId = uuid()
    * def centralInstanceHrid = 'fqm-ch-central-' + centralInstanceId
    * def universityInstanceHrid = 'fqm-ch-univ-local-' + universityInstanceId
    * def universitySharedInstanceHrid = 'fqm-ch-univ-shared-' + universitySharedInstanceId
    * def collegeInstanceHrid = 'fqm-ch-college-local-' + collegeInstanceId
    * def collegeSharedInstanceHrid = 'fqm-ch-college-shared-' + collegeSharedInstanceId
    * def centralHoldingId = uuid()
    * def universityLocalHoldingId = uuid()
    * def universitySharedHoldingId = uuid()
    * def collegeLocalHoldingId = uuid()
    * def collegeSharedHoldingId = uuid()
    * def centralInstanceTitle = 'FQM ECS holdings central instance'
    * def universityInstanceTitle = 'FQM ECS holdings university instance'
    * def universitySharedInstanceTitle = 'FQM ECS holdings university shared instance'
    * def collegeInstanceTitle = 'FQM ECS holdings college instance'
    * def collegeSharedInstanceTitle = 'FQM ECS holdings college shared instance'
    * def instanceTypeRequest = { id: '#(instanceTypeId)', name: 'FQM ECS holdings instance type', code: 'fqm-hecs', source: 'rdacarrier' }
    * def holdingsSourceRequest = { id: '#(holdingsSourceId)', name: 'FQM ECS holdings source', source: 'local' }

    * call login consortiaAdmin
    * configure retry = { count: 3, interval: 15000 }
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure headers = headersConsortia

    Given path 'entity-types', holdingsEntityTypeId
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request holdingsSourceRequest
    When method POST
    Then status 201

    Given path 'location-units/institutions'
    And request { id: '#(centralInstitutionId)', name: 'FQM ECS central institution', code: 'fqm-ci' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(centralCampusId)', institutionId: '#(centralInstitutionId)', name: 'FQM ECS central campus', code: 'fqm-cc' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(centralLibraryId)', campusId: '#(centralCampusId)', name: 'FQM ECS central library', code: 'fqm-cl' }
    When method POST
    Then status 201

    Given path 'locations'
    And request { id: '#(centralLocationId)', name: 'FQM ECS central location', code: 'fqm-cloc', institutionId: '#(centralInstitutionId)', campusId: '#(centralCampusId)', libraryId: '#(centralLibraryId)', primaryServicePoint: '#(centralServicePointId)', servicePointIds: ['#(centralServicePointId)'] }
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(centralInstanceId)', hrid: '#(centralInstanceHrid)', title: '#(centralInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request { id: '#(centralHoldingId)', instanceId: '#(centralInstanceId)', permanentLocationId: '#(centralLocationId)', sourceId: '#(holdingsSourceId)' }
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

    Given path 'holdings-sources'
    And request holdingsSourceRequest
    When method POST
    Then status 201

    Given path 'location-units/institutions'
    And request { id: '#(universityInstitutionId)', name: 'FQM ECS university institution', code: 'fqm-ui' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(universityCampusId)', institutionId: '#(universityInstitutionId)', name: 'FQM ECS university campus', code: 'fqm-uc' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(universityLibraryId)', campusId: '#(universityCampusId)', name: 'FQM ECS university library', code: 'fqm-ul' }
    When method POST
    Then status 201

    Given path 'locations'
    And request { id: '#(universityLocationId)', name: 'FQM ECS university location', code: 'fqm-uloc', institutionId: '#(universityInstitutionId)', campusId: '#(universityCampusId)', libraryId: '#(universityLibraryId)', primaryServicePoint: '#(universityServicePointId)', servicePointIds: ['#(universityServicePointId)'] }
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(universityInstanceId)', hrid: '#(universityInstanceHrid)', title: '#(universityInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request { id: '#(universitySharedInstanceId)', hrid: '#(universitySharedInstanceHrid)', title: '#(universitySharedInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(universitySharingId)',
        instanceIdentifier: '#(universitySharedInstanceId)',
        sourceTenantId: '#(universityTenant)',
        targetTenantId: '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    * def universitySharingInstanceId = response.id

    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = universitySharedInstanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR'
    When method GET
    Then status 200
    * def universitySharingInstance = response.sharingInstances[0]
    And match universitySharingInstance.id == universitySharingInstanceId
    And match universitySharingInstance.status == 'COMPLETE'

    Given path 'holdings-storage/holdings'
    And request { id: '#(universityLocalHoldingId)', instanceId: '#(universityInstanceId)', permanentLocationId: '#(universityLocationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request { id: '#(universitySharedHoldingId)', instanceId: '#(universitySharedInstanceId)', permanentLocationId: '#(universityLocationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201

    * call login collegeUser1
    * configure retry = { count: 3, interval: 15000 }
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json' }
    * configure headers = headersCollege

    Given path 'entity-types', holdingsEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request holdingsSourceRequest
    When method POST
    Then status 201

    Given path 'location-units/institutions'
    And request { id: '#(collegeInstitutionId)', name: 'FQM ECS college institution', code: 'fqm-ki' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(collegeCampusId)', institutionId: '#(collegeInstitutionId)', name: 'FQM ECS college campus', code: 'fqm-kc' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(collegeLibraryId)', campusId: '#(collegeCampusId)', name: 'FQM ECS college library', code: 'fqm-kl' }
    When method POST
    Then status 201

    Given path 'locations'
    And request { id: '#(collegeLocationId)', name: 'FQM ECS college location', code: 'fqm-kloc', institutionId: '#(collegeInstitutionId)', campusId: '#(collegeCampusId)', libraryId: '#(collegeLibraryId)', primaryServicePoint: '#(collegeServicePointId)', servicePointIds: ['#(collegeServicePointId)'] }
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(collegeInstanceId)', hrid: '#(collegeInstanceHrid)', title: '#(collegeInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request { id: '#(collegeSharedInstanceId)', hrid: '#(collegeSharedInstanceHrid)', title: '#(collegeSharedInstanceTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(collegeSharingId)',
        instanceIdentifier: '#(collegeSharedInstanceId)',
        sourceTenantId: '#(collegeTenant)',
        targetTenantId: '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    * def collegeSharingInstanceId = response.id

    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = collegeSharedInstanceId
    And param sourceTenantId = collegeTenant
    And retry until response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR'
    When method GET
    Then status 200
    * def collegeSharingInstance = response.sharingInstances[0]
    And match collegeSharingInstance.id == collegeSharingInstanceId
    And match collegeSharingInstance.status == 'COMPLETE'

    Given path 'holdings-storage/holdings'
    And request { id: '#(collegeLocalHoldingId)', instanceId: '#(collegeInstanceId)', permanentLocationId: '#(collegeLocationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request { id: '#(collegeSharedHoldingId)', instanceId: '#(collegeSharedInstanceId)', permanentLocationId: '#(collegeLocationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201

    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    * def expectedHoldingIds = ['#(centralHoldingId)', '#(universityLocalHoldingId)', '#(universitySharedHoldingId)', '#(collegeLocalHoldingId)', '#(collegeSharedHoldingId)']
    * def fqlQuery = '{\"holdings.id\":{\"$in\":[\"' + centralHoldingId + '\",\"' + universityLocalHoldingId + '\",\"' + universitySharedHoldingId + '\",\"' + collegeLocalHoldingId + '\",\"' + collegeSharedHoldingId + '\"]}}'
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
    * if (response.status == 'FAILED') karate.fail('FQM holdings query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'

    * def queriedHoldings = karate.filter(response.content, function(row) { return expectedHoldingIds.indexOf(row['holdings.id']) > -1 })
    * assert karate.sizeOf(queriedHoldings) == 5

    And match queriedHoldings contains deep { 'holdings.id': '#(centralHoldingId)', 'holdings.instance_id': '#(centralInstanceId)', 'holdings.tenant_id': '#(centralTenant)', 'holdings.tenant_name': 'Central tenants name', 'instance.title': '#(centralInstanceTitle)' }
    And match queriedHoldings contains deep { 'holdings.id': '#(universityLocalHoldingId)', 'holdings.instance_id': '#(universityInstanceId)', 'holdings.tenant_id': '#(universityTenant)', 'holdings.tenant_name': 'University tenants name', 'instance.title': '#(universityInstanceTitle)' }
    And match queriedHoldings contains deep { 'holdings.id': '#(universitySharedHoldingId)', 'holdings.instance_id': '#(universitySharedInstanceId)', 'holdings.tenant_id': '#(universityTenant)', 'holdings.tenant_name': 'University tenants name', 'instance.title': '#(universitySharedInstanceTitle)' }
    And match queriedHoldings contains deep { 'holdings.id': '#(collegeLocalHoldingId)', 'holdings.instance_id': '#(collegeInstanceId)', 'holdings.tenant_id': '#(collegeTenant)', 'holdings.tenant_name': 'College tenant', 'instance.title': '#(collegeInstanceTitle)' }
    And match queriedHoldings contains deep { 'holdings.id': '#(collegeSharedHoldingId)', 'holdings.instance_id': '#(collegeSharedInstanceId)', 'holdings.tenant_id': '#(collegeTenant)', 'holdings.tenant_name': 'College tenant', 'instance.title': '#(collegeSharedInstanceTitle)' }
