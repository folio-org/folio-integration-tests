@LD_INSTANCE_EDIT_MAIN_TITLE
Feature: Edit main title of LINKED_DATA instance

  Background:
    * url baseUrl
    * callonce variables
    * call login testUser
    * def defaultHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*', 'Authtoken-Refresh-Cache': 'true' }
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  Scenario: ListRecords: Edit main title of LINKED_DATA Instance is retrieved in response (marc21)
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

    # Verify there is no record match for this instance in the current harvest window
    * def from = isoDate()
    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    * def baselineXml = karate.prettyXml(response)
    And match baselineXml !contains instanceId

    * url baseUrl
    * configure headers = defaultHeaders
    * def from = isoDate()

    # Edit title in source record for LINKED_DATA instance
    Given path 'instance-storage/instances', instanceId
    When method GET
    Then status 200
    * def version = $._version

    Given path 'records-editor/records'
    And param externalId = instanceId
    When method GET
    Then status 200
    * def instanceRecord = response
    * def parsedRecordId = response.parsedRecordId
    * def updatedMainTitle = 'Updated linked data main title ' + uuid()
    * def field245 = { tag: '245', indicators: [ '\\', '\\' ], content: '#("$a " + updatedMainTitle)', isProtected: false }
    * eval
      """
      var i;
      var idx = -1;
      for (i = 0; i < instanceRecord.fields.length; i++) {
        if (instanceRecord.fields[i].tag == '245') {
          idx = i;
          break;
        }
      }
      if (idx >= 0) {
        instanceRecord.fields[idx] = field245;
      } else {
        instanceRecord.fields.push(field245);
      }
      """
    * set instanceRecord._actionType = 'edit'
    * set instanceRecord.relatedRecordVersion = version

    Given path 'records-editor/records', parsedRecordId
    And request instanceRecord
    When method PUT
    Then status 202

    * pause(5000)
    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Verify updated record in Source record storage mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == updatedMainTitle
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

    # Verify updated record in Inventory mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == updatedMainTitle
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

    # Verify updated record in Source record storage and Inventory mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == updatedMainTitle
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
