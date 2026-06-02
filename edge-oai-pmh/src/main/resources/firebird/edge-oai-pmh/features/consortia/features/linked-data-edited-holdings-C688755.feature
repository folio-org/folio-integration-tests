Feature: Edited holdings of shared LINKED_DATA instance

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def headersUniversityTextPlain = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'text/plain', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersUniversity
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  @C688755
  Scenario: Consortia | ListRecords: Verify that edit Holdings of shared LINKED_DATA Instance is retrieved in single tenant and cross-tenant harvests
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
          karate.log('Unauthorized, re-logging in as consortiaAdmin');
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

    # Switch to member tenant and verify shared instance is available
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId

    # Create holdings in member tenant for marc21_withholdings output
    * def holdings = call read(utilsPath + '@CreateHoldings') { instanceId: '#(instanceId)', testTenant: '#(universityTenant)' }
    * def holdingsId = holdings.id

    # OAI-PMH settings: Source record storage, transfer suppressed records with discovery flag value
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.recordsSource = 'Source record storage'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    # Save settings for central tenant
    * configure headers = headersConsortia
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def centralBehaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', centralBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    # Save settings for member tenant
    * configure headers = headersUniversity
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def universityBehaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', universityBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * pause(1000)
    * def from = isoDate()
    * def until = isoDate()

    # Baseline single tenant harvest should not include the instance in this window
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//error/@code == 'noRecordsMatch'

    * url baseUrl
    * configure headers = headersUniversity
    * def from = isoDate()

    # Edit holdings record in member tenant
    Given path 'holdings-storage/holdings', holdingsId
    When method GET
    Then status 200
    * def holdingsBody = response
    * def updatedCallNumber = 'Edited holdings call number ' + uuid()
    * set holdingsBody.callNumber = updatedCallNumber
    * set holdingsBody.discoverySuppress = false

    * configure headers = headersUniversityTextPlain
    Given path 'holdings-storage/holdings', holdingsId
    And request holdingsBody
    When method PUT
    Then status 204

    * pause(5000)
    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * configure retry = { count: 12, interval: 2000 }

    # Single tenant harvest in Source record storage mode
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == updatedCallNumber
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Cross-tenant harvest in Source record storage mode
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == updatedCallNumber
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Change OAI-PMH record source to Inventory and save settings
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

    # Single tenant harvest in Inventory mode
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == updatedCallNumber
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Cross-tenant harvest in Inventory mode
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == updatedCallNumber
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Change OAI-PMH record source to Source record storage and Inventory and save settings
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

    # Single tenant harvest in Source record storage and Inventory mode
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == updatedCallNumber
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'

    # Cross-tenant harvest in Source record storage and Inventory mode
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    And retry until responseStatus == 200 && karate.toString(response).indexOf(instanceId) > -1
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='s'] == srsId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='i'] == instanceId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='l'] == linkedDataId
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t'] == '0'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == updatedCallNumber
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t'] == '0'
