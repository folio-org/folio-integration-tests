# For FAT-XXXX, Create Karate tests for ILR and TLR ECS requests via edge-patron
@parallel=false
Feature: Cross-Module Integration Tests for ILR and TLR ECS Requests

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    # Create tenants and users, initialize data
    * callonce read('classpath:consortia/init-consortia.feature')

#    # Wipe data afterwards
#    * configure afterFeature = function() { karate.call('classpath:consortia/destroy-data.feature'); }

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
    * def headersCentralConsortium = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)' }
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


  Scenario: Create shared instance, holding and item in university tenant
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

    # Share instance to central tenant
    * table shareInstanceData
      | instanceId | sourceTenantId       | targetTenantId     | consortiumId |
      | instanceId | universityTenantName | centralTenantName  | consortiumId |
    * callonce shareInstance shareInstanceData

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

    # Get allowed service points for the item (ILR)
    Given path 'patron/account', ilrUserId, 'item', itemId, 'allowed-service-points'
    When method GET
    Then status 200
    * def allowedServicePoints = response.allowedServicePoints
    * def ilrServicePointId = karate.filter(allowedServicePoints, function(x){ return x.requestTypes && x.requestTypes.indexOf('Page') > -1 })[0].id

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
#    * def instanceId = call uuid
#    * def randomNum = call randomMillis
#    * def instanceHrid = "in" + randomNum
#    * table instanceData
#      | id         | title                       | instanceTypeId           | hrid         |
#      | instanceId | 'Test TLR Request Instance' | universityInstanceTypeId | instanceHrid |
#    * def instance = call createInstanceWithHrid instanceData
#
#    # Share instance to central tenant
#    * table shareInstanceData
#      | instanceId | sourceTenantId       | targetTenantId     | consortiumId |
#      | instanceId | universityTenantName | centralTenantName  | consortiumId |
#    * call shareInstance shareInstanceData
#
#    # Verify status is 'COMPLETE'
#    * configure retry = { count: 20, interval: 5000 }
#    Given path 'consortia', consortiumId, 'sharing/instances'
#    And param instanceIdentifier = instanceId
#    And param sourceTenantId = universityTenantName
#    And retry until response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR'
#    When method GET
#    Then status 200
#    And def sharingInstance = response.sharingInstances[0]
#    And match sharingInstance.instanceIdentifier == instanceId
#    And match sharingInstance.sourceTenantId == universityTenantName
#    And match sharingInstance.targetTenantId == centralTenantName
#    And match sharingInstance.status == 'COMPLETE'
#
#    # Create holding in university tenant
#    * def holdingId = call uuid
#    * table holdingData
#      | id        | instanceId | locationId            | sourceId                   |
#      | holdingId | instanceId | universityLocationsId | universityHoldingsSourceId |
#    * call createHolding holdingData
#
#    # Create item in the holding in university tenant
#    * def itemId = call uuid
#    * table itemData
#      | id     | holdingsRecordId | barcode    | materialTypeId               | permanentLoanTypeId  | permanentLocationId      |
#      | itemId | holdingId        | randomNum  | universityMaterialTypeIdPhys | universityLoanTypeId | universityLocationsId    |
#    * call createItem itemData
#
#    # Create user in central tenant
#    * configure headers = headersCentral
#    * def tlrUserBarcode = 'TLR-ECS-UBC-' + randomNum
#    * table tlrUserData
#      | barcode        | username       | type     |
#      | tlrUserBarcode | tlrUserBarcode | "patron" |
#    * def tlrUser = call createUser tlrUserData
#    * def tlrUserId = tlrUser[0].response.id
#
#    # Get allowed service points for the instance (TLR)
#    Given path 'patron/account', tlrUserId, 'instance', instanceId, 'allowed-service-points'
#    When method GET
#    Then status 200
#    * def allowedServicePoints = response.allowedServicePoints
#    * def tlrServicePointId = karate.filter(allowedServicePoints, function(x){ return x.requestTypes && x.requestTypes.indexOf('Page') > -1 })[0].id
#
#    # Create TLR ECS request
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

#  Scenario: Verify TLR ECS request is available in university tenant
#    # Create instance, share it and create TLR request
#    * configure headers = headersUniversity
#    * def instanceId = call uuid
#    * def randomNum = call randomMillis
#    * def instanceHrid = "in" + randomNum
#    * table instanceData
#      | id         | title                           | instanceTypeId           | hrid         |
#      | instanceId | 'Verify TLR Request Instance'   | universityInstanceTypeId | instanceHrid |
#    * def instance = call createInstanceWithHrid instanceData
#
#    # Share instance to central tenant
#    * table shareInstanceData
#      | instanceId | sourceTenantId       | targetTenantId     | consortiumId |
#      | instanceId | universityTenantName | centralTenantName  | consortiumId |
#    * call shareInstance shareInstanceData
#
#    # Wait for sharing to complete
#    * configure retry = { count: 20, interval: 5000 }
#    Given path 'consortia', consortiumId, 'sharing/instances'
#    And param instanceIdentifier = instanceId
#    And param sourceTenantId = universityTenantName
#    And retry until response.sharingInstances[0].status == 'COMPLETE'
#    When method GET
#    Then status 200
#
#    # Create holding and item
#    * def holdingId = call uuid
#    * table holdingData
#      | id        | instanceId | locationId            | sourceId                   |
#      | holdingId | instanceId | universityLocationsId | universityHoldingsSourceId |
#    * call createHolding holdingData
#
#    * def itemId = call uuid
#    * table itemData
#      | id     | holdingsRecordId | barcode    | materialTypeId               | permanentLoanTypeId  | permanentLocationId      |
#      | itemId | holdingId        | randomNum  | universityMaterialTypeIdPhys | universityLoanTypeId | universityLocationsId    |
#    * call createItem itemData
#
#    # Create user in central tenant and create TLR request
#    * configure headers = headersCentral
#    * def verifyUserBarcode = 'VERIFY-TLR-UBC-' + randomNum
#    * table verifyUserData
#      | barcode          | username         | type     |
#      | verifyUserBarcode | verifyUserBarcode | "patron" |
#    * def verifyUser = call createUser verifyUserData
#    * def verifyUserId = verifyUser[0].response.id
#
#    # Create TLR request from central tenant
#    Given path 'patron/account', verifyUserId, 'instance', instanceId, 'hold'
#    And request { servicePointId: '#(centralServicePointId)' }
#    When method POST
#    Then status 201
#    * def verifyTlrRequestId = response.id
#
#    # Verify TLR request is available via consortium search in university tenant
#    * configure headers = headersCentralConsortium
#    Given path 'search/consortium/requests'
#    And param query = '(requesterId=="' + verifyUserId + '" and instanceId=="' + instanceId + '")'
#    When method GET
#    Then status 200
#    And match response.totalRecords >= 1
#    And match response.requests[0].requestType == 'Page'
#    And match response.requests[0].requestLevel == 'Title'
#
#    # Verify TLR request can be found via edge-patron
#    Given url edgeUrl
#    And path 'patron', 'account', verifyUserId, 'instance', instanceId, 'hold'
#    And header x-okapi-tenant = centralTenantName
#    And header x-okapi-token = okapitoken
#    When method GET
#    Then status 200
#    And match response.totalRecords >= 1
#    And match response.requests[0].requestLevel == 'Title'
