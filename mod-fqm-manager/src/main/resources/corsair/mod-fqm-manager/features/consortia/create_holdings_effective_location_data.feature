Feature: Create holdings data with effective location details

  Background:
    * url baseUrl
    * configure readTimeout = 600000

  @Positive
  Scenario: Create holdings, location, and library data for one tenant
    * call login user
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenantId)', 'Accept': 'application/json' }

    * def institutionId = uuid()
    * def campusId = uuid()
    * def libraryId = uuid()
    * def servicePointId = uuid()
    * def locationId = uuid()
    * def holdingsSourceId = uuid()
    * def instanceTypeId = uuid()
    * def instanceId = uuid()
    * def holdingsId = uuid()
    * def institutionName = 'FQM ECS ' + label + ' Institution ' + runId
    * def campusName = 'FQM ECS ' + label + ' Campus ' + runId
    * def libraryName = 'FQM ECS ' + label + ' Library ' + runId
    * def locationName = 'FQM ECS ' + label + ' Effective Location ' + runId
    * def holdingsSourceName = 'FQM ECS ' + label + ' Holdings Source ' + runId

    Given path 'location-units', 'institutions'
    And request { id: '#(institutionId)', name: '#(institutionName)', code: '#("FQI" + codeSuffix)' }
    When method POST
    Then status 201

    Given path 'location-units', 'campuses'
    And request { id: '#(campusId)', institutionId: '#(institutionId)', name: '#(campusName)', code: '#("FQC" + codeSuffix)' }
    When method POST
    Then status 201

    Given path 'location-units', 'libraries'
    And request { id: '#(libraryId)', campusId: '#(campusId)', name: '#(libraryName)', code: '#("FQL" + codeSuffix)' }
    When method POST
    Then status 201

    Given path 'locations'
    And request { id: '#(locationId)', name: '#(locationName)', code: '#("FQLOC" + codeSuffix)', primaryServicePoint: '#(servicePointId)', libraryId: '#(libraryId)', campusId: '#(campusId)', institutionId: '#(institutionId)', servicePointIds: ['#(servicePointId)'] }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(instanceTypeId)', name: '#("FQM ECS " + label + " instance type")', code: '#("fqmet" + codeSuffix)', source: 'rdacarrier' }
    When method POST
    Then status 201

    Given path 'instance-storage', 'instances'
    And request { id: '#(instanceId)', title: '#("FQM ECS " + label + " holdings instance")', source: 'FOLIO', instanceTypeId: '#(instanceTypeId)' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(holdingsSourceId)', name: '#(holdingsSourceName)', source: 'local' }
    When method POST
    Then status 201

    Given path 'holdings-storage', 'holdings'
    And request { id: '#(holdingsId)', instanceId: '#(instanceId)', permanentLocationId: '#(locationId)', sourceId: '#(holdingsSourceId)' }
    When method POST
    Then status 201
