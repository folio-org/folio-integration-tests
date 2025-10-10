# For FAT-XXXX, Create Karate tests for ILR and TLR ECS requests via edge-patron
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

    # Login as central tenant admin
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(universityTenantName)' }
    * def headersCentralConsortium = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
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

    # Import reusable user creation helper
    * def createUser = read('classpath:reusable/createUser.feature')

    # Setup variables
    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity


  Scenario: Create shared instance, holding and item in university tenant, then create ILR ECS request
    # Switch to university tenant for instance creation
    * configure headers = headersUniversity

    # Create instance in university tenant
    * def instanceId = callonce uuid
    * def randomNum = callonce randomMillis
    * def instanceHrid = "in" + randomNum
    * table instanceData
      | id         | title      | instanceTypeId           | hrid         |
      | instanceId | instanceId | universityInstanceTypeId | instanceHrid |
    * callonce createInstanceWithHrid instanceData

    # Share instance to central tenant (using improved sharing)
    * def sharingId = callonce uuid
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
    * configure retry = { count: 120, interval: 30000 }
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

    # Create user in central tenant
    * configure headers = headersCentral
    * def ilrUserBarcode = 'ILR-ECS-UBC-' + randomNum
    * table ilrUserData
      | barcode        | username       | type     |
      | ilrUserBarcode | ilrUserBarcode | "patron" |
    * def ilrUser = call createUser ilrUserData
    * def ilrUserId = ilrUser[0].response.id

    * print 'DEBUG: okapitoken:', okapitoken
    * print 'DEBUG: ilrUserId:', ilrUserId
    * print 'DEBUG: itemId:', itemId
    # Define freshHeadersCentral before use
    * def freshHeadersCentral = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)' }
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

    # Now make the allowed-service-points call with debug output
    * configure headers = freshHeadersCentral
    Given path 'patron/account', ilrUserId, 'item', itemId, 'allowed-service-points'
    When method GET
    * print 'DEBUG: allowed-service-points response status:', responseStatus
    * print 'DEBUG: allowed-service-points response:', response
    Then status 200
    * def allowedServicePoints = response.allowedServicePoints
    * def ilrServicePointId = karate.filter(allowedServicePoints, function(x){ return x.requestTypes && x.requestTypes.indexOf('Page') > -1 })[0].id


    # Reset to standard central tenant headers
    * configure headers = headersCentral

    # Create ILR ECS request
    Given path 'patron/account', ilrUserId, 'item', itemId, 'hold'
    And request { servicePointId: '#(ilrServicePointId)' }
    When method POST
    Then status 201
    * def ilrRequestId = response.id
    And match response.itemId == itemId
    And match response.requesterId == ilrUserId
    And match response.servicePointId == ilrServicePointId
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'

#  Scenario: Create TLR ECS request for shared instance
#    # Switch to university tenant for instance creation
#    * configure headers = headersUniversity
#
#    # Create instance in university tenant
#    * def instanceId = callonce uuid
#    * def randomNum = callonce randomMillis
#    * def instanceHrid = "in" + randomNum
#    * table instanceData
#      | id         | title      | instanceTypeId           | hrid         |
#      | instanceId | instanceId | universityInstanceTypeId | instanceHrid |
#    * callonce createInstanceWithHrid instanceData
#
#    # Share instance to central tenant (using improved sharing)
#    * def sharingId = callonce uuid
#    Given path 'consortia', consortiumId, 'sharing/instances'
#    And request
#    """
#    {
#      id: '#(sharingId)',
#      instanceIdentifier: '#(instanceId)',
#      sourceTenantId:  '#(universityTenantName)',
#      targetTenantId:  '#(centralTenantName)'
#    }
#    """
#    When method POST
#    Then status 201
#    And match response.instanceIdentifier == instanceId
#    And match response.sourceTenantId == universityTenantName
#    And match response.targetTenantId == centralTenantName
#    And def sharingInstanceId = response.id
#
#    # Verify status is 'COMPLETE'
#    * configure retry = { count: 60, interval: 15000 }
#    * print 'Polling for TLR sharing status completion...'
#    Given path 'consortia', consortiumId, 'sharing/instances'
#    And param instanceIdentifier = instanceId
#    And param sourceTenantId = universityTenantName
#    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
#    When method GET
#    Then status 200
#    And def sharingInstance = response.sharingInstances[0]
#    And match sharingInstance.id == sharingInstanceId
#    And match sharingInstance.instanceIdentifier == instanceId
#    And match sharingInstance.sourceTenantId == universityTenantName
#    And match sharingInstance.targetTenantId == centralTenantName
#    And match sharingInstance.status == 'COMPLETE'
#
#    # Verify shared instance is updated in source tenant with source = 'CONSORTIUM-FOLIO'
#    * java.lang.Thread.sleep(5000)
#    Given path 'inventory/instances', instanceId
#    When method GET
#    Then status 200
#    And match response.id == instanceId
#    And match response.source == 'CONSORTIUM-FOLIO'
#
#    # Create holding in university tenant
#    * def holdingId = call uuid
#    * table holdingData
#      | id        | instanceId | locationId            | sourceId                   |
#      | holdingId | instanceId | universityLocationsId | universityHoldingsSourceId |
#    * def v = call createHolding holdingData
#
#    # Create item in the holding in university tenant
#    * def itemId = call uuid
#    * table itemData
#      | id     | holdingsRecordId | barcode    | materialTypeId               | permanentLoanTypeId  | permanentLocationId      |
#      | itemId | holdingId        | randomNum  | universityMaterialTypeIdPhys | universityLoanTypeId | universityLocationsId    |
#    * def v = call createItem itemData
#
#    # Verify instance exists in university tenant
#    Given path 'inventory/instances', instanceId
#    When method GET
#    Then status 200
#
#    # Verify holding exists in university tenant
#    Given path 'holdings-storage/holdings', holdingId
#    When method GET
#    Then status 200
#
#    # Verify item exists in university tenant
#    Given path 'inventory/items', itemId
#    When method GET
#    Then status 200
#
#    # Create user in central tenant for TLR request
#    * configure headers = headersCentral
#    * def tlrUserBarcode = 'TLR-ECS-UBC-' + randomNum
#    * table tlrUserData
#      | barcode        | username       | type     |
#      | tlrUserBarcode | tlrUserBarcode | "patron" |
#    * def tlrUser = call createUser tlrUserData
#    * def tlrUserId = tlrUser[0].response.id
#
#    # Based on working example from update-ownership.feature
#    # 1. Re-login as central tenant admin to get a fresh token
#    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
#    * def freshHeadersCentral = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)' }
#    * configure headers = freshHeadersCentral
#
#    # 2. Make sure consortium is configured - similar to update-ownership.feature
#    Given path 'consortia', consortiumId, 'tenants'
#    And request { id: '#(centralTenantName)', code: 'AUTO', name: 'Central tenant', isCentral: true }
#    When method POST
#    * print 'Re-register central tenant response status for TLR:', responseStatus
#
#    # Assert and print centralTenantName vs centralTenantId for TLR
#    * print 'TLR ASSERT: centralTenantName:', centralTenantName, 'centralTenantId:', centralTenantId
#    * match centralTenantName == centralTenantId
#    # Print debug info before TLR allowed-service-points call
#    * print 'TLR DEBUG: x-okapi-tenant header:', freshHeadersCentral["x-okapi-tenant"]
#    * match freshHeadersCentral["x-okapi-tenant"] == centralTenantId
#    * print 'TLR DEBUG: okapitoken:', okapitoken
#    * print 'TLR DEBUG: tlrUserId:', tlrUserId
#    * print 'TLR DEBUG: instanceId:', instanceId
#    # Print user-tenants for this token and tenant
#    * configure headers = freshHeadersCentral
#    Given path 'user-tenants'
#    When method GET
#    Then status 200
#    * print 'TLR DEBUG: user-tenants response:', response
#    * def foundUser = karate.filter(response.userTenants, function(x){ return x.userId == tlrUserId && x.tenantId == centralTenantId })
#    * print 'TLR ASSERT: user found in user-tenants for central tenant:', foundUser
#
#    # Now make the TLR allowed-service-points call with debug output (instance-level endpoint)
#    Given path 'patron/account', tlrUserId, 'instance', instanceId, 'allowed-service-points'
#    When method GET
#    * print 'TLR DEBUG: allowed-service-points response status:', responseStatus
#    * print 'TLR DEBUG: allowed-service-points response:', response
#    Then status 200
#    * def allowedServicePoints = response.allowedServicePoints
#    * def tlrServicePointId = karate.filter(allowedServicePoints, function(x){ return x.requestTypes && x.requestTypes.indexOf('Page') > -1 })[0].id
#
#    # Reset to standard central tenant headers
#    * configure headers = headersCentral
#
#    # Create TLR ECS request (instance-level endpoint)
#    Given path 'patron/account', tlrUserId, 'instance', instanceId, 'hold'
#    And request { servicePointId: '#(tlrServicePointId)' }
#    When method POST
#    Then status 201
#    * def tlrRequestId = response.id
#    And match response.instanceId == instanceId
#    And match response.requesterId == tlrUserId
#    And match response.servicePointId == tlrServicePointId
#    And match response.requestType == 'Page'
#    And match response.requestLevel == 'Title'
