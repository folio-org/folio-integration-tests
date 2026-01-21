@C729202
Feature: Deleted FOLIO instances

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * callonce read('classpath:firebird/edge-oai-pmh/features/init_data/create-instances-di.feature') { testUser : '#(universityUser1)' }

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login collegeUser1
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersUniversity
    * def utilsPath = 'classpath:firebird/edge-oai-pmh/features/utils.feature'

  Scenario: Consortia | Verify that deleted FOLIO Instances are retrieved in the responses of single tenant and cross-tenant harvests
    # Create FOLIO instances
    * configure headers = headersUniversity

    Given def instance = call read(utilsPath + '@CreateInstance') { source:'FOLIO', title:'Title1', testTenant: '#(universityTenant)' }
    And def instanceId1 = instance.id

    Given def instance = call read(utilsPath + '@CreateInstance') { source:'FOLIO', title:'Title2', testTenant: '#(universityTenant)' }
    And def instanceId2 = instance.id

    Given def instance = call read(utilsPath + '@CreateInstance') { source:'FOLIO', title:'Title3', testTenant: '#(universityTenant)' }
    And def instanceId3 = instance.id

    # create holdings records
    * def holdings1 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId1)', testTenant: '#(universityTenant)' }
    * def holdings2 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId2)', testTenant: '#(universityTenant)' }
    * def holdings3 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId3)', testTenant: '#(universityTenant)' }

    # share instance 1
    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId1)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId1
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant
    And def sharingInstanceId = response.id

    * def retryLogic =
      """
      function() {
        if (responseStatus == 401) {
          karate.log('Unauthorized, re-logging in as universityUser');
          var loginResult = karate.call('classpath:common-consortia/eureka/initData.feature@Login', universityUser1);
          var newToken = loginResult.okapitoken;
          var newHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': newToken, 'x-okapi-tenant': universityUser1.tenant, 'Accept': 'application/json' };
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
    And param instanceIdentifier = instanceId1
    And param sourceTenantId = universityTenant
    And retry until retryLogic()
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId1
    And match sharingInstance.sourceTenantId == universityTenant
    And match sharingInstance.targetTenantId == centralTenant
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is updated in source tenant with source = 'CONSORTIUM-FOLIO'
    Given path 'inventory/instances', instanceId1
    When method GET
    Then status 200
    And match response.id == instanceId1
    And match response.source == 'CONSORTIUM-FOLIO'

    # Verify if shared instance is accessible on the central tenant
    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId1
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId1

    # Share instance 2
    * configure headers = headersUniversity
    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId2)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId2
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant
    And def sharingInstanceId = response.id

    # Verify status is 'COMPLETE'
    * configure retry = { count: 40, interval: 10000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId2
    And param sourceTenantId = universityTenant
    And retry until retryLogic()
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId2
    And match sharingInstance.sourceTenantId == universityTenant
    And match sharingInstance.targetTenantId == centralTenant
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is updated in source tenant with source = 'CONSORTIUM-FOLIO'
    Given path 'inventory/instances', instanceId2
    When method GET
    Then status 200
    And match response.id == instanceId2
    And match response.source == 'CONSORTIUM-FOLIO'

    # Verify if shared instance is accessible on the central tenant
    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId2
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId2

    * def from = isoDate()

    # Set instance 1 for deleteion
    Given path 'inventory/instances/' + instanceId1 + '/mark-deleted'
    When method DELETE
    Then status 204

    # Check deleted instance
    Given path 'inventory/instances/' + instanceId1
    When method GET
    Then status 200
    And match response.discoverySuppress == true
    And match response.deleted == true
    And match response.staffSuppress == true

    # Switch to member tenant, edit instance 2 to set for deletion
    * configure headers = headersUniversity
    Given path 'inventory/instances/' + instanceId2
    When method GET
    Then status 200
    * def instanceBody = response
    * eval instanceBody['deleted'] = true
    * eval instanceBody['staffSuppress'] = true
    * eval instanceBody['discoverySuppress'] = true

    Given path 'inventory/instances/' + instanceId2
    And request instanceBody
    When method PUT
    Then status 204

    * pause(5000)

    # Check deleted instance
    Given path 'inventory/instances/' + instanceId2
    When method GET
    Then status 200
    And match response.discoverySuppress == true
    And match response.deleted == true
    And match response.staffSuppress == true

    # Set local instance 3 for deleteion
    Given path 'inventory/instances/' + instanceId3 + '/mark-deleted'
    When method DELETE
    Then status 204

    # Check deleted instance
    Given path 'inventory/instances/' + instanceId3
    When method GET
    Then status 200
    And match response.discoverySuppress == true
    And match response.deleted == true
    And match response.staffSuppress == true

    * def until = isoDate()

    # OAI-PMH settings - source Inventory, Deleted records support
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.recordsSource = 'Inventory'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    # save settings for central tenant
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    # save settings for university tenant
    * configure headers = headersUniversity
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200

    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * def identifier1 = 'oai:folio.org:' + universityTenant + '/' + instanceId1
    * def identifier2 = 'oai:folio.org:' + universityTenant + '/' + instanceId2
    * def identifier3 = 'oai:folio.org:' + universityTenant + '/' + instanceId3

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Send single tenant harvest requests - GetRecord
    # Instance 1
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier1
    When method GET
    Then status 200
    And match response//header/identifier == identifier1
    And match response//header/@status == 'deleted'

    # Instance 2
    #    Given path 'oai/records'
    #    And param apikey = universityApikey
    #    And param metadataPrefix = 'marc21_withholdings'
    #    And param verb = 'GetRecord'
    #    And param identifier = identifier2
    #    When method GET
    #    Then status 200
    #    And match response//header/identifier == identifier2
    #    And match response//header/@status == 'deleted'

    # Instance 3
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier3
    When method GET
    Then status 200
    And match response//header/identifier == identifier3
    And match response//header/@status == 'deleted'

    # Send single tenant harvest requests - ListRecords
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    # verify identifiers
    * def ids = karate.xmlPath(response, '//header/identifier')
    * match ids contains identifier1
    * match ids contains identifier2
    * match ids contains identifier3
    # verify all headers have status="deleted"
    * def statuses = karate.xmlPath(response, '//header/@status')
    * match statuses == ['deleted', 'deleted', 'deleted']

    # Send single tenant harvest requests - ListIdentifiers
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListIdentifiers'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    # verify identifiers
    * def ids = karate.xmlPath(response, '//header/identifier')
    * match ids contains identifier1
    * match ids contains identifier2
    * match ids contains identifier3
    # verify all headers have status="deleted"
    * def statuses = karate.xmlPath(response, '//header/@status')
    * match statuses == ['deleted', 'deleted', 'deleted']

    # Send cross-tenant harvest requests - ListRecords
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    # verify identifiers
    * def ids = karate.xmlPath(response, '//header/identifier')
    * match ids contains identifier1
    * match ids contains identifier2
    * match ids contains identifier3
    # verify all headers have status="deleted"
    * def statuses = karate.xmlPath(response, '//header/@status')
    * match statuses == ['deleted', 'deleted', 'deleted']

    # Send cross-tenant harvest requests - ListIdentifiers
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListIdentifiers'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    # verify identifiers
    * def ids = karate.xmlPath(response, '//header/identifier')
    * match ids contains identifier1
    * match ids contains identifier2
    * match ids contains identifier3
    # verify all headers have status="deleted"
    * def statuses = karate.xmlPath(response, '//header/@status')
    * match statuses == ['deleted', 'deleted', 'deleted']

    * url baseUrl

    # Disable deleted records support
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'no'
    * set behaviorPayload.configValue.recordsSource = 'Inventory'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    # save settings for central tenant
    * configure headers = headersConsortia
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    # save settings for university tenant
    * configure headers = headersUniversity
    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200

    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }

    # Send single tenant harvest requests - GetRecord
    # Instance 1
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier1
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    # Instance 2
    #    Given path 'oai/records'
    #    And param apikey = universityApikey
    #    And param metadataPrefix = 'marc21_withholdings'
    #    And param verb = 'GetRecord'
    #    And param identifier = identifier2
    #    When method GET
    #    Then status 200
    #    And match response//error/@code == 'idDoesNotExist'

    # Instance 3
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier3
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    # Send single tenant harvest requests - ListRecords
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//error/@code == 'noRecordsMatch'

    # Send single tenant harvest requests - ListIdentifiers
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListIdentifiers'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//error/@code == 'noRecordsMatch'

    # Send cross-tenant harvest requests - ListRecords
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//error/@code == 'noRecordsMatch'

    # Send cross-tenant harvest requests - ListIdentifiers
    Given path 'oai/records'
    And param apikey = consortiumApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListIdentifiers'
    And param from = from
    And param until = until
    When method GET
    Then status 200
    And match response//error/@code == 'noRecordsMatch'