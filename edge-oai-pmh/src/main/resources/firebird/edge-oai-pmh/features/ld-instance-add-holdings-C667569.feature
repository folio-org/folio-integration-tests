@C667569
Feature: Add holdings to LINKED_DATA instance

  Background:
    * url baseUrl
    * callonce variables
    * call login testUser
    * def defaultHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  Scenario: ListRecords: Add Holdings to LINKED_DATA Instance is retrieved in response (marc21_withholdings)
    * configure headers = defaultHeaders

    # Configure OAI-PMH
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

    # Create LINKED_DATA instance
    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(testTenant)' }
    And def instanceId = instance.inventoryId
    And def srsId = instance.srsId
    And def linkedDataId = instance.linkedDataId

    * pause(5000)

    * def from = isoDate()
    * def until = isoDate()

    * url edgeUrl

    # Send harvest request
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//error/@code == 'noRecordsMatch'

    * url baseUrl
    * def from = isoDate()

    # create holdings record
    * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId: '#(instanceId)', testTenant: '#(testTenant)' }

    * def until = isoDate()

    * url edgeUrl

    # Send harvest request
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    * url baseUrl
    # Change OAI-PMH record source to 'Inventory' and save settings
    * set behaviorPayload.configValue.recordsSource = 'Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl

    # Send harvest request
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    * url baseUrl
    # Change OAI-PMH record source to 'Source record storage and Inventory' and save settings
    * set behaviorPayload.configValue.recordsSource = 'Source record storage and Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl

    # Send harvest request
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'