@parallel=false
Feature: ListRecords/GetRecord: SRS - Verify holdings ILL policy is included in 952 subfield r for marc21_withholdings

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify holdings ILL policy is returned in 952 subfield r for ListRecords and GetRecord
    * def testInstanceId = '9fe4a767-d071-4952-ad14-43f2df7d3e01'
    * def testSrsId = 'f0f8ee76-4438-4667-b95e-ff90763eb201'
    * def testSnapshotId = '70463cff-631f-48a2-ab3d-706a1d315001'
    * def testHoldingsId = '1c2a4b65-2442-469f-8a48-fde86f523001'
    * def testItemId = '2072f137-9194-4ff2-88fb-f9e16debd001'
    * def testHrid = 'inst000000ill952'
    * def illPolicyId = '0fdb0d88-f4f8-4b01-b3a6-9988fefec001'
    * def illPolicyName = 'ILL policy for holdings 952 subfield r'
    * def currentDate = karate.get('$', java.time.LocalDate.now().toString())
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }

    # Verify OAI-PMH behavior configuration.
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * match behaviorConfig.configValue.recordsSource == 'Source record storage'
    * match behaviorConfig.configValue.suppressedRecordsProcessing == 'true'

    # Create ILL policy used by holdings.
    Given url baseUrl
    And path 'ill-policies'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "id": "#(illPolicyId)",
      "name": "#(illPolicyName)",
      "source": "local"
    }
    """
    When method POST
    Then status 201

    # Create MARC-backed instance.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'MARC'
    And request instance
    When method POST
    Then status 201

    # Create snapshot and SRS bib record for the MARC instance.
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
    * set record.id = testSrsId
    * set record.snapshotId = testSnapshotId
    * set record.externalIdsHolder.instanceId = testInstanceId
    * set record.externalIdsHolder.instanceHrid = testHrid
    * set record.matchedId = testSrsId
    And request record
    And header Accept = 'application/json'
    When method POST
    Then status 201

    # Create holdings with populated ILL policy.
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = testHoldingsId
    * set holding.instanceId = testInstanceId
    * set holding.hrid = testHrid + '_h1'
    * set holding.illPolicyId = illPolicyId
    And request holding
    When method POST
    Then status 201

    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * def recordXPath = '//record[header/identifier[text()="' + identifierToFind + '"]]'
    * call sleep 5000

    # Verify ListRecords returns 952 $r with the holdings ILL policy.
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind
    * def testRecord = karate.xmlPath(response, recordXPath)
    * def field952r = karate.xmlPath(testRecord, '//datafield[@tag="952" and @ind1="f" and @ind2="f"]/subfield[@code="r"]')
    * print 'field952r:', field952r
    * print 'illPolicyName:', illPolicyName
    * match field952r == illPolicyName

    # Add item to the holdings and verify holdings ILL policy still appears in 952 $r.
    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def item = read('classpath:samples/item.json')
    * set item.id = testItemId
    * set item.holdingsRecordId = testHoldingsId
    * set item.hrid = testHrid + '_i1'
    And request item
    When method POST
    Then status 201

    * call sleep 5000

    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def identifiersAfterItem = karate.xmlPath(response, '//header/identifier')
    * match identifiersAfterItem contains identifierToFind
    * def testRecordWithItem = karate.xmlPath(response, recordXPath)
    * def field952rWithItem = karate.xmlPath(testRecordWithItem, '//datafield[@tag="952" and @ind1="f" and @ind2="f"]/subfield[@code="r"]')
    * print 'field952rWithItem:', field952rWithItem
    * print 'illPolicyName:', illPolicyName
    * match field952rWithItem == illPolicyName

    # Verify GetRecord returns 952 $r with the holdings ILL policy.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def getRecordIllPolicy = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="952" and @ind1="f" and @ind2="f"]/*[local-name()="subfield" and @code="r"]')
    * print 'getRecordIllPolicy:', getRecordIllPolicy
    * print 'illPolicyName:', illPolicyName
    * match getRecordIllPolicy == illPolicyName

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

    Given url baseUrl
    And path 'ill-policies', illPolicyId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204
