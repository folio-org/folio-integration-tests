# For FAT-21606, Create Karate tests for ILR and TLR ECS requests via edge-patron
@parallel=false
Feature: Cross-Module Integration Tests for ILR and TLR ECS Requests

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    # Create tenants and users, initialize data
    * callonce read('classpath:consortia/init-consortia.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:consortia/destroy-data.feature'); }

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'mod-inventory'             |
      | 'folio-custom-fields'       |
      | 'edge-patron'               |
      | 'mod-patron'                |
      | 'mod-tlr'                   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |
      | 'mod-consortia'             |
      | 'mod-search'                |

    # Login as central tenant admin
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call read('classpath:consortia/headers.feature')
    * configure headers = headersCentral

    # Verify consortium is properly configured
    * configure headers = headersCentralConsortium
    Given path 'consortia'
    When method GET
    Then status 200
    * def consortiumList = response.consortia || []
    * print 'All consortia:', consortiumList
    * print 'Central tenant ID being checked:', centralTenantId

    * def matchingConsortia = karate.jsonPath(consortiumList, "$[?(@.centralTenantId == '" + centralTenantName + "' || @.centralTenantId == '" + centralTenantId + "')]")
    * print 'Matching consortia:', matchingConsortia

    * def consortium = matchingConsortia && matchingConsortia.length > 0 ? matchingConsortia[0] : null
    * print 'Selected consortium:', consortium

    Given path 'consortia', consortiumId, 'tenants'
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)' }
    And request { id: '#(centralTenantName)', code: 'AUTO', name: 'Central tenants name', isCentral: true }
    When method POST
    * print 'Register central tenant response status:', responseStatus
    * configure retry = { count: 20, interval: 5000 }
    Given path 'consortia-configuration'
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)' }
    And retry until response.centralTenantId == centralTenantName
    When method GET
    Then status 200

    # attempt to read consortium configuration using central tenant name to learn stored centralTenantId
    Given path 'consortia-configuration'
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)' }
    When method GET
    Then status 200
    * print 'Consortia configuration (via tenant name):', response
    * def resolvedCentralTenantId = response.centralTenantId
    * print 'Resolved centralTenantId from consortia-configuration:', resolvedCentralTenantId

    # Ensure centralTenantName is available
    * def centralTenantName = (typeof centralTenantName !== 'undefined') ? centralTenantName : response.centralTenantId
    * print 'Using centralTenantName:', centralTenantName

    # reset headers back to central tenant name for regular calls
    * configure headers = headersCentral

    # Enable ECS TLR feature via settings (consortium-level; use consortium headers)
    * configure headers = headersCentralConsortium
    Given path 'tlr/settings'
    And request { "ecsTlrFeatureEnabled": true, "excludeFromEcsRequestLendingTenantSearch": [] }
    When method PUT
    Then status 204
    * configure headers = headersCentral

    # Setup variables
    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

  Scenario: Create shared instance, holding and item in university tenant, then create ILR ECS request
    # Create user group and user in central tenant for this specific scenario
    * configure headers = headersCentral
    * def ilrGroupId = java.util.UUID.randomUUID().toString()
    * print 'DEBUG: ilrGroupId value:', ilrGroupId
    * def ilrGroup = 'lib-ilr-' + ilrGroupId
    * def ilrTenantId = centralTenantName
    * def groupResult = call read('classpath:reusable/user-init-data.feature@CreateGroup') { id: '#(ilrGroupId)', group: '#(ilrGroup)', tenantId: '#(ilrTenantId)' }
    * def ilrPatronId = groupResult.groupId

    * def ilrUserId = java.util.UUID.randomUUID().toString()
    * def randomNum = callonce randomMillis
    * def ilrUserBarcode = 'ILR-ECS-UBC-' + randomNum
    * def ilrUserName = ilrUserBarcode
    * def ilrFirstName = 'TestFirstName'
    * def ilrLastName = 'TestLastName'
    * def ilrExternalId = java.util.UUID.randomUUID().toString()
    * call read('classpath:reusable/user-init-data.feature@CreateUser') { userId: '#(ilrUserId)', firstName: '#(ilrFirstName)', lastName: '#(ilrLastName)', userBarcode: '#(ilrUserBarcode)', userName: '#(ilrUserName)', externalId: '#(ilrExternalId)', patronId: '#(ilrPatronId)' }

    # Switch to university tenant for instance creation
    * configure headers = headersUniversity

    # Create instance in university tenant
    * def instanceId = call uuid
    * def randomNum = '' + java.lang.System.currentTimeMillis()
    * def instanceHrid = "in" + randomNum
    * table instanceData
      | id         | title      | instanceTypeId           | hrid         |
      | instanceId | instanceId | universityInstanceTypeId | instanceHrid |
    * def v = call createInstanceWithHrid instanceData

    # Share instance to central tenant (using improved sharing)
    * def sharingId = call uuid
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
    """
    {
      id: '#(sharingId)',
      instanceIdentifier: '#(instanceId)',
      sourceTenantId:  '#(universityTenantName)',
      targetTenantId:  '#(centralTenantName)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == universityTenantName
    And match response.targetTenantId == centralTenantName
    And def sharingInstanceId = response.id

    # Verify status is 'COMPLETE'
    * configure retry = { count: 20, interval: 30000 }
    * print 'Polling for sharing status completion...'
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenantName
    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
    When method GET
    * print 'DEBUG: sharingInstances response:', response
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId
    And match sharingInstance.sourceTenantId == universityTenantName
    And match sharingInstance.targetTenantId == centralTenantName
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is update in source tenant with source = 'CONSORTIUM-FOLIO'
    * java.lang.Thread.sleep(5000)
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'

    # Create holding in university tenant
    * def holdingId = call uuid
    * table holdingData
      | id        | instanceId | locationId            | sourceId                   |
      | holdingId | instanceId | universityLocationsId | universityHoldingsSourceId |
    * def v = call createHolding holdingData

    # Create item in the holding in university tenant
    * def itemId = call uuid
    * table itemData
      | id     | holdingsRecordId | barcode    | materialTypeId               | permanentLoanTypeId  | permanentLocationId      |
      | itemId | holdingId        | randomNum  | universityMaterialTypeIdPhys | universityLoanTypeId | universityLocationsId    |
    * def v = call createItem itemData

    # Verify instance exists in university tenant
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200

    # Verify holding exists in university tenant
    Given path 'holdings-storage/holdings', holdingId
    When method GET
    Then status 200

    # Verify item exists in university tenant
    Given path 'inventory/items', itemId
    When method GET
    Then status 200

    * print 'DEBUG: okapitoken:', okapitoken
    * print 'DEBUG: ilrUserId:', ilrUserId
    * print 'DEBUG: itemId:', itemId
    # Define freshHeadersCentral with consortium headers for consortium-level requests
    * def freshHeadersCentral = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    # Print user-tenants for this token and tenant
    * configure headers = freshHeadersCentral
    Given path 'user-tenants'
    When method GET
    Then status 200
    * print 'DEBUG: user-tenants response:', response

    # Check user-tenants with tenantId param (as mod-search does)
    Given path 'user-tenants'
    And param tenantId = centralTenantName
    When method GET
    Then status 200
    * print 'DEBUG: user-tenants by tenantId:', response

    * print 'DEBUG: headers before allowed-service-points:', freshHeadersCentral
    # Extra debug and wait before allowed-service-points call
    * print 'DEBUG: ilrUserId:', ilrUserId
    * print 'DEBUG: itemId:', itemId

    # Now make the allowed-service-points call with debug output using consortium headers
    * configure headers = freshHeadersCentral
    Given path 'patron/account', ilrUserId, 'item', itemId, 'allowed-service-points'
    When method GET
    * print 'DEBUG: allowed-service-points response status:', responseStatus
    * print 'DEBUG: allowed-service-points response:', response
    Then status 200
    * def allowedServicePoints = response.allowedServicePoints

    # Find Central Service point in the response by matching centralServicePointsId
    * def matched = karate.filter(allowedServicePoints, function(x){ return x.id == centralServicePointsId })
    * def ilrServicePointId = matched[0].id
    * print 'DEBUG: ilrServicePointId:', ilrServicePointId

    # Reset to standard central tenant headers
    * configure headers = headersCentral

    # Create ILR ECS request
    Given path 'patron/account', ilrUserId, 'item', itemId, 'hold'
    And headers headersCentralConsortium
    And request
    """
    {
      "instanceId": "#(instanceId)",
      "servicePointId": "#(ilrServicePointId)",
      "pickupLocationId": "#(ilrServicePointId)",
      "requestDate": "#(new java.util.Date().toInstant().toString())"
    }
    """
    When method POST
    Then status 201
    * print 'DEBUG: ILR ECS hold response:', response
    And match response.status == 'Open - Not yet filled'
    And match response.item.itemId == itemId
    And match response.item.instanceId == instanceId
    And match response.pickupLocationId == ilrServicePointId

  Scenario: Create shared instance, holding and item in university tenant, then create TLR ECS request
    # Create user group and user in central tenant for this specific scenario
    * configure headers = headersCentral
    * def tlrGroupId = java.util.UUID.randomUUID().toString()
    * print 'DEBUG: tlrGroupId value:', tlrGroupId
    * def tlrGroup = 'lib-tlr-' + tlrGroupId
    * def tlrTenantId = centralTenantName
    * def groupResult = call read('classpath:reusable/user-init-data.feature@CreateGroup') { id: '#(tlrGroupId)', group: '#(tlrGroup)', tenantId: '#(tlrTenantId)' }
    * def tlrPatronId = groupResult.groupId

    * def tlrUserId = java.util.UUID.randomUUID().toString()
    * def randomNum = callonce randomMillis
    * def tlrUserBarcode = 'TLR-ECS-UBC-' + randomNum
    * def tlrUserName = tlrUserBarcode
    * def tlrFirstName = 'TestFirstName'
    * def tlrLastName = 'TestLastName'
    * def tlrExternalId = java.util.UUID.randomUUID().toString()
    * call read('classpath:reusable/user-init-data.feature@CreateUser') { userId: '#(tlrUserId)', firstName: '#(tlrFirstName)', lastName: '#(tlrLastName)', userBarcode: '#(tlrUserBarcode)', userName: '#(tlrUserName)', externalId: '#(tlrExternalId)', patronId: '#(tlrPatronId)' }

    # Switch to university tenant for instance creation
    * configure headers = headersUniversity

    # Create instance in university tenant
    * def instanceId = call uuid
    * def randomNum = '' + java.lang.System.currentTimeMillis()
    * def instanceHrid = "in" + randomNum
    * table instanceData
      | id         | title      | instanceTypeId           | hrid         |
      | instanceId | instanceId | universityInstanceTypeId | instanceHrid |
    * def v = call createInstanceWithHrid instanceData

    # Share instance to central tenant
    * def sharingId = call uuid
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
    """
    {
      id: '#(sharingId)',
      instanceIdentifier: '#(instanceId)',
      sourceTenantId:  '#(universityTenantName)',
      targetTenantId:  '#(centralTenantName)'
    }
    """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == universityTenantName
    And match response.targetTenantId == centralTenantName
    And def sharingInstanceId = response.id

    # Verify status is 'COMPLETE'
    * configure retry = { count: 20, interval: 30000 }
    * print 'Polling for sharing status completion...'
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenantName
    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
    When method GET
    * print 'DEBUG: sharingInstances response:', response
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId
    And match sharingInstance.sourceTenantId == universityTenantName
    And match sharingInstance.targetTenantId == centralTenantName
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is updated in source tenant with source = 'CONSORTIUM-FOLIO'
    * java.lang.Thread.sleep(5000)
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'

    # Create holding in university tenant
    * def tlrHoldingId = call uuid
    * table tlrHoldingData
      | id           | instanceId | locationId            | sourceId                   |
      | tlrHoldingId | instanceId | universityLocationsId | universityHoldingsSourceId |
    * def v = call createHolding tlrHoldingData

    # Create item in the holding in university tenant
    * def tlrItemId = call uuid
    # createItem.feature uses holdingId from scope directly
    * def holdingId = tlrHoldingId
    * table tlrItemData
      | id        | holdingsRecordId | barcode    | materialTypeId               | permanentLoanTypeId  | permanentLocationId   |
      | tlrItemId | tlrHoldingId     | randomNum  | universityMaterialTypeIdPhys | universityLoanTypeId | universityLocationsId |
    * def v = call createItem tlrItemData

    # Get allowed service points for TLR instance hold (kept for debug/visibility)
    * def freshHeadersCentral = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    * configure headers = freshHeadersCentral
    Given path 'patron/account', tlrUserId, 'instance', instanceId, 'allowed-service-points'
    When method GET
    * print 'DEBUG: TLR allowed-service-points response status:', responseStatus
    * print 'DEBUG: TLR allowed-service-points response:', response
    Then status 200
    * def allowedServicePoints = response.allowedServicePoints
    * print 'DEBUG: allowedServicePoints:', allowedServicePoints

    # Find Central Service point in the response by matching centralServicePointsId
    * def matched = karate.filter(allowedServicePoints, function(x){ return x.id == centralServicePointsId })
    * def tlrServicePointId = matched[0].id
    * print 'DEBUG: tlrServicePointId:', tlrServicePointId

    # Reset to standard central tenant headers
    * configure headers = headersCentral

    # Create TLR ECS request
    Given path 'patron/account', tlrUserId, 'instance', instanceId, 'hold'
    And headers headersCentralConsortium
    And request
    """
    {
      "instanceId": "#(instanceId)",
      "servicePointId": "#(tlrServicePointId)",
      "pickupLocationId": "#(tlrServicePointId)",
      "requestDate": "#(new java.util.Date().toInstant().toString())"
    }
    """
    When method POST
    Then status 201
    * print 'DEBUG: TLR ECS hold response:', response
    And match response.status == 'Open - Not yet filled'
    And match response.item.instanceId == instanceId
    And match response.pickupLocationId == tlrServicePointId
