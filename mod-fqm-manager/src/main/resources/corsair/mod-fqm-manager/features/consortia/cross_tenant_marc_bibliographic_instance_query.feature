Feature: Cross-tenant instance queries with MARC bibliographic in mod-fqm-manager

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 3, interval: 15000 }
    * def instanceMarcBibliographicEntityTypeId = 'bce8ea43-1271-54ca-99ad-aa185e8b5b1b'
    * def resultFields = ['instance.id', 'instance.title', 'instance.source', 'instance.shared', 'instance.tenant_id', 'instance.tenant_name']

  @Positive
  Scenario: [Instances with MARC bibliographic] [Central tenant] Cross-tenant searching for instances that have MARC bibliographic data is enabled
    * def instanceTypeId = uuid()
    * def centralInstanceId = uuid()
    * def universityInstanceId = uuid()
    * def collegeInstanceId = uuid()
    * def queryTitle = 'FQM ECS central MARC bibliographic instance query ' + randomMillis()
    * def instanceTypeRequest = { id: '#(instanceTypeId)', name: 'FQM ECS central MARC bibliographic instance type', code: 'fqm-ecs-cmbi', source: 'local' }
    * def centralInstanceHrid = 'fqm-cmbi-central-' + centralInstanceId
    * def universityInstanceHrid = 'fqm-cmbi-university-' + universityInstanceId
    * def collegeInstanceHrid = 'fqm-cmbi-college-' + collegeInstanceId

    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    Given path 'entity-types', instanceMarcBibliographicEntityTypeId
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(centralInstanceId)', hrid: '#(centralInstanceHrid)', title: '#(queryTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)', languages: ['eng'] }
    When method POST
    Then status 201

    * call login universityUser1
    * configure retry = { count: 3, interval: 15000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }

    Given path 'entity-types', instanceMarcBibliographicEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(universityInstanceId)', hrid: '#(universityInstanceHrid)', title: '#(queryTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)', languages: ['eng'] }
    When method POST
    Then status 201

    * call login collegeUser1
    * configure retry = { count: 3, interval: 15000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json' }

    Given path 'entity-types', instanceMarcBibliographicEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(collegeInstanceId)', hrid: '#(collegeInstanceHrid)', title: '#(queryTitle)', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)', languages: ['eng'] }
    When method POST
    Then status 201

    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    * def fqlQuery = '{"instance.title":{"$eq":"' + queryTitle + '"}}'
    * def queryRequest = { entityTypeId: '#(instanceMarcBibliographicEntityTypeId)', fqlQuery: '#(fqlQuery)', fields: '#(resultFields)' }
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
    * if (response.status == 'FAILED') karate.fail('FQM central MARC bibliographic instance query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'

    * def expectedInstanceIds = ['#(centralInstanceId)', '#(universityInstanceId)', '#(collegeInstanceId)']
    * def queriedInstances = karate.filter(response.content, function(row) { return expectedInstanceIds.indexOf(row['instance.id']) > -1 })
    * assert karate.sizeOf(queriedInstances) == 3

    And match queriedInstances contains deep { "instance.id": '#(centralInstanceId)', "instance.title": '#(queryTitle)', "instance.source": 'FOLIO', "instance.shared": 'Shared', "instance.tenant_id": '#(centralTenant)', "instance.tenant_name": 'Central tenants name' }
    And match queriedInstances contains deep { "instance.id": '#(universityInstanceId)', "instance.title": '#(queryTitle)', "instance.source": 'FOLIO', "instance.shared": 'Local', "instance.tenant_id": '#(universityTenant)', "instance.tenant_name": 'University tenants name' }
    And match queriedInstances contains deep { "instance.id": '#(collegeInstanceId)', "instance.title": '#(queryTitle)', "instance.source": 'FOLIO', "instance.shared": 'Local', "instance.tenant_id": '#(collegeTenant)', "instance.tenant_name": 'College tenant' }
