@parallel=false
Feature: ListRecords: SRS - Verify 856 mappings for source record storage with holdings and item electronic access

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * def utcDateTimeWithOffsetMinutes = function(offsetMinutes){ return java.time.OffsetDateTime.now(java.time.ZoneOffset.UTC).plusMinutes(offsetMinutes).withNano(0).format(java.time.format.DateTimeFormatter.ISO_INSTANT) }
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * url pmhUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify ListRecords returns expected 856 indicators and subfield t values for source record storage records
    * def randomUuid = function(){ return java.util.UUID.randomUUID() + '' }
    * def runSuffix = java.lang.String.valueOf(java.lang.System.currentTimeMillis())
    * def testInstanceId = randomUuid()
    * def testSrsId = randomUuid()
    * def testSnapshotId = randomUuid()
    * def testHoldingsId = randomUuid()
    * def testItemId = randomUuid()
    * def testHrid = 'inst856ss' + runSuffix
    * def versionComponentRelationshipId = 'd855f394-f9d4-46b6-8435-830eb00d0d57'
    * def componentRelationshipId = '3373f0cf-7a3a-4a65-b0a6-e4f1a3f7d131'
    * def relatedRelationshipId = '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e'
    * def resourceRelationshipId = 'f5d0068e-6272-458e-8a81-b85e7b9a14aa'
    * def fromDateTime = utcDateTimeWithOffsetMinutes(-2)
    * def untilDateTime = utcDateTimeWithOffsetMinutes(5)
    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * def recordXPath = '//*[local-name()="record"][.//*[local-name()="identifier" and text()="' + identifierToFind + '"]]'
    * def instanceComponentUri = 'Instance URI 4 3'
    * def instanceVersionComponentUri = 'Instance URI 4 4'
    * def instanceVersionUri = 'Instance URI 4 1'
    * def holdingsComponentUri = 'Holdings URI 4 3'
    * def holdingsVersionComponentUri = 'Holdings URI 4 4'
    * def holdingsRelatedUri = 'Holdings URI 4 2'
    * def itemComponentUri = 'Item URI 4 3'
    * def itemVersionComponentUri = 'Item URI 4 4'
    * def itemResourceUri = 'Item URI 4 0'

    # Configure the behavior settings required by the scenario.
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * def behaviorValue = behaviorConfig.configValue
    * set behaviorValue.recordsSource = 'Source record storage'
    * set behaviorValue.suppressedRecordsProcessing = 'true'
    * set behaviorConfig.configValue = behaviorValue

    Given path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    Given path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def updatedBehavior = response.configurationSettings[0].configValue
    * match updatedBehavior.recordsSource == 'Source record storage'
    * assert updatedBehavior.suppressedRecordsProcessing == 'Transfer suppressed records with discovery flag value' || updatedBehavior.suppressedRecordsProcessing == 'true'

    # Avoid pagination so ListRecords first page contains this scenario's test record.
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==technical'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def technicalConfig = response.configurationSettings[0]
    * def technicalValue = technicalConfig.configValue
    * def originalMaxRecordsPerResponse = technicalValue.maxRecordsPerResponse
    * set technicalValue.maxRecordsPerResponse = 1000
    * set technicalConfig.configValue = technicalValue

    Given path '/oai-pmh/configuration-settings', technicalConfig.id
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request technicalConfig
    When method PUT
    Then status 204

    # Seed relationship types used by holdings and item electronic access.
    Given url baseUrl
    And path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "id": "#(componentRelationshipId)",
      "name": "Component part(s) of resource",
      "source": "folio"
    }
    """
    When method POST
    * def componentRelationshipExists = responseStatus == 422 && (response.errors[0].message.indexOf('id value already exists') > -1 || response.errors[0].message.indexOf('value already exists in table electronic_access_relationship') > -1)
    * assert responseStatus == 201 || componentRelationshipExists

    Given url baseUrl
    And path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "id": "#(versionComponentRelationshipId)",
      "name": "Version of component part(s) of resource",
      "source": "folio"
    }
    """
    When method POST
    * def versionComponentRelationshipExists = responseStatus == 422 && (response.errors[0].message.indexOf('id value already exists') > -1 || response.errors[0].message.indexOf('value already exists in table electronic_access_relationship') > -1)
    * assert responseStatus == 201 || versionComponentRelationshipExists

    # Create the MARC-backed instance.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'MARC'
    * set instance.discoverySuppress = false
    * set instance.electronicAccess = []
    And request instance
    When method POST
    Then status 201

    # Create snapshot and SRS MARC bib record containing the three source 856 fields.
    Given url baseUrl
    And path 'source-storage/snapshots'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "jobExecutionId": "#(testSnapshotId)",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    Given url baseUrl
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record.json')
    * def marcFields =
    """
    [
      { "001": "in000000856ss" },
      { "008": "                                        " },
      { "005": "20260421081007.7" },
      {
        "245": {
          "subfields": [
            { "a": "Source record storage 856 mapping test" }
          ],
          "ind1": " ",
          "ind2": " "
        }
      },
      {
        "856": {
          "subfields": [
            { "u": "#(instanceComponentUri)" },
            { "3": "Instance material 4 3" },
            { "y": "Component part(s) of resource" },
            { "z": "Instance Public note 4 3" }
          ],
          "ind1": "4",
          "ind2": "3"
        }
      },
      {
        "856": {
          "subfields": [
            { "u": "#(instanceVersionComponentUri)" },
            { "3": "Instance material 4 4" },
            { "y": "Version of component part(s) of resource" },
            { "z": "Instance Public note 4 4" }
          ],
          "ind1": "4",
          "ind2": "4"
        }
      },
      {
        "856": {
          "subfields": [
            { "u": "#(instanceVersionUri)" },
            { "3": "Instance material 4 1" },
            { "y": "Version of resource" },
            { "z": "Instance Public note 4 1" }
          ],
          "ind1": "4",
          "ind2": "1"
        }
      }
    ]
    """
    * set record.id = testSrsId
    * set record.snapshotId = testSnapshotId
    * set record.matchedId = testSrsId
    * set record.externalIdsHolder.instanceId = testInstanceId
    * set record.externalIdsHolder.instanceHrid = testHrid
    * set record.additionalInfo.suppressDiscovery = false
    * set record.parsedRecord.content.fields = marcFields
    And request record
    And header Accept = 'application/json'
    When method POST
    Then status 201

    * call sleep 5000

    # Verify source-record 856 fields in ListRecords marc21 response.
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    * def untilDateTime = utcDateTimeWithOffsetMinutes(5)
    And param from = fromDateTime
    And param until = untilDateTime
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def marcIdentifiers = karate.xmlPath(response, '//*[local-name()="header"]/*[local-name()="identifier"]')
    * match marcIdentifiers contains identifierToFind
    * def marcRecord = karate.xmlPath(response, recordXPath)
    * def marc856Fields = karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856"]')
    * match marc856Fields == '#[3]'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="999" and @ind1="f" and @ind2="f"]/*[local-name()="subfield" and @code="s"]') == testSrsId
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="999" and @ind1="f" and @ind2="f"]/*[local-name()="subfield" and @code="t"]') == '0'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="u"]') == instanceComponentUri
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="3"]') == 'Instance material 4 3'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="y"]') == 'Component part(s) of resource'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="z"]') == 'Instance Public note 4 3'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="t"]') == '0'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="u"]') == instanceVersionComponentUri
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="3"]') == 'Instance material 4 4'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="y"]') == 'Version of component part(s) of resource'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="z"]') == 'Instance Public note 4 4'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="t"]') == '0'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="u"]') == instanceVersionUri
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="3"]') == 'Instance material 4 1'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="y"]') == 'Version of resource'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="z"]') == 'Instance Public note 4 1'
    * match karate.xmlPath(marcRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="t"]') == '0'

    # Add holdings electronic access values matching the requested relationships.
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = testHoldingsId
    * set holding.instanceId = testInstanceId
    * set holding.hrid = testHrid + '_h1'
    * set holding.sourceId = '036ee84a-6afd-4c3c-9ad3-4a12ab875f59'
    * set holding.discoverySuppress = false
    * set holding.electronicAccess = []
    * set holding.electronicAccess[0] = { relationshipId: '#(componentRelationshipId)', uri: '#(holdingsComponentUri)', materialsSpecification: 'Holdings material 4 3', linkText: 'Component part(s) of resource', publicNote: 'Holdings Public note 4 3' }
    * set holding.electronicAccess[1] = { relationshipId: '#(versionComponentRelationshipId)', uri: '#(holdingsVersionComponentUri)', materialsSpecification: 'Holdings material 4 4', linkText: 'Version of component part(s) of resource', publicNote: 'Holdings Public note 4 4' }
    * set holding.electronicAccess[2] = { relationshipId: '#(relatedRelationshipId)', uri: '#(holdingsRelatedUri)', materialsSpecification: 'Holdings material 4 2', linkText: 'Related resource', publicNote: 'Holdings Public note 4 2' }
    And request holding
    When method POST
    Then status 201

    # Validate holdings was created with MARC source and expected 856 relationship payload.
    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsId
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * match response.sourceId == '036ee84a-6afd-4c3c-9ad3-4a12ab875f59'
    * match response.electronicAccess[*].uri contains holdingsRelatedUri

    * call sleep 15000

    # Verify holdings 856 fields in ListRecords marc21_withholdings response.
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    * def untilDateTime = utcDateTimeWithOffsetMinutes(5)
    And param from = fromDateTime
    And param until = untilDateTime
    And header Accept = 'text/xml'
    * configure retry = { count: 2, interval: 30000 }
    And retry until responseStatus == 200 && karate.toString(response).contains(holdingsRelatedUri)
    When method GET
    Then status 200
    * def withHoldingsIdentifiers = karate.xmlPath(response, '//*[local-name()="header"]/*[local-name()="identifier"]')
    * match withHoldingsIdentifiers contains identifierToFind
    * def holdingsRecord = karate.xmlPath(response, recordXPath)
    * def holdings856Fields = karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856"]')
    * match holdings856Fields == '#[6]'
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="u"]') contains only ['Instance URI 4 3', 'Holdings URI 4 3']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="3"]') contains only ['Instance material 4 3', 'Holdings material 4 3']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="y"]') contains only ['Component part(s) of resource', 'Component part(s) of resource']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="z"]') contains only ['Instance Public note 4 3', 'Holdings Public note 4 3']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="t"]') == ['0', '0']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="u"]') contains only ['Instance URI 4 4', 'Holdings URI 4 4']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="3"]') contains only ['Instance material 4 4', 'Holdings material 4 4']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="y"]') contains only ['Version of component part(s) of resource', 'Version of component part(s) of resource']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="z"]') contains only ['Instance Public note 4 4', 'Holdings Public note 4 4']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="t"]') == ['0', '0']
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="u"]') == instanceVersionUri
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="t"]') == '0'
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="u"]') == holdingsRelatedUri
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="3"]') == 'Holdings material 4 2'
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="y"]') == 'Related resource'
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="z"]') == 'Holdings Public note 4 2'
    * match karate.xmlPath(holdingsRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="t"]') == '0'

    # Add item electronic access values matching the requested relationships.
    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def item = read('classpath:samples/item.json')
    * set item.id = testItemId
    * set item.holdingsRecordId = testHoldingsId
    * set item.hrid = testHrid + '_i1'
    * set item.discoverySuppress = false
    * set item.electronicAccess = []
    * set item.electronicAccess[0] = { relationshipId: '#(componentRelationshipId)', uri: '#(itemComponentUri)', materialsSpecification: 'Item material 4 3', linkText: 'Component part(s) of resource', publicNote: 'Item Public note 4 3' }
    * set item.electronicAccess[1] = { relationshipId: '#(versionComponentRelationshipId)', uri: '#(itemVersionComponentUri)', materialsSpecification: 'Item material 4 4', linkText: 'Version of component part(s) of resource', publicNote: 'Item Public note 4 4' }
    * set item.electronicAccess[2] = { relationshipId: '#(resourceRelationshipId)', uri: '#(itemResourceUri)', materialsSpecification: 'Item material 4 0', linkText: 'Resource', publicNote: 'Item Public note 4 0' }
    And request item
    When method POST
    Then status 201

    * call sleep 5000

    # Verify item 856 fields in ListRecords marc21_withholdings response.
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    * def untilDateTime = utcDateTimeWithOffsetMinutes(5)
    And param from = fromDateTime
    And param until = untilDateTime
    And header Accept = 'text/xml'
    * configure retry = { count: 2, interval: 30000 }
    And retry until responseStatus == 200 && karate.toString(response).contains(itemResourceUri)
    When method GET
    Then status 200
    * def withItemIdentifiers = karate.xmlPath(response, '//*[local-name()="header"]/*[local-name()="identifier"]')
    * match withItemIdentifiers contains identifierToFind
    * def itemRecord = karate.xmlPath(response, recordXPath)
    * def item856Fields = karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856"]')
    * match item856Fields == '#[9]'
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="u"]') contains only ['Instance URI 4 3', 'Holdings URI 4 3', 'Item URI 4 3']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="3"]') contains only ['Instance material 4 3', 'Holdings material 4 3', 'Item material 4 3']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="z"]') contains only ['Instance Public note 4 3', 'Holdings Public note 4 3', 'Item Public note 4 3']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="t"]') == ['0', '0', '0']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="u"]') contains only ['Instance URI 4 4', 'Holdings URI 4 4', 'Item URI 4 4']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="3"]') contains only ['Instance material 4 4', 'Holdings material 4 4', 'Item material 4 4']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="z"]') contains only ['Instance Public note 4 4', 'Holdings Public note 4 4', 'Item Public note 4 4']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="t"]') == ['0', '0', '0']
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="u"]') == instanceVersionUri
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="1"]/*[local-name()="subfield" and @code="t"]') == '0'
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="u"]') == holdingsRelatedUri
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="2"]/*[local-name()="subfield" and @code="t"]') == '0'
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="0"]/*[local-name()="subfield" and @code="u"]') == itemResourceUri
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="0"]/*[local-name()="subfield" and @code="3"]') == 'Item material 4 0'
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="0"]/*[local-name()="subfield" and @code="y"]') == 'Resource'
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="0"]/*[local-name()="subfield" and @code="z"]') == 'Item Public note 4 0'
    * match karate.xmlPath(itemRecord, './/*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="0"]/*[local-name()="subfield" and @code="t"]') == '0'

    # Cleanup
    Given url baseUrl
    And path 'item-storage/items', testItemId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'source-storage/records', testSrsId
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Restore technical max records setting.
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==technical'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def restoreTechnicalConfig = response.configurationSettings[0]
    * def restoreTechnicalValue = restoreTechnicalConfig.configValue
    * set restoreTechnicalValue.maxRecordsPerResponse = originalMaxRecordsPerResponse
    * set restoreTechnicalConfig.configValue = restoreTechnicalValue

    Given path '/oai-pmh/configuration-settings', restoreTechnicalConfig.id
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request restoreTechnicalConfig
    When method PUT
    Then status 204
