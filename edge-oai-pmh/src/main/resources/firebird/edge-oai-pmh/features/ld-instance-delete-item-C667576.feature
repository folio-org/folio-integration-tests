Feature: Delete item of LINKED_DATA instance

  Background:
    * url baseUrl
    * callonce variables
    * call login testUser
    * def defaultHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def textPlainHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain', 'Authtoken-Refresh-Cache': 'true' }
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  @C667576
  Scenario: ListRecords: Delete Item of LINKED_DATA Instance is retrieved in response (marc21_withholdings)
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

    # create holdings record
    * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId: '#(instanceId)', testTenant: '#(testTenant)' }
    * def holdingsId = holdings.id
    * def item = call read(utilsPath+'@CreateSimpleItem') { holdingsId: '#(holdingsId)', testTenant: '#(testTenant)'  }
    * def itemId = item.id

    * pause(1000)
    * def from = isoDate()
    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

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
    * configure headers = defaultHeaders
    * def from = isoDate()

    # Delete item
    * configure headers = textPlainHeaders
    Given path 'item-storage/items', itemId
    When method DELETE
    Then status 204
    * def itemBody = response
    * eval itemBody['discoverySuppress'] = true

    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Send harvest request
    Given path 'oai/records'
    And param apikey = apikey
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

    * url baseUrl
    * configure headers = defaultHeaders
    # Change OAI-PMH record source to 'Inventory' and save settings
    * set behaviorPayload.configValue.recordsSource = 'Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Send harvest request
    Given path 'oai/records'
    And param apikey = apikey
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

    * url baseUrl
    * configure headers = defaultHeaders
    # Change OAI-PMH record source to 'Source record storage and Inventory' and save settings
    * set behaviorPayload.configValue.recordsSource = 'Source record storage and Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Send harvest request
    Given path 'oai/records'
    And param apikey = apikey
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