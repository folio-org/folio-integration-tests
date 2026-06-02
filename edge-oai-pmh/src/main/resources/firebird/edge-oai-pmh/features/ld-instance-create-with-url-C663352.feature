Feature: Create LINKED_DATA instance with URL and verify OAI response across record source modes

  Background:
    * url baseUrl
    * callonce variables
    * call login testUser
    * def defaultHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*', 'Authtoken-Refresh-Cache': 'true' }
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'
    * def xmlRecordPath =
      """
      function(identifier) {
        return "//*[local-name()='record'][*[local-name()='header']/*[local-name()='identifier' and text()='" + identifier + "']]";
      }
      """
    * def getSubfield =
      """
      function(xml, identifier, tag, code) {
        var path = xmlRecordPath(identifier) + "//*[local-name()='datafield' and @tag='" + tag + "']/*[local-name()='subfield' and @code='" + code + "']";
        return karate.xmlPath(xml, "string((" + path + ")[1])");
      }
      """
    * def addOrUpdate856 =
      """
      function(fields, url) {
        for (var i = 0; i < fields.length; i++) {
          if (fields[i]['856']) {
            var subfields = fields[i]['856'].subfields || [];
            var hasU = false;
            var hasY = false;
            for (var j = 0; j < subfields.length; j++) {
              if (subfields[j]['u'] != null) {
                subfields[j]['u'] = url;
                hasU = true;
              }
              if (subfields[j]['y'] != null) {
                subfields[j]['y'] = 'Resource';
                hasY = true;
              }
            }
            if (!hasU) subfields.push({ u: url });
            if (!hasY) subfields.push({ y: 'Resource' });
            fields[i]['856'].ind1 = '4';
            fields[i]['856'].ind2 = '0';
            fields[i]['856'].subfields = subfields;
            return true;
          }
        }
        fields.push({ '856': { 'ind1': '4', 'ind2': '0', 'subfields': [{ 'u': url }, { 'y': 'Resource' }] } });
        return true;
      }
      """
  @C663352
  Scenario: ListRecords: New LINKED_DATA instance with URL is retrieved with 999 and 856 fields (marc21)
    * configure headers = defaultHeaders

    # Configure OAI-PMH behavior:
    # recordsSource = Source record storage
    # suppressedRecordsProcessing = Transfer suppressed records with discovery flag value
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

    * def from = isoDate()

    # Create LINKED_DATA work + instance (Marigold-equivalent API flow)
    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(testTenant)' }
    And def instanceId = instance.inventoryId
    And def srsId = instance.srsId
    And def linkedDataId = instance.linkedDataId
    * def linkedDataIdentifier = 'oai:folio.org:' + testTenant + '/' + instanceId
    * def instanceUrl = 'https://folio.org/linked-data/' + uuid()

    * pause(5000)

    # Populate URL of instance
    Given path 'instance-storage/instances', instanceId
    When method GET
    Then status 200
    * def instanceBody = response
    * set instanceBody.electronicAccess =
      """
      [
        {
          uri: '#(instanceUrl)',
          linkText: 'Resource',
          publicNote: 'Linked data URL',
          relationshipId: 'f7d0068e-6272-458e-8a81-b85e7b9a14aa'
        }
      ]
      """

    Given path 'instance-storage/instances', instanceId
    And header Accept = 'text/plain'
    And request instanceBody
    When method PUT
    Then status 204

    # Keep SRS view aligned with the instance URL for Source record storage mode checks
    Given path 'source-storage/records', srsId
    When method GET
    Then status 200
    * def srsRecord = response
    * def updated856 = addOrUpdate856(srsRecord.parsedRecord.content.fields, instanceUrl)
    * match updated856 == true

    Given path 'source-storage/records', srsId
    And request srsRecord
    When method PUT
    * match [200, 204] contains responseStatus

    * pause(5000)

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * configure retry = { count: 12, interval: 2000 }
    * def until = isoDate()

    # Verify in Source record storage mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    * match getSubfield(response, linkedDataIdentifier, '999', 'i') == instanceId
    * match getSubfield(response, linkedDataIdentifier, '999', 's') == srsId
    * match getSubfield(response, linkedDataIdentifier, '999', 'l') == linkedDataId
    * match getSubfield(response, linkedDataIdentifier, '999', 't') == '0'
    * match getSubfield(response, linkedDataIdentifier, '856', 'u') == instanceUrl
    * match getSubfield(response, linkedDataIdentifier, '856', 't') == '0'

    * url baseUrl
    * configure headers = defaultHeaders
    * set behaviorPayload.configValue.recordsSource = 'Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * def until = isoDate()

    # Verify in Inventory mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    * match getSubfield(response, linkedDataIdentifier, '999', 'i') == instanceId
    * match getSubfield(response, linkedDataIdentifier, '999', 's') == srsId
    * match getSubfield(response, linkedDataIdentifier, '999', 'l') == linkedDataId
    * match getSubfield(response, linkedDataIdentifier, '999', 't') == '0'
    * match getSubfield(response, linkedDataIdentifier, '856', 'u') == instanceUrl
    * match getSubfield(response, linkedDataIdentifier, '856', 't') == '0'

    * url baseUrl
    * configure headers = defaultHeaders
    * set behaviorPayload.configValue.recordsSource = 'Source record storage and Inventory'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * def until = isoDate()

    # Verify in Source record storage and Inventory mode
    Given path 'oai/records'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    * match getSubfield(response, linkedDataIdentifier, '999', 'i') == instanceId
    * match getSubfield(response, linkedDataIdentifier, '999', 's') == srsId
    * match getSubfield(response, linkedDataIdentifier, '999', 'l') == linkedDataId
    * match getSubfield(response, linkedDataIdentifier, '999', 't') == '0'
    * match getSubfield(response, linkedDataIdentifier, '856', 'u') == instanceUrl
    * match getSubfield(response, linkedDataIdentifier, '856', 't') == '0'
