Feature: GetRecord for LINKED_DATA instance with holdings and items

  Background:
    * url baseUrl
    * callonce variables
    * call login testUser
    * def defaultHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  @C663362
  Scenario: GetRecord: LINKED_DATA Instance with Holdings and Items is retrieved in response (marc21_withholdings)
    * configure headers = defaultHeaders

    # Configure OAI-PMH behavior: Source record storage and transfer suppressed records with discovery flag value
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.recordsSource = 'Source record storage'
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    # Create LINKED_DATA instance with holdings and item
    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(testTenant)' }
    And def instanceId = instance.inventoryId
    And def srsId = instance.srsId
    And def linkedDataId = instance.linkedDataId
    * pause(5000)

    * def holdings = call read(utilsPath + '@CreateHoldings') { instanceId: '#(instanceId)', testTenant: '#(testTenant)' }
    * def holdingsId = holdings.id
    * def item = call read(utilsPath + '@CreateSimpleItem') { holdingsId: '#(holdingsId)', testTenant: '#(testTenant)' }
    * def itemId = item.id

    * pause(5000)
    * def identifier = 'oai:folio.org:' + testTenant + '/' + instanceId
    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * configure retry = { count: 12, interval: 2000 }

    # Verify GetRecord in Source record storage mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952'] == '#present'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Change OAI-PMH record source to Inventory
    * url baseUrl
    * configure headers = defaultHeaders
    * set behaviorPayload.configValue.recordsSource = 'Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Verify GetRecord in Inventory mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952'] == '#present'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Change OAI-PMH record source to Source record storage and Inventory
    * url baseUrl
    * configure headers = defaultHeaders
    * set behaviorPayload.configValue.recordsSource = 'Source record storage and Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Verify GetRecord in Source record storage and Inventory mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952'] == '#present'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'
