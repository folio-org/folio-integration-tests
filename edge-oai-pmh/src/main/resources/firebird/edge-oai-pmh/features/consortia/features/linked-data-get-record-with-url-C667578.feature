Feature: GetRecord for shared LINKED_DATA instance with URL

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def headersConsortiaTextPlain = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'text/plain', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def headersUniversityTextPlain = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'text/plain', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersUniversity
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'
    * def getSubfield =
      """
      function(xml, tag, code) {
        var path = "string((//*[local-name()='datafield' and @tag='" + tag + "']/*[local-name()='subfield' and @code='" + code + "'])[1])";
        return karate.xmlPath(xml, path);
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

  @C667578
  Scenario: Consortia | GetRecord: Verify shared LINKED_DATA Instance with URL is retrieved for member tenant harvest
    # Create LINKED_DATA instance in central tenant
    * configure headers = headersConsortia
    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(centralTenant)' }
    And def instanceId = instance.inventoryId
    And def srsId = instance.srsId
    And def linkedDataId = instance.linkedDataId
    And def instanceUrl = 'https://folio.org/linked-data/' + uuid()
    * pause(5000)

    # Populate URL of Instance in Inventory
    Given path 'inventory/instances', instanceId
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

    * configure headers = headersConsortiaTextPlain
    Given path 'inventory/instances', instanceId
    And request instanceBody
    When method PUT
    Then status 204

    # Keep SRS view aligned with URL of Instance for Source record storage mode
    * configure headers = headersConsortia
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

    # Share created instance to member tenant
    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId)',
        sourceTenantId:  '#(centralTenant)',
        targetTenantId:  '#(universityTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == centralTenant
    And match response.targetTenantId == universityTenant
    And def sharingInstanceId = response.id

    * def retryLogic =
      """
      function() {
        if (responseStatus == 401) {
          var loginResult = karate.call('classpath:common-consortia/eureka/initData.feature@Login', consortiaAdmin);
          var newToken = loginResult.okapitoken;
          var newHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': newToken, 'x-okapi-tenant': consortiaAdmin.tenant, 'Accept': 'application/json' };
          karate.configure('headers', newHeaders);
          karate.configure('cookies', { folioAccessToken: newToken });
          return false;
        }
        if (responseStatus == 200 && response.sharingInstances && response.sharingInstances.length > 0) {
          var status = response.sharingInstances[0].status;
          return status == 'COMPLETE' || status == 'ERROR';
        }
        return false;
      }
      """

    # Verify sharing status is COMPLETE
    * configure retry = { count: 40, interval: 10000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = centralTenant
    And retry until retryLogic()
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is available in member tenant
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId

    # Create holdings and item in member tenant for marc21_withholdings output
    * def holdings = call read(utilsPath + '@CreateHoldings') { instanceId: '#(instanceId)', testTenant: '#(universityTenant)' }
    * def holdingsId = holdings.id
    * def item = call read(utilsPath + '@CreateSimpleItem') { holdingsId: '#(holdingsId)', testTenant: '#(universityTenant)' }
    * def itemId = item.id

    # Configure OAI-PMH behavior for Source record storage mode
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.recordsSource = 'Source record storage'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    * configure headers = headersConsortia
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def centralBehaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', centralBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * configure headers = headersUniversity
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def universityBehaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', universityBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * pause(5000)
    * def identifier = 'oai:folio.org:' + universityTenant + '/' + instanceId
    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * configure retry = { count: 12, interval: 2000 }

    # Single tenant GetRecord in Source record storage mode
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    * match getSubfield(response, '999', 'i') == instanceId
    * match getSubfield(response, '999', 's') == srsId
    * match getSubfield(response, '999', 'l') == linkedDataId
    * match getSubfield(response, '999', 't') == '0'
    * match getSubfield(response, '856', 'u') == instanceUrl
    * match getSubfield(response, '856', 't') == '0'
    * match getSubfield(response, '952', 't') == '0'

    # Change OAI-PMH record source to Inventory
    * url baseUrl
    * set behaviorPayload.configValue.recordsSource = 'Inventory'

    * configure headers = headersConsortia
    Given path 'oai-pmh/configuration-settings', centralBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * configure headers = headersUniversity
    Given path 'oai-pmh/configuration-settings', universityBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Single tenant GetRecord in Inventory mode
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    * match getSubfield(response, '999', 'i') == instanceId
    * match getSubfield(response, '999', 's') == srsId
    * match getSubfield(response, '999', 'l') == linkedDataId
    * match getSubfield(response, '999', 't') == '0'
    * match getSubfield(response, '856', 'u') == instanceUrl
    * match getSubfield(response, '856', 't') == '0'
    * match getSubfield(response, '952', 't') == '0'

    # Change OAI-PMH record source to Source record storage and Inventory
    * url baseUrl
    * set behaviorPayload.configValue.recordsSource = 'Source record storage and Inventory'

    * configure headers = headersConsortia
    Given path 'oai-pmh/configuration-settings', centralBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * configure headers = headersUniversity
    Given path 'oai-pmh/configuration-settings', universityBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Single tenant GetRecord in Source record storage and Inventory mode
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    * match getSubfield(response, '999', 'i') == instanceId
    * match getSubfield(response, '999', 's') == srsId
    * match getSubfield(response, '999', 'l') == linkedDataId
    * match getSubfield(response, '999', 't') == '0'
    * match getSubfield(response, '856', 'u') == instanceUrl
    * match getSubfield(response, '856', 't') == '0'
    * match getSubfield(response, '952', 't') == '0'

    # Suppress shared instance from discovery in member tenant
    * url baseUrl
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    * def memberInstanceBody = response
    * set memberInstanceBody.discoverySuppress = true

    * configure headers = headersUniversityTextPlain
    Given path 'inventory/instances', instanceId
    And request memberInstanceBody
    When method PUT
    Then status 204

    # Update source record suppression flag so Source record storage response carries discovery flag value
    * configure headers = headersConsortia
    Given path 'source-storage/records', srsId
    When method GET
    Then status 200
    * def suppressedSrsRecord = response
    * set suppressedSrsRecord.additionalInfo.suppressDiscovery = true

    Given path 'source-storage/records', srsId
    And request suppressedSrsRecord
    When method PUT
    * match [200, 204] contains responseStatus

    * pause(10000)
    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Single tenant GetRecord returns suppressed record with discovery flag value
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    * match getSubfield(response, '999', 'i') == instanceId
    * match getSubfield(response, '999', 's') == srsId
    * match getSubfield(response, '999', 'l') == linkedDataId
    * match getSubfield(response, '999', 't') == '1'
    * match getSubfield(response, '856', 'u') == instanceUrl
    * match getSubfield(response, '856', 't') == '1'
