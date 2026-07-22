# FAT-26989, Karate tests for mediated requests via mod-requests-mediated
@parallel=false
Feature: Mediated requests - create and retrieve via mod-requests-mediated

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * callonce read('classpath:vega/mediated-requests/mediated-requests-variables.feature')
    * callonce read('classpath:vega/common/mediated-requests-consortium-setup.feature')

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def createPatronUser = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreatePatronUser')
    * def createInventoryInCollege = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreateSharedInstanceWithItemInCollege')
    * def getRequest = read('classpath:vega/util/crud-utils.feature@GetRequest')
    * def getItem = read('classpath:vega/util/crud-utils.feature@GetItem')
    * def getCirculationItem = read('classpath:vega/util/crud-utils.feature@GetCirculationItem')
    * def getMediatedRequest = read('classpath:vega/util/crud-utils.feature@GetMediatedRequest')

    # Shared logins reused by every scenario
    * def uniLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def uniOkapitoken = uniLogin.okapitoken
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def centralOkapitoken = centralLogin.okapitoken
    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * def collegeOkapitoken = collegeLogin.okapitoken

    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * def headersCentral    = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralOkapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersCollege    = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeOkapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }

    # Shared inventory params reused by helpers
    * def baseInventoryParams =
      """
      {
        "centralOkapitoken": "#(centralOkapitoken)",
        "centralTenant": "#(centralTenant)",
        "consortiumId": "#(consortiumId)",
        "uniOkapitoken": "#(uniOkapitoken)",
        "universityTenant": "#(universityTenant)",
        "collegeOkapitoken": "#(collegeOkapitoken)",
        "collegeTenant": "#(collegeTenant)",
        "mrInstanceTypeId": "#(mrInstanceTypeId)",
        "mrUniLocationId": "#(mrUniLocationId)",
        "mrUniHoldingsSourceId": "#(mrUniHoldingsSourceId)",
        "mrCollegeLocationId": "#(mrCollegeLocationId)",
        "mrCollegeHoldingsSourceId": "#(mrCollegeHoldingsSourceId)",
        "mrMaterialTypeId": "#(mrMaterialTypeId)",
        "mrLoanTypeId": "#(mrLoanTypeId)"
      }
      """

  Scenario: create and decline item-level page mediated request
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'MR Page Item-level Test Instance'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    * configure headers = headersUniversity

    # Use the central service point as pickup — it is the shared pickup location visible
    # across tenants, matching the pattern used by ECS requests.
    Given path 'requests-mediated/mediated-requests'
    And request
      """
      {
        "requestType": "Page",
        "fulfillmentPreference": "Hold Shelf",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "instanceId": "#(inventory.instanceId)",
        "holdingsRecordId": "#(inventory.holdingId)",
        "itemId": "#(inventory.itemId)",
        "item": { "barcode": "#(inventory.itemBarcode)" },
        "requesterId": "#(patron.requesterId)",
        "pickupServicePointId": "#(mrCentralServicePointId)"
      }
      """
    When method POST
    Then status 201
    * def mediatedRequestId = response.id
    And match mediatedRequestId == '#notnull'
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == patron.requesterId
    And match response.pickupServicePointId == mrCentralServicePointId

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.id == mediatedRequestId
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == patron.requesterId
    And match response.pickupServicePointId == mrCentralServicePointId

    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'decline'
    When method POST
    Then status 204

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.id == mediatedRequestId
    And match response.status == 'Closed - Declined'

  Scenario: create and confirm item-level mediated page request
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'FAT-27027'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    # Wait for mod-search to index the item — confirm routing depends on cross-tenant instance visibility
    * configure headers = headersCentral
    * configure retry = { count: 40, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = patron.requesterId
    And param operation = 'create'
    And param itemId = inventory.itemId
    And retry until responseStatus == 200 && response && karate.sizeOf(response) > 0
    When method GET
    Then status 200
    * def allowedSpIds = response.Page ? response.Page.map(function(sp){ return sp.id }) : []
    * if (!allowedSpIds.includes(mrCentralServicePointId)) karate.fail('MR confirm: mrCentralServicePointId not found in allowed service points: ' + karate.toJson(response))

    * configure headers = headersUniversity

    Given path 'requests-mediated/mediated-requests'
    And request
      """
      {
        "requestType": "Page",
        "fulfillmentPreference": "Hold Shelf",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "instanceId": "#(inventory.instanceId)",
        "holdingsRecordId": "#(inventory.holdingId)",
        "itemId": "#(inventory.itemId)",
        "item": { "barcode": "#(inventory.itemBarcode)" },
        "requesterId": "#(patron.requesterId)",
        "pickupServicePointId": "#(mrCentralServicePointId)"
      }
      """
    When method POST
    Then status 201
    * def mediatedRequestId = response.id
    And match mediatedRequestId == '#notnull'
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == patron.requesterId
    And match response.pickupServicePointId == mrCentralServicePointId

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.id == mediatedRequestId
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == patron.requesterId
    And match response.pickupServicePointId == mrCentralServicePointId

    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'confirm'
    When method POST
    Then status 204

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.id == mediatedRequestId
    And match response.status == 'Open - Not yet filled'
    * def confirmedRequestId = response.confirmedRequestId
    And match confirmedRequestId == '#notnull'

    # Verify request and item in lending tenant (college)
    * configure headers = headersCollege
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    And match response.itemId == inventory.itemId

    * call getItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Paged'

    # Verify request and circulation item in central tenant
    * configure headers = headersCentral
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    And match response.itemId == inventory.itemId

    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Paged'

    # Verify request and circulation item in secure tenant (university)
    * configure headers = headersUniversity
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    And match response.itemId == inventory.itemId

    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Paged'

