Feature: Edited items of shared LINKED_DATA instance

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def headersUniversityTextPlain = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'text/plain', 'Authtoken-Refresh-Cache': 'true' }

    * call login collegeUser1
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersUniversity
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  @C688762
  Scenario: Consortia | ListRecords: Verify that edit Item of shared LINKED_DATA Instance is retrieved in the responses of single tenant and cross-tenant harvests
    # Create LINKED_DATA instance
    * configure headers = headersConsortia

    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(centralTenant)' }
    And def instanceId = instance.inventoryId
    And def srsId = instance.srsId
    And def linkedDataId = instance.linkedDataId

    * pause(5000)

    # share created instance
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

    # Verify status is 'COMPLETE'
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

    # switch to member tenant
    * configure headers = headersUniversity

    # Verify if shared instance is accessible on the member tenant
    Given path 'inventory/instances', instanceId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId

    # create holdings record and item
    * def holdings = call read(utilsPath+'@CreateHoldings') { instanceId: '#(instanceId)', testTenant: '#(universityTenant)' }
    * def holdingsId = holdings.id
    * def item = call read(utilsPath+'@CreateSimpleItem') { holdingsId: '#(holdingsId)', testTenant: '#(universityTenant)'  }
    * def itemId = item.id

    # OAI-PMH settings - Source record storage, Deleted records support
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.recordsSource = 'Source record storage'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    # save settings for central tenant
    * configure headers = headersConsortia
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def centralBehaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', centralBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    # save settings for university tenant
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

    # Send single tenant harvest request
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

    # edit item
    Given path 'item-storage/items', itemId
    When method GET
    Then status 200
    * def itemBody = response
    * eval itemBody['discoverySuppress'] = true

    * configure headers = headersUniversityTextPlain
    Given path 'item-storage/items', itemId
    And request itemBody
    When method PUT
    Then status 204

    * def until = isoDate()

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Send single tenant harvest request
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

    # Send cross-tenant harvest request
    Given path 'oai/records'
    And param apikey = consortiumApikey
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

    # Change OAI-PMH record source to 'Inventory' and save settings
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

    # Send single tenant harvest request
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

    # Send cross-tenant harvest request
    Given path 'oai/records'
    And param apikey = consortiumApikey
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

    # Change OAI-PMH record source to 'Source record storage and Inventory' and save settings
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

    # Send single tenant harvest request
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

    # Send cross-tenant harvest request
    Given path 'oai/records'
    And param apikey = consortiumApikey
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