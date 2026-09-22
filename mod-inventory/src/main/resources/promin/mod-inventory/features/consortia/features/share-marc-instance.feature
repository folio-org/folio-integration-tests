Feature: Sharing a local MARC instance with the central tenant

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * def marcUtilPath = 'classpath:promin/mod-inventory/features/consortia/util/marc-instance-util.feature'
    * def instanceTypeId = '6312d172-f0cf-40f6-b27d-9fa8feaf332f'

    * def sharingRetryLogic =
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

  Scenario: Local MARC instance is shared with the central tenant
    * configure headers = headersUniversity

    * def instanceId = uuid()
    * def instance = { id: '#(instanceId)', source: 'MARC', title: 'Local MARC instance', instanceTypeId: '#(instanceTypeId)' }
    * def created = call read(marcUtilPath + '@CreateLocalMarcInstance') { instance: '#(instance)', headersUser: '#(headersUniversity)' }
    * def instanceHrid = created.instanceHrid

    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant

    * configure retry = { count: 40, interval: 10000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until sharingRetryLogic()
    When method GET
    Then status 200
    And match response.sharingInstances[0].id == sharingId
    And match response.sharingInstances[0].status == 'COMPLETE'

    # Source instance is marked as shared and points at the HRID assigned by the central tenant
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-MARC'
    And match response.hrid != instanceHrid

    # Shared instance and its MARC record exist on the central tenant
    * configure headers = headersConsortia
    * configure retry = { count: 10, interval: 10000 }
    Given path 'inventory/instances', instanceId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'MARC'

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.state == 'ACTUAL'
    And match response.externalIdsHolder.instanceId == instanceId

  @C1528146
  Scenario: MARC instance with local statistical code cannot be shared and can be shared after removing local setting
    * configure headers = headersUniversity

    # Reference data created on the university tenant only, so the central tenant cannot resolve it
    * def statisticalCodeTypeId = uuid()
    * def statisticalCodeType = { id: '#(statisticalCodeTypeId)', name: '#("Local statistical code type " + statisticalCodeTypeId)', source: 'local' }
    Given path 'statistical-code-types'
    And request statisticalCodeType
    When method POST
    Then status 201

    * def statisticalCodeId = uuid()
    * def statisticalCode = { id: '#(statisticalCodeId)', code: '#("LOCAL-" + statisticalCodeId)', name: '#("Local statistical code " + statisticalCodeId)', statisticalCodeTypeId: '#(statisticalCodeTypeId)', source: 'local' }
    Given path 'statistical-codes'
    And request statisticalCode
    When method POST
    Then status 201

    * def instanceId = uuid()
    * def instance = { id: '#(instanceId)', source: 'MARC', title: 'Local MARC instance with local statistical code', instanceTypeId: '#(instanceTypeId)', statisticalCodeIds: ['#(statisticalCodeId)'] }
    * def created = call read(marcUtilPath + '@CreateLocalMarcInstance') { instance: '#(instance)', headersUser: '#(headersUniversity)' }
    * def instanceHrid = created.instanceHrid

    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId

    # Sharing is reported as failed because of the local statistical code
    * configure retry = { count: 40, interval: 10000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until sharingRetryLogic()
    When method GET
    Then status 200
    And match response.sharingInstances[0].id == sharingId
    And match response.sharingInstances[0].status == 'ERROR'
    And match response.sharingInstances[0].error contains statisticalCodeId

    # The instance is NOT shared: nothing is left behind on the central tenant
    * configure headers = headersConsortia
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 404

    # SRS soft-deletes records, so the copy created on the central tenant is either gone or marked as deleted
    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then assert responseStatus == 404 || (responseStatus == 200 && response.state == 'DELETED')

    # The local instance and its MARC record on the university tenant are untouched
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'MARC'
    And match response.hrid == instanceHrid
    And match response.statisticalCodeIds == [ '#(statisticalCodeId)' ]

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.state == 'ACTUAL'
    And match response.deleted == false

    # The local instance is still searchable on the university tenant (re-indexed after the rollback)
    * configure retry = { count: 12, interval: 5000 }
    Given path 'search/instances'
    And param query = 'id==' + instanceId
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1
    When method GET
    Then status 200
    And match response.instances[0].tenantId == universityTenant
    And match response.instances[0].shared == false
    And match response.instances[0].source == 'MARC'

    # Remove the local statistical code from the instance (edit of a non-MARC-controlled field)
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    * def instanceToUpdate = response
    * set instanceToUpdate.statisticalCodeIds = []

    Given path 'inventory/instances', instanceId
    And request instanceToUpdate
    When method PUT
    Then status 204

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.statisticalCodeIds == []

    # Share again: the same sharing record is reused by mod-consortia and now completes
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(uuid())',
        instanceIdentifier: '#(instanceId)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId

    * configure retry = { count: 40, interval: 10000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until sharingRetryLogic()
    When method GET
    Then status 200
    And match response.sharingInstances[0].id == sharingId
    And match response.sharingInstances[0].status == 'COMPLETE'

    # Source instance is now shared and its HRID is reassigned based on the central tenant's HRID settings
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-MARC'
    And match response.hrid != instanceHrid
    * def sharedHrid = response.hrid

    # The shared instance on the central tenant carries the same HRID
    * configure headers = headersConsortia
    * configure retry = { count: 10, interval: 10000 }
    Given path 'inventory/instances', instanceId
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'MARC'
    And match response.hrid == sharedHrid

    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.state == 'ACTUAL'
    And match response.externalIdsHolder.instanceId == instanceId

    # The shared instance is searchable from the university tenant as shared
    * configure headers = headersUniversity
    * configure retry = { count: 12, interval: 5000 }
    Given path 'search/instances'
    And param query = 'id==' + instanceId
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1 && response.instances[0].shared == true
    When method GET
    Then status 200
    And match response.instances[0].tenantId == centralTenant
    And match response.instances[0].hrid == sharedHrid
