Feature: GetRecord for suppressed shared local MARC instances

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

  @C468257
  Scenario: Consortia | GetRecord: Suppressed shared local MARC Instances are skipped for member tenant harvests
    # Configure member tenant OAI-PMH behavior to skip suppressed records
    * configure headers = headersUniversity
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'false'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.recordsSource = 'Source record storage'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    Given path 'oai-pmh/configuration-settings'
    When method GET
    Then status 200
    * def universityBehaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    Given path 'oai-pmh/configuration-settings', universityBehaviorId
    And request behaviorPayload
    When method PUT
    Then status 204

    # Create local MARC records in member tenant through Data Import
    * call read('classpath:firebird/edge-oai-pmh/features/init_data/create-instances-di.feature') { testUser: '#(universityUser1)' }
    * url baseUrl
    * configure headers = headersUniversity
    * def availableMarcInstances =
      """
      function(instances) {
        return karate.filter(instances, function(instance) {
          return instance.source == 'MARC' && instance.title == 'Summerland' && !instance.discoverySuppress && !instance.deleted;
        });
      }
      """

    * configure retry = { count: 12, interval: 5000 }
    Given path 'inventory/instances'
    And param query = 'title=="Summerland"'
    And param limit = 100
    And retry until responseStatus == 200 && availableMarcInstances(response.instances).length >= 2
    When method GET
    Then status 200
    * def marcInstances = availableMarcInstances(response.instances)
    * def instanceId1 = marcInstances[0].id
    * def instanceId2 = marcInstances[1].id

    # Share first local MARC instance from member tenant to central tenant
    * url baseUrl
    * configure headers = headersUniversity
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
    And def sharingInstanceId1 = response.id

    * def retryLogic =
      """
      function() {
        if (responseStatus == 401) {
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

    * configure retry = { count: 40, interval: 10000 }
    * url baseUrl
    * configure headers = headersUniversity
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId1
    And param sourceTenantId = universityTenant
    And retry until retryLogic()
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId1
    And match sharingInstance.status == 'COMPLETE'

    # Verify first instance became shared in member tenant and is available in central tenant
    Given path 'inventory/instances', instanceId1
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-MARC'

    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId1
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId1

    # Share second local MARC instance from member tenant to central tenant
    * url baseUrl
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
    And def sharingInstanceId2 = response.id

    * configure retry = { count: 40, interval: 10000 }
    * url baseUrl
    * configure headers = headersUniversity
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId2
    And param sourceTenantId = universityTenant
    And retry until retryLogic()
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId2
    And match sharingInstance.status == 'COMPLETE'

    # Verify second instance became shared in member tenant and is available in central tenant
    Given path 'inventory/instances', instanceId2
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-MARC'

    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId2
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId2

    # Suppress first shared instance in member tenant
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId1
    When method GET
    Then status 200
    * def memberInstance = response
    * set memberInstance.discoverySuppress = true

    * configure headers = headersUniversityTextPlain
    Given path 'inventory/instances', instanceId1
    And request memberInstance
    When method PUT
    Then status 204

    * configure headers = headersUniversity
    Given path 'source-storage/records'
    And param externalId = instanceId1
    When method GET
    Then status 200
    * def memberSrsRecord = response.records[0]
    * set memberSrsRecord.additionalInfo.suppressDiscovery = true
    Given path 'source-storage/records', memberSrsRecord.id
    And request memberSrsRecord
    When method PUT
    * match [200, 204] contains responseStatus

    # Suppress second shared instance in central tenant
    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId2
    When method GET
    Then status 200
    * def centralInstance = response
    * set centralInstance.discoverySuppress = true

    * configure headers = headersConsortiaTextPlain
    Given path 'inventory/instances', instanceId2
    And request centralInstance
    When method PUT
    Then status 204

    * configure headers = headersConsortia
    Given path 'source-storage/records'
    And param externalId = instanceId2
    When method GET
    Then status 200
    * def centralSrsRecord = response.records[0]
    * set centralSrsRecord.additionalInfo.suppressDiscovery = true
    Given path 'source-storage/records', centralSrsRecord.id
    And request centralSrsRecord
    When method PUT
    * match [200, 204] contains responseStatus

    * pause(5000)
    * url edgeUrl
    * configure headers = { 'Accept': 'text/xml' }
    * def identifier1 = 'oai:folio.org:' + universityTenant + '/' + instanceId1
    * def identifier2 = 'oai:folio.org:' + universityTenant + '/' + instanceId2

    # marc21 GetRecord requests are skipped for both suppressed instances
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21'
    And param verb = 'GetRecord'
    And param identifier = identifier1
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21'
    And param verb = 'GetRecord'
    And param identifier = identifier2
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    # marc21_withholdings GetRecord requests are skipped for both suppressed instances
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier1
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'GetRecord'
    And param identifier = identifier2
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    # oai_dc GetRecord requests are skipped for both suppressed instances
    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'oai_dc'
    And param verb = 'GetRecord'
    And param identifier = identifier1
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'

    Given path 'oai/records'
    And param apikey = universityApikey
    And param metadataPrefix = 'oai_dc'
    And param verb = 'GetRecord'
    And param identifier = identifier2
    When method GET
    Then status 200
    And match response//error/@code == 'idDoesNotExist'
