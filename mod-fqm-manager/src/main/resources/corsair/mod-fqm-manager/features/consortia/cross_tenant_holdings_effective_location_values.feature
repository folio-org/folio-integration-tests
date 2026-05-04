Feature: Cross-tenant holdings effective location values in mod-fqm-manager

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 20, interval: 15000 }
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'
    * def resultFields = ['holdings.id', 'holdings.tenant_id', 'effective_location.name', 'effective_library.name']

  @Positive
  Scenario: Holdings effective location and library field values are aggregated in ECS
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    Given path 'entity-types', holdingsEntityTypeId
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    * def createHoldingsData = read('create_holdings_effective_location_data.feature')
    * def centralData = call createHoldingsData { user: '#(consortiaAdmin)', tenantId: '#(centralTenant)', label: 'Central', codeSuffix: 'CEN', runId: '#(random)' }
    * def universityData = call createHoldingsData { user: '#(universityUser1)', tenantId: '#(universityTenant)', label: 'University', codeSuffix: 'UNI', runId: '#(random)' }
    * def collegeData = call createHoldingsData { user: '#(collegeUser1)', tenantId: '#(collegeTenant)', label: 'College', codeSuffix: 'COL', runId: '#(random)' }

    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # API equivalent of selecting "Holdings - Tenant ID equals consortium".
    Given path 'entity-types', holdingsEntityTypeId, 'field-values'
    And param field = 'holdings.tenant_id'
    When method GET
    Then status 200
    And match response.content contains deep { value: '#(centralTenant)', label: '#(centralTenant)' }

    * def fqlQuery = '{"holdings.tenant_id":{"$eq":"' + centralTenant + '"}}'
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
    * if (response.status == 'FAILED') karate.fail('FQM query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'

    * def queriedHoldings = karate.filter(response.content, function(row) { return row['holdings.id'] == centralData.holdingsId })
    * assert karate.sizeOf(queriedHoldings) == 1
    And match queriedHoldings contains deep { 'holdings.id': '#(centralData.holdingsId)', 'holdings.tenant_id': '#(centralTenant)', 'effective_location.name': '#(centralData.locationName)', 'effective_library.name': '#(centralData.libraryName)' }

    * def distinctColumnValues =
      """
      function(rows, field) {
        var values = [];
        rows.forEach(function(row) {
          var value = row[field];
          if (value != null && values.indexOf(value) < 0) {
            values.push(value);
          }
        });
        return values;
      }
      """
    * def labels =
      """
      function(values) {
        return values.map(function(value) { return value.label; });
      }
      """

    Given path 'entity-types', holdingsEntityTypeId, 'field-values'
    And param field = 'effective_location.name'
    And param search = 'FQM ECS'
    When method GET
    Then status 200
    * def effectiveLocationLabels = labels(response.content)
    * def queriedEffectiveLocationNames = distinctColumnValues(queriedHoldings, 'effective_location.name')
    * def expectedEffectiveLocationNames = [centralData.locationName, universityData.locationName, collegeData.locationName]
    * match effectiveLocationLabels contains queriedEffectiveLocationNames
    * match effectiveLocationLabels contains expectedEffectiveLocationNames

    Given path 'entity-types', holdingsEntityTypeId, 'field-values'
    And param field = 'effective_library.name'
    And param search = 'FQM ECS'
    When method GET
    Then status 200
    * def effectiveLibraryLabels = labels(response.content)
    * def queriedEffectiveLibraryNames = distinctColumnValues(queriedHoldings, 'effective_library.name')
    * def expectedEffectiveLibraryNames = [centralData.libraryName, universityData.libraryName, collegeData.libraryName]
    * match effectiveLibraryLabels contains queriedEffectiveLibraryNames
    * match effectiveLibraryLabels contains expectedEffectiveLibraryNames
