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

    # Force a full mod-search reindex so the college copy of the instance is indexed regardless
    # of Kafka delivery speed. mod-requests-mediated queries mod-search to find secondary tenants
    # on confirm; without this, confirm returns 500 TenantPickingException on slow environments.
    * configure headers = headersCentral
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then match [200, 400] contains responseStatus

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

    # Retry confirm until mod-search has indexed the college copy of the instance.
    # mod-requests-mediated queries mod-search to find secondary tenants; if Kafka hasn't
    # propagated the college instance yet, confirm returns 500 TenantPickingException.
    # The 500 occurs before any state change, so retrying the POST is safe.
    * configure retry = { count: 40, interval: 15000 }
    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'confirm'
    And retry until responseStatus == 204
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

  Scenario: mediated request - send item in transit and confirm arrival
    # Extends FAT-27027: after confirming the mediated request, move the item through the
    # full fulfillment flow. Note on ordering: mod-requests-mediated only finds a mediated
    # request for arrival confirmation while it is in step 'In transit for approval', and
    # only finds one for sending in transit while it is in step 'Item arrived'
    # (MediatedRequestsRepository), so the flow is:
    #   1. check-in in lending tenant (college)      -> 'Open - In transit for approval'
    #   2. confirm item arrival in secure tenant     -> 'Open - Item arrived'
    #   3. send item in transit in secure tenant     -> 'Open - In transit to be checked out'
    #   4. check-in in secure tenant (university)    -> 'Open - Awaiting pickup'
    # Statuses of all three requests (secondary/college, intermediate/central,
    # primary/university) are verified at every step.
    #
    # ENVIRONMENT REQUIREMENT: mod-requests-mediated applies the Kafka-driven status
    # transitions ('Open - In transit for approval', 'Open - Awaiting pickup', 'Closed - Filled')
    # in the tenant configured via its SECURE_TENANT_ID env variable (folio.tenant.secure-tenant-id),
    # NOT in the event's tenant. This scenario therefore only passes if SECURE_TENANT_ID equals
    # the university tenant name used by this test run (pass -DuniversityTenant=<name>, or
    # -DrandomNumbers=<suffix> if the configured value is 'university<suffix>').
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'MR Send In Transit And Confirm Arrival'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    # Force a full mod-search reindex so the college copy of the instance is indexed regardless
    # of Kafka delivery speed (see the confirm scenario for details).
    * configure headers = headersCentral
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then match [200, 400] contains responseStatus

    # ========== Create mediated request in secure tenant (university) ==========
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

    # ========== Confirm mediated request (retry until mod-search has indexed the instance) ==========
    * configure retry = { count: 40, interval: 15000 }
    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'confirm'
    And retry until responseStatus == 204
    When method POST
    Then status 204

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    * def confirmedRequestId = response.confirmedRequestId
    And match confirmedRequestId == '#notnull'

    # Verify all three requests after confirmation
    * configure headers = headersCollege
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    * call getItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Paged'

    * configure headers = headersCentral
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - Not yet filled'

    * configure headers = headersUniversity
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - Not yet filled'

    # ========== Step 1: Check-in in lending tenant (college) ==========
    # Fulfills the page: the item goes in transit towards the secure tenant.
    * configure headers = headersCollege
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCollegeServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200

    # Secondary request (college) and item are updated synchronously by the check-in
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'
    * call getItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'In transit'

    # Intermediate request (central) is updated asynchronously by mod-tlr via Kafka - retry
    * configure headers = headersCentral
    * configure retry = { count: 20, interval: 15000 }
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - In transit'
    When method GET
    Then status 200
    And match response.status == 'Open - In transit'

    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'In transit'

    # Primary request (university) is updated asynchronously by mod-tlr via Kafka - retry
    * configure headers = headersUniversity
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - In transit'
    When method GET
    Then status 200
    And match response.status == 'Open - In transit'

    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'In transit'

    # Mediated request moves to 'Open - In transit for approval' (async, Kafka) - retry
    Given path 'requests-mediated/mediated-requests', mediatedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - In transit for approval'
    When method GET
    Then status 200
    And match response.status == 'Open - In transit for approval'

    # ========== Step 2: Confirm item arrival in secure tenant (university) ==========
    Given path 'requests-mediated/confirm-item-arrival'
    And request { itemBarcode: '#(inventory.itemBarcode)' }
    When method POST
    Then status 200

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.status == 'Open - Item arrived'

    # Arrival confirmation does not change the circulation requests - all three remain in transit
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'

    * configure headers = headersCentral
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'

    * configure headers = headersCollege
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'

    # ========== Step 3: Send item in transit in secure tenant (university) ==========
    * configure headers = headersUniversity
    Given path 'requests-mediated/send-item-in-transit'
    And request { itemBarcode: '#(inventory.itemBarcode)' }
    When method POST
    Then status 200

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.status == 'Open - In transit to be checked out'

    # Sending in transit does not change the circulation requests - all three remain in transit
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'

    * configure headers = headersCentral
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'

    * configure headers = headersCollege
    * call getRequest { requestId: '#(confirmedRequestId)' }
    And match response.status == 'Open - In transit'

    # ========== Step 4: Check-in in secure tenant (university) at the pickup service point ==========
    # Confirming item arrival reverts the primary request's pickup service point back to the one
    # from the mediated request (mrCentralServicePointId), so checking the item in there puts it
    # on the hold shelf for the secure patron.
    * configure headers = headersUniversity
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCentralServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200

    # Primary request (university) - awaiting pickup
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - Awaiting pickup'
    When method GET
    Then status 200
    And match response.status == 'Open - Awaiting pickup'

    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Awaiting pickup'

    # Mediated request - awaiting pickup (async, Kafka) - retry
    Given path 'requests-mediated/mediated-requests', mediatedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - Awaiting pickup'
    When method GET
    Then status 200
    And match response.status == 'Open - Awaiting pickup'

    # Intermediate request (central) - awaiting pickup (async, Kafka) - retry
    * configure headers = headersCentral
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - Awaiting pickup'
    When method GET
    Then status 200
    And match response.status == 'Open - Awaiting pickup'

    # Secondary request (college) - awaiting pickup, and the real item follows (async, Kafka) - retry
    * configure headers = headersCollege
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Open - Awaiting pickup'
    When method GET
    Then status 200
    And match response.status == 'Open - Awaiting pickup'

    Given path 'item-storage/items', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'Awaiting pickup'
    When method GET
    Then status 200
    And match response.status.name == 'Awaiting pickup'

    # ========== Step 5: Check-out in secure tenant (university) ==========
    # The patron collects the item at the pickup service point. A loan is created
    # in the university tenant; all three confirmed requests and the mediated request
    # transition to 'Closed - Filled' asynchronously via Kafka.
    * configure headers = headersUniversity
    * configure retry = { count: 20, interval: 15000 }
    Given path 'circulation/check-out-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', userBarcode: '#(patron.requesterBarcode)', servicePointId: '#(mrCentralServicePointId)', loanDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 201
    * def loanId = response.id
    And match loanId == '#notnull'
    And match response.itemId == inventory.itemId
    And match response.userId == patron.requesterId

    # Loan is open in university tenant
    Given path 'loan-storage/loans', loanId
    When method GET
    Then status 200
    And match response.status.name == 'Open'
    And match response.action == 'checkedout'

    # Circulation item checked out (university)
    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Checked out'

    # Primary request closed - filled (async, Kafka) - retry
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Closed - Filled'
    When method GET
    Then status 200
    And match response.status == 'Closed - Filled'

    # Mediated request closed - filled (async, Kafka) - retry
    Given path 'requests-mediated/mediated-requests', mediatedRequestId
    And retry until responseStatus == 200 && response.status == 'Closed - Filled'
    When method GET
    Then status 200
    And match response.status == 'Closed - Filled'

    # Intermediate request (central) closed - filled and circulation item checked out (async, Kafka) - retry
    * configure headers = headersCentral
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Closed - Filled'
    When method GET
    Then status 200
    And match response.status == 'Closed - Filled'

    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Checked out'

    # Secondary request (college) closed - filled and real item checked out (async, Kafka) - retry
    * configure headers = headersCollege
    Given path 'request-storage/requests', confirmedRequestId
    And retry until responseStatus == 200 && response.status == 'Closed - Filled'
    When method GET
    Then status 200
    And match response.status == 'Closed - Filled'

    Given path 'item-storage/items', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'Checked out'
    When method GET
    Then status 200
    And match response.status.name == 'Checked out'

    # ========== Step 6: Check-in in central tenant ==========
    # The patron returns the item at the central service point. The central tenant
    # processes the check-in and sends the item back in transit to the lending library.
    * configure headers = headersCentral
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCentralServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200

    # Circulation item in transit (central)
    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'In transit'

    # Loan closed in university tenant (async, Kafka) - retry
    * configure headers = headersUniversity
    Given path 'loan-storage/loans', loanId
    And retry until responseStatus == 200 && response.status.name == 'Closed'
    When method GET
    Then status 200
    And match response.status.name == 'Closed'
    And match response.action == 'checkedin'

    # Circulation item in transit (university)
    * call getCirculationItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'In transit'

    # Real item in transit (college) - async, Kafka - retry
    * configure headers = headersCollege
    Given path 'item-storage/items', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'In transit'
    When method GET
    Then status 200
    And match response.status.name == 'In transit'

    # ========== Step 7: Check-in in lending tenant (college) ==========
    # The item arrives back at its home library and becomes available.
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCollegeServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200

    # Real item available at college library
    Given path 'item-storage/items', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'Available'
    When method GET
    Then status 200
    And match response.status.name == 'Available'

    # Circulation item available (central) - async, Kafka - retry
    * configure headers = headersCentral
    Given path 'circulation-item', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'Available'
    When method GET
    Then status 200
    And match response.status.name == 'Available'

    # Circulation item available (university) - async, Kafka - retry
    * configure headers = headersUniversity
    Given path 'circulation-item', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'Available'
    When method GET
    Then status 200
    And match response.status.name == 'Available'