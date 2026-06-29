Feature: GetRecord for edited main title of shared LINKED_DATA instance

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def headersConsortiaTextPlain = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'text/plain', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersUniversity
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  @C667579
  Scenario: Consortia | GetRecord: Verify edited main title of shared LINKED_DATA Instance is retrieved for member tenant harvest
    # Create LINKED_DATA instance in central tenant
    * configure headers = headersConsortia
    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(centralTenant)' }
    And def instanceId = instance.inventoryId
    And def srsId = instance.srsId
    And def linkedDataId = instance.linkedDataId
    * pause(5000)

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

    # Edit main title in central tenant
    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    * def updatedInstance = response
    * def updatedMainTitle = 'Updated shared linked data GetRecord title ' + uuid()
    * set updatedInstance.title = updatedMainTitle

    * configure headers = headersConsortiaTextPlain
    Given path 'inventory/instances', instanceId
    And request updatedInstance
    When method PUT
    Then status 204

    * configure headers = headersConsortia
    Given path 'source-storage/records', srsId
    When method GET
    Then status 200
    * def srsRecord = response
    * def set245a =
      """
      function(fields, value) {
        for (var i = 0; i < fields.length; i++) {
          if (fields[i]['245']) {
            var subfields = fields[i]['245'].subfields;
            for (var j = 0; j < subfields.length; j++) {
              if (subfields[j]['a'] != null) {
                subfields[j]['a'] = value;
                return true;
              }
            }
            subfields.push({ a: value });
            return true;
          }
        }
        return false;
      }
      """
    * def updated245 = set245a(srsRecord.parsedRecord.content.fields, updatedMainTitle)
    * match updated245 == true
    Given path 'source-storage/records', srsId
    And request srsRecord
    When method PUT
    * match [200, 204] contains responseStatus

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
    And retry until responseStatus == 200 && karate.toString(response).indexOf(updatedMainTitle) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == updatedMainTitle
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Change OAI-PMH record source to Inventory for both tenants
    * set behaviorPayload.configValue.recordsSource = 'Inventory'
    * url baseUrl
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
    And retry until responseStatus == 200 && karate.toString(response).indexOf(updatedMainTitle) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == updatedMainTitle
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Change OAI-PMH record source to Source record storage and Inventory for both tenants
    * set behaviorPayload.configValue.recordsSource = 'Source record storage and Inventory'
    * url baseUrl
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
    And retry until responseStatus == 200 && karate.toString(response).indexOf(updatedMainTitle) > -1
    When method GET
    Then status 200
    And match response//header/identifier == identifier
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='245']/*[local-name()='subfield'][@code='a'] == updatedMainTitle
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'
