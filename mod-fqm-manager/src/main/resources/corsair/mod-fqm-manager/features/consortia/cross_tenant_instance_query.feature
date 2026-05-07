Feature: Cross-tenant instance queries in mod-fqm-manager

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 3, interval: 15000 }
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def resultFields = ['instance.id', 'instance.title', 'instance.source', 'instance.shared', 'instance.tenant_id', 'instance.tenant_name']

  @Positive
  Scenario: [Instances] [Central tenant] Query returns instances from central and member tenants
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # The entity type definition should expose the ECS-only fields that back the UI fields in this test.
    Given path 'entity-types', instanceEntityTypeId
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    # Cross-tenant execution flattens the entity type in each affiliated tenant, so the member tenants need it too.
    # The shared FQM setup verifies these once before the query scenarios run.
    * call login universityUser1
    * configure retry = { count: 3, interval: 15000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }

    Given path 'entity-types', instanceEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200

    * call login collegeUser1
    * configure retry = { count: 3, interval: 15000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json' }

    Given path 'entity-types', instanceEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200

    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # Create shared central instances and local member instances.
    * def instanceTypeId = uuid()
    * def instanceTypeRequest = { id: '#(instanceTypeId)', name: 'FQM ECS instance type', code: 'fqm-ecs', source: 'rdacarrier' }
    * def centralSharedFolioInstanceId = uuid()
    * def centralSharedMarcInstanceId = uuid()
    * def universityLocalInstanceId = uuid()
    * def collegeLocalInstanceId = uuid()
    * def centralSharedFolioInstanceHrid = 'fqm-ci-central-folio-' + centralSharedFolioInstanceId
    * def centralSharedMarcInstanceHrid = 'fqm-ci-central-marc-' + centralSharedMarcInstanceId
    * def universityLocalInstanceHrid = 'fqm-ci-univ-local-' + universityLocalInstanceId
    * def collegeLocalInstanceHrid = 'fqm-ci-college-local-' + collegeLocalInstanceId

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(centralSharedFolioInstanceId)', hrid: '#(centralSharedFolioInstanceHrid)', title: 'FQM ECS shared FOLIO instance', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(centralSharedMarcInstanceId)', hrid: '#(centralSharedMarcInstanceHrid)', title: 'FQM ECS shared MARC instance', source: 'MARC', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    * call login universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(universityLocalInstanceId)', hrid: '#(universityLocalInstanceHrid)', title: 'FQM ECS local FOLIO instance', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    * call login collegeUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json' }

    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    Given path 'instance-storage/instances'
    And request { id: '#(collegeLocalInstanceId)', hrid: '#(collegeLocalInstanceHrid)', title: 'FQM ECS local MARC instance', source: 'MARC', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    # Submit the API equivalent of "Instance - Instance UUID is null/empty False".
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    * def fqlQuery = '{"instance.id":{"$empty":false}}'
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
    * if (response.status == 'FAILED') karate.fail('FQM query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'

    * def expectedInstanceIds = ['#(centralSharedFolioInstanceId)', '#(centralSharedMarcInstanceId)', '#(universityLocalInstanceId)', '#(collegeLocalInstanceId)']
    * def columnValues =
      """
      function(rows, field) {
        return rows.map(function(row) { return row[field]; });
      }
      """
    * def queriedInstances = karate.filter(response.content, function(row) { return expectedInstanceIds.indexOf(row['instance.id']) > -1 })
    * assert karate.sizeOf(queriedInstances) == 4

    And match queriedInstances contains deep { "instance.id": '#(centralSharedFolioInstanceId)', "instance.title": 'FQM ECS shared FOLIO instance', "instance.source": 'FOLIO', "instance.shared": 'Shared', "instance.tenant_id": '#(centralTenant)', "instance.tenant_name": 'Central tenants name' }
    And match queriedInstances contains deep { "instance.id": '#(centralSharedMarcInstanceId)', "instance.title": 'FQM ECS shared MARC instance', "instance.source": 'MARC', "instance.shared": 'Shared', "instance.tenant_id": '#(centralTenant)', "instance.tenant_name": 'Central tenants name' }
    And match queriedInstances contains deep { "instance.id": '#(universityLocalInstanceId)', "instance.title": 'FQM ECS local FOLIO instance', "instance.source": 'FOLIO', "instance.shared": 'Local', "instance.tenant_id": '#(universityTenant)', "instance.tenant_name": 'University tenants name' }
    And match queriedInstances contains deep { "instance.id": '#(collegeLocalInstanceId)', "instance.title": 'FQM ECS local MARC instance', "instance.source": 'MARC', "instance.shared": 'Local', "instance.tenant_id": '#(collegeTenant)', "instance.tenant_name": 'College tenant' }

    * def sharedValues = columnValues(queriedInstances, 'instance.shared')
    * match sharedValues contains ['Shared', 'Local']
    * def sources = columnValues(queriedInstances, 'instance.source')
    * match sources !contains 'CONSORTIUM-FOLIO'
    * match sources !contains 'CONSORTIUM-MARC'
    * match sources !contains 'CONSORTIUM_FOLIO'
    * match sources !contains 'CONSORTIUM_MARC'
