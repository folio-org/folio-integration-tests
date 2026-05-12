@C688762
Feature: Edited items of LINKED_DATA instance

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login collegeUser1
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersUniversity
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  Scenario: Consortia | ListRecords: Verify that edit Item of shared LINKED_DATA Instance is retrieved in the responses of single tenant and cross-tenant harvests
    # Create LINKED_DATA instance
    * configure headers = headersConsortia

    Given def instance = call read(utilsPath + '@CreateLdInstance') { testTenant: '#(centralTenant)' }
    And def instanceId = instance.instanceId

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

    # check created data
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    Given path 'holdings-storage/holdings', holdingsId
    When method GET
    Then status 200
    Given path 'inventory/items', itemId
    When method GET
    Then status 200

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

    * url baseUrl
    * def from = isoDate()

    # edit item
    Given path 'item-storage/items', itemId
    When method GET
    Then status 200
    * def itemBody = response
    * eval itemBody['discoverySuppress'] = true

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

#    # Set instance 1 for deleteion
#    Given path 'inventory/instances/' + instanceId1 + '/mark-deleted'
#    When method DELETE
#    Then status 204
#
#    # Check deleted instance
#    Given path 'inventory/instances/' + instanceId1
#    When method GET
#    Then status 200
#    And match response.discoverySuppress == true
#    And match response.deleted == true
#    And match response.staffSuppress == true
#
#    # Switch to member tenant, edit instance 2 to set for deletion
#    * configure headers = headersUniversity
#    Given path 'inventory/instances/' + instanceId2
#    When method GET
#    Then status 200
#    * def instanceBody = response
#    * eval instanceBody['deleted'] = true
#    * eval instanceBody['staffSuppress'] = true
#    * eval instanceBody['discoverySuppress'] = true
#
#    Given path 'inventory/instances/' + instanceId2
#    And request instanceBody
#    When method PUT
#    Then status 204
#
#    * pause(5000)
#
#    # Check deleted instance
#    Given path 'inventory/instances/' + instanceId2
#    When method GET
#    Then status 200
#    And match response.discoverySuppress == true
#    And match response.deleted == true
#    And match response.staffSuppress == true
#
#    # Set local instance 3 for deleteion
#    Given path 'inventory/instances/' + instanceId3 + '/mark-deleted'
#    When method DELETE
#    Then status 204
#
#    # Check deleted instance
#    Given path 'inventory/instances/' + instanceId3
#    When method GET
#    Then status 200
#    And match response.discoverySuppress == true
#    And match response.deleted == true
#    And match response.staffSuppress == true
#
#    * def until = isoDate()
#
#    # OAI-PMH settings - source Inventory, Deleted records support
#    * def behaviorPayload = read('classpath:samples/behavior.json')
#    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
#    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
#    * set behaviorPayload.configValue.recordsSource = 'Inventory'
#    * set behaviorPayload.configValue.errorsProcessing = '200'
#
#    # save settings for central tenant
#    Given path 'oai-pmh/configuration-settings'
#    When method GET
#    Then status 200
#    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
#
#    Given path 'oai-pmh/configuration-settings', behaviorId
#    And request behaviorPayload
#    When method PUT
#    Then status 204
#
#    # save settings for university tenant
#    * configure headers = headersUniversity
#    Given path 'oai-pmh/configuration-settings'
#    When method GET
#    Then status 200
#
#    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
#    Given path 'oai-pmh/configuration-settings', behaviorId
#    And request behaviorPayload
#    When method PUT
#    Then status 204
#
#    * def identifier1 = 'oai:folio.org:' + universityTenant + '/' + instanceId1
#    * def identifier2 = 'oai:folio.org:' + universityTenant + '/' + instanceId2
#    * def identifier3 = 'oai:folio.org:' + universityTenant + '/' + instanceId3
#
#    * url edgeUrl
#    * configure headers = { 'Accept': 'text/xml' }
#
#    # Send single tenant harvest requests - GetRecord
#    # Instance 1
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'GetRecord'
#    And param identifier = identifier1
#    When method GET
#    Then status 200
#    And match response//header/identifier == identifier1
#    And match response//header/@status == 'deleted'
#
#    # Instance 2
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'GetRecord'
#    And param identifier = identifier2
#    When method GET
#    Then status 200
#    And match response//header/identifier == identifier2
#    And match response//header/@status == 'deleted'
#
#    # Instance 3
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'GetRecord'
#    And param identifier = identifier3
#    When method GET
#    Then status 200
#    And match response//header/identifier == identifier3
#    And match response//header/@status == 'deleted'
#
#    # Send single tenant harvest requests - ListRecords
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListRecords'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    # verify identifiers
#    * def ids = karate.xmlPath(response, '//header/identifier')
#    * match ids contains identifier1
#    * match ids contains identifier2
#    * match ids contains identifier3
#    # verify all headers have status="deleted"
#    * def statuses = karate.xmlPath(response, '//header/@status')
#    * match statuses == ['deleted', 'deleted', 'deleted']
#
#    # Send single tenant harvest requests - ListIdentifiers
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListIdentifiers'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    # verify identifiers
#    * def ids = karate.xmlPath(response, '//header/identifier')
#    * match ids contains identifier1
#    * match ids contains identifier2
#    * match ids contains identifier3
#    # verify all headers have status="deleted"
#    * def statuses = karate.xmlPath(response, '//header/@status')
#    * match statuses == ['deleted', 'deleted', 'deleted']
#
#    # Send cross-tenant harvest requests - ListRecords
#    Given path 'oai/records'
#    And param apikey = consortiumApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListRecords'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    # verify identifiers
#    * def ids = karate.xmlPath(response, '//header/identifier')
#    * match ids contains identifier1
#    * match ids contains identifier2
#    * match ids contains identifier3
#    # verify all headers have status="deleted"
#    * def statuses = karate.xmlPath(response, '//header/@status')
#    * match statuses == ['deleted', 'deleted', 'deleted']
#
#    # Send cross-tenant harvest requests - ListIdentifiers
#    Given path 'oai/records'
#    And param apikey = consortiumApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListIdentifiers'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    # verify identifiers
#    * def ids = karate.xmlPath(response, '//header/identifier')
#    * match ids contains identifier1
#    * match ids contains identifier2
#    * match ids contains identifier3
#    # verify all headers have status="deleted"
#    * def statuses = karate.xmlPath(response, '//header/@status')
#    * match statuses == ['deleted', 'deleted', 'deleted']
#
#    * url baseUrl
#
#    # Disable deleted records support
#    * def behaviorPayload = read('classpath:samples/behavior.json')
#    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
#    * set behaviorPayload.configValue.deletedRecordsSupport = 'no'
#    * set behaviorPayload.configValue.recordsSource = 'Inventory'
#    * set behaviorPayload.configValue.errorsProcessing = '200'
#
#    # save settings for central tenant
#    * configure headers = headersConsortia
#    Given path 'oai-pmh/configuration-settings'
#    When method GET
#    Then status 200
#    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
#
#    Given path 'oai-pmh/configuration-settings', behaviorId
#    And request behaviorPayload
#    When method PUT
#    Then status 204
#
#    # save settings for university tenant
#    * configure headers = headersUniversity
#    Given path 'oai-pmh/configuration-settings'
#    When method GET
#    Then status 200
#
#    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
#    Given path 'oai-pmh/configuration-settings', behaviorId
#    And request behaviorPayload
#    When method PUT
#    Then status 204
#
#    * url edgeUrl
#    * configure headers = { 'Accept': 'text/xml' }
#
#    # Send single tenant harvest requests - GetRecord
#    # Instance 1
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'GetRecord'
#    And param identifier = identifier1
#    When method GET
#    Then status 200
#    And match response//error/@code == 'idDoesNotExist'
#
#    # Instance 2
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'GetRecord'
#    And param identifier = identifier2
#    When method GET
#    Then status 200
#    And match response//error/@code == 'idDoesNotExist'
#
#    # Instance 3
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'GetRecord'
#    And param identifier = identifier3
#    When method GET
#    Then status 200
#    And match response//error/@code == 'idDoesNotExist'
#
#    # Send single tenant harvest requests - ListRecords
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListRecords'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    And match response//error/@code == 'noRecordsMatch'
#
#    # Send single tenant harvest requests - ListIdentifiers
#    Given path 'oai/records'
#    And param apikey = universityApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListIdentifiers'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    And match response//error/@code == 'noRecordsMatch'
#
#    # Send cross-tenant harvest requests - ListRecords
#    Given path 'oai/records'
#    And param apikey = consortiumApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListRecords'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    And match response//error/@code == 'noRecordsMatch'
#
#    # Send cross-tenant harvest requests - ListIdentifiers
#    Given path 'oai/records'
#    And param apikey = consortiumApikey
#    And param metadataPrefix = 'marc21_withholdings'
#    And param verb = 'ListIdentifiers'
#    And param from = from
#    And param until = until
#    When method GET
#    Then status 200
#    And match response//error/@code == 'noRecordsMatch'