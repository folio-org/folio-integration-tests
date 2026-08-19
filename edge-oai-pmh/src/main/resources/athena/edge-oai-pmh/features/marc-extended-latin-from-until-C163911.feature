@MARC_EXTENDED_LATIN_FROM_UNTIL
Feature: Import MARC with extended Latin characters and harvest using from/until

  Background:
    * url baseUrl
    * callonce variables
    * call login testUser
    * def defaultHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*', 'Authtoken-Refresh-Cache': 'true' }

  @C163911
  Scenario: ListRecords with from/until returns imported MARC and preserves extended Latin characters
    * configure headers = defaultHeaders
    * def expectedTitleA = 'Neue Ausgabe sämtlicher Werke'
    * def expectedTitleB = 'in Verbindung mit den Mozartstädten, Augsburg, Salzburg und Wien.'
    * def normalizeNfc =
      """
      function(value) {
        var Normalizer = Java.type('java.text.Normalizer');
        var Form = Java.type('java.text.Normalizer$Form');
        return Normalizer.normalize(value, Form.NFC);
      }
      """

    # Configure OAI-PMH:
    # Record source = Source record storage
    # Suppressed records processing = Transfer suppressed records with discovery flag value
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

    # Import MARC record with extended Latin characters into SRS
    * def newInstanceTypeId = uuid()
    * def newInstanceTypeCode = 'extlatin' + java.lang.System.currentTimeMillis()
    * def newInstanceId = uuid()
    * def newInstanceHrid = 'inst-ext-latin-' + java.lang.System.currentTimeMillis()
    * def newSnapshotId = uuid()
    * def newRecordId = uuid()
    * def newMatchedId = uuid()

    # Create instance type in-test to avoid dependency on static reference IDs
    Given path 'instance-types'
    And request
    """
    {
      "id": "#(newInstanceTypeId)",
      "name": "Extended Latin test type",
      "code": "#(newInstanceTypeCode)",
      "source": "local"
    }
    """
    When method POST
    Then status 201

    * call read('init_data/create-instance.feature') { instanceId: '#(newInstanceId)', instanceTypeId: '#(newInstanceTypeId)', instanceHrid: '#(newInstanceHrid)', instanceSource: 'MARC' }
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(newSnapshotId)', instanceId: '#(newInstanceId)', recordId: '#(newRecordId)', matchedId: '#(newMatchedId)' }

    # Ensure harvested MARC includes an extended-Latin 245 field in parsed SRS content
    Given path 'source-storage/records', newRecordId
    When method GET
    Then status 200
    * def srsRecord = response
    * def upsert245ab =
      """
      function(fields, valueA, valueB) {
        for (var i = 0; i < fields.length; i++) {
          if (fields[i]['245']) {
            fields[i]['245'].ind1 = '1';
            fields[i]['245'].ind2 = '0';
            var subfields = fields[i]['245'].subfields || [];
            var hasA = false;
            var hasB = false;
            for (var j = 0; j < subfields.length; j++) {
              if (subfields[j]['a'] != null) {
                subfields[j]['a'] = valueA;
                hasA = true;
              }
              if (subfields[j]['b'] != null) {
                subfields[j]['b'] = valueB;
                hasB = true;
              }
            }
            if (!hasA) subfields.push({ a: valueA });
            if (!hasB) subfields.push({ b: valueB });
            fields[i]['245'].subfields = subfields;
            return true;
          }
        }
        fields.push({ '245': { 'ind1': '1', 'ind2': '0', 'subfields': [{ 'a': valueA }, { 'b': valueB }] } });
        return true;
      }
      """
    * def updated245 = upsert245ab(srsRecord.parsedRecord.content.fields, expectedTitleA, expectedTitleB)
    * match updated245 == true

    Given path 'source-storage/records', newRecordId
    And request srsRecord
    When method PUT
    Then status 200

    * pause(5000)
    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * configure retry = { count: 12, interval: 2000 }

    # Harvest records with from/until boundaries
    Given path 'oai'
    And param apikey = apikey
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(newInstanceId) > -1
    When method GET
    Then status 200

    * def responseXml = karate.toString(response)

    # Response contains the imported record
    And match responseXml contains newInstanceId

    # Extended Latin characters are preserved
    * def harvestedTitleA = karate.xmlPath(response, "string((//*[local-name()='record'][.//*[local-name()='datafield' and @tag='999']/*[local-name()='subfield' and @code='s' and text()='" + newRecordId + "']]//*[local-name()='datafield' and @tag='245']/*[local-name()='subfield' and @code='a'])[1])")
    * def harvestedTitleB = karate.xmlPath(response, "string((//*[local-name()='record'][.//*[local-name()='datafield' and @tag='999']/*[local-name()='subfield' and @code='s' and text()='" + newRecordId + "']]//*[local-name()='datafield' and @tag='245']/*[local-name()='subfield' and @code='b'])[1])")
    * def harvestedTitleANormalized = normalizeNfc(harvestedTitleA)
    * def harvestedTitleBNormalized = normalizeNfc(harvestedTitleB)
    * def expectedTitleANormalized = normalizeNfc(expectedTitleA)
    * def expectedTitleBNormalized = normalizeNfc(expectedTitleB)
    And match harvestedTitleANormalized == expectedTitleANormalized
    And match harvestedTitleBNormalized == expectedTitleBNormalized
    And match responseXml !contains '�'
