@parallel=false
Feature: ListRecords/GetRecord: Inventory - Verify holdings ILL policy is included in 952 subfield r for marc21_withholdings

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_Inventory_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify Inventory holdings ILL policy is returned in 952 subfield r for ListRecords and GetRecord
    * def randomUuid = function(){ return java.util.UUID.randomUUID() + '' }
    * def runSuffix = java.lang.String.valueOf(java.lang.System.currentTimeMillis())
    * def testInstanceId = randomUuid()
    * def testHoldingsId = randomUuid()
    * def testItemId = randomUuid()
    * def illPolicyId = randomUuid()
    * def testHrid = 'instill952' + runSuffix
    * def illPolicyName = 'ILL policy ' + runSuffix
    * def currentDate = java.time.LocalDate.now().toString()
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * def recordXPath = '//*[local-name()="record"][.//*[local-name()="identifier" and text()="' + identifierToFind + '"]]'

    # Verify required OAI-PMH behavior configuration:
    # record source = Inventory
    # suppressed records processing = Transfer suppressed records with discovery flag value
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * match behaviorConfig.configValue.recordsSource == 'Inventory'
    * assert behaviorConfig.configValue.suppressedRecordsProcessing == 'Transfer suppressed records with discovery flag value' || behaviorConfig.configValue.suppressedRecordsProcessing == 'true'

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

    # Create FOLIO instance.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'FOLIO'
    * set instance.title = 'Inventory holdings ILL policy ' + runSuffix
    * set instance.discoverySuppress = false
    * set instance.staffSuppress = false
    And request instance
    When method POST
    Then status 201

    # Create holding associated with the FOLIO instance.
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = testHoldingsId
    * set holding.instanceId = testInstanceId
    * set holding.hrid = testHrid + '_h1'
    * remove holding.illPolicyId
    * set holding.electronicAccess = []
    And request holding
    When method POST
    Then status 201

    # Update holding with ILL policy (Inventory UI equivalent: Actions -> Edit -> select ILL policy -> Save & close).
    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsId
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def holdingToUpdate = response
    * set holdingToUpdate.illPolicyId = illPolicyId

    Given path 'holdings-storage/holdings', testHoldingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request holdingToUpdate
    When method PUT
    Then status 204

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
    * def identifiers = karate.xmlPath(response, '//*[local-name()="header"]/*[local-name()="identifier"]')
    * match identifiers contains identifierToFind
    * def testRecord = karate.xmlPath(response, recordXPath)
    * def field952r = karate.xmlPath(testRecord, './/*[local-name()="datafield" and @tag="952" and @ind1="f" and @ind2="f"]/*[local-name()="subfield" and @code="r"]')
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
    * def identifiersAfterItem = karate.xmlPath(response, '//*[local-name()="header"]/*[local-name()="identifier"]')
    * match identifiersAfterItem contains identifierToFind
    * def testRecordWithItem = karate.xmlPath(response, recordXPath)
    * def field952rWithItem = karate.xmlPath(testRecordWithItem, './/*[local-name()="datafield" and @tag="952" and @ind1="f" and @ind2="f"]/*[local-name()="subfield" and @code="r"]')
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
