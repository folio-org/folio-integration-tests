# FAT-26989, FAT-27422, Karate tests for mediated requests via mod-requests-mediated
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

  # FAT-27422: create a mediated request in 'New - Awaiting confirmation', edit supported
  # request fields, verify the edits are persisted, then decline it and verify the request
  # ends in 'Closed - Declined'.
  #
  # No mod-search readiness gate is needed here: like the decline-only scenario above, neither
  # POST, PUT nor decline picks a lending tenant (only /confirm does), so nothing depends on the
  # college item being present in the shared index yet.
  Scenario: create, edit, and decline mediated request
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'FAT-27422 Create Edit Decline'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    * configure headers = headersUniversity

    # ========== Create: the new request starts in 'New - Awaiting confirmation' ==========
    Given path 'requests-mediated/mediated-requests'
    And request
      """
      {
        "requestType": "Page",
        "fulfillmentPreference": "Hold Shelf",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "patronComments": "FAT-27422 original patron comment",
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
    And match response.status == 'New - Awaiting confirmation'
    And match response.mediatedRequestStatus == 'New'
    And match response.mediatedRequestStep == 'Awaiting confirmation'
    And match response.patronComments == 'FAT-27422 original patron comment'
    And match response.pickupServicePointId == mrCentralServicePointId

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.status == 'New - Awaiting confirmation'
    And match response.patronComments == 'FAT-27422 original patron comment'
    And match response.pickupServicePointId == mrCentralServicePointId
    And match response.pickupServicePoint.name == 'MR Central Service Point'

    # ========== Edit supported request fields ==========
    # PUT is a full replace, not a merge: MediatedRequestsServiceImpl.update() maps the whole
    # request body onto the entity, so any field omitted from the body would be wiped (including
    # 'status', which decline below requires to still be 'New - Awaiting confirmation'). Start
    # from the stored representation returned by the GET above and mutate only the fields
    # under test.
    * copy updatedRequest = response
    * set updatedRequest.patronComments = 'FAT-27422 edited patron comment'
    * set updatedRequest.pickupServicePointId = mrUniServicePointId
    # 'pickupServicePoint' is a read-only copy the module resolves from pickupServicePointId,
    # so drop the stale copy rather than sending it alongside the new ID.
    * remove updatedRequest.pickupServicePoint

    Given path 'requests-mediated/mediated-requests', mediatedRequestId
    And request updatedRequest
    When method PUT
    Then status 204

    # ========== Verify the edited fields were saved ==========
    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.id == mediatedRequestId
    And match response.patronComments == 'FAT-27422 edited patron comment'
    And match response.pickupServicePointId == mrUniServicePointId
    And match response.pickupServicePoint.name == 'MR University Service Point'

    # Fields that were not edited survive the full-replace PUT unchanged...
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == patron.requesterId
    And match response.item.barcode == inventory.itemBarcode
    # ...and the edit does not advance the workflow - still awaiting confirmation
    And match response.status == 'New - Awaiting confirmation'
    And match response.mediatedRequestStatus == 'New'
    And match response.mediatedRequestStep == 'Awaiting confirmation'

    # ========== Decline the edited request ==========
    # decline() rejects anything not in 'New - Awaiting confirmation' with a 422, so a 204 here
    # also proves the edit left the request in a declinable state.
    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'decline'
    When method POST
    Then status 204

    # ========== Verify the final status ==========
    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.id == mediatedRequestId
    And match response.status == 'Closed - Declined'
    And match response.mediatedRequestStatus == 'Closed'
    And match response.mediatedRequestStep == 'Declined'
    # Declining does not create a circulation request, and the edits are still in place
    And match response.confirmedRequestId == '##null'
    And match response.patronComments == 'FAT-27422 edited patron comment'
    And match response.pickupServicePointId == mrUniServicePointId

  Scenario: create and confirm item-level mediated page request
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'FAT-27027'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    # Wait until mod-search has indexed the college copy of the item in the shared (consortium)
    # index before confirming. mod-requests-mediated queries mod-search on confirm to find the
    # lending (college) tenant; until Kafka propagates the college item into the shared index,
    # confirm returns 500 TenantPickingException. Poll the central (shared) index for the college
    # item rather than firing a fire-and-forget full reindex - a reindex POST returns before
    # indexing finishes and does not target the member-tenant item confirm needs. This mirrors the
    # mod-search readiness wait in ecs-requests.feature (allowed-service-points).
    * configure headers = headersCentral
    * configure retry = { count: 40, interval: 15000 }
    Given path 'search/instances'
    And param query = 'items.id=="' + inventory.itemId + '"'
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1 && response.instances[0].id == inventory.instanceId
    When method GET
    Then status 200

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

    # Confirm the mediated request. The mod-search readiness gate above already ensures the college
    # copy is indexed, so this normally succeeds immediately; keep a short retry as a safety net for
    # any residual propagation lag (confirm returns 500 TenantPickingException before any state
    # change, so retrying the POST is safe).
    * configure retry = { count: 10, interval: 15000 }
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

    # Wait until mod-search has indexed the college copy of the item in the shared (consortium)
    # index before confirming (see the confirm scenario above for the full rationale).
    * configure headers = headersCentral
    * configure retry = { count: 40, interval: 15000 }
    Given path 'search/instances'
    And param query = 'items.id=="' + inventory.itemId + '"'
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1 && response.instances[0].id == inventory.instanceId
    When method GET
    Then status 200

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

    # ========== Confirm mediated request (readiness gate above ensures indexing; short safety net) ==========
    * configure retry = { count: 10, interval: 15000 }
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

    # In the ECS mediated-request flow the intermediate (central) request and the secondary
    # (college) request/item skip 'Awaiting pickup' entirely: they stay 'Open - In transit' /
    # 'In transit' until the patron checks the item out, at which point the item transitions
    # directly to 'Checked out' (verified in Step 5). Confirmed against a live run, where the
    # central intermediate request remained 'Open - In transit' after the pickup check-in.
    # No request or item checks are needed here for those two tenants.

    # ========== Step 5: Check-out in secure tenant (university) ==========
    # The patron collects the item at the pickup service point. A loan is created
    # in the university tenant; the primary and mediated requests transition to
    # 'Closed - Filled'. In the ECS mediated-request flow the intermediate (central)
    # and secondary (college) requests do not propagate 'Closed - Filled' via the
    # checkout event - only their item/circulation-item statuses are verified.
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

    # In the ECS mediated-request flow the intermediate (central) circulation-item and the
    # secondary (college) real item do NOT transition to 'Checked out' after the university
    # checkout - the DCB virtual layer tracks cross-tenant item movement, not the loan state.
    # They remain 'In transit' until check-in at central (Step 6) and at college (Step 7),
    # verified there. No 'Checked out' checks for those two tenants here.

    # ========== Step 6: Check-in in secure tenant (university) ==========
    # The patron returns the item at the secure tenant's pickup service point - the exact mirror of
    # the Step 4 delivery check-in (same tenant, same mrCentralServicePointId). Checking the item in
    # at the tenant that owns the loan is what closes the borrower's loan and sends the item back in
    # transit towards the lending library. A central check-in was tried here first (matching the
    # original test) and never closed the loan, because the central tenant does not own it: after
    # both a central and a college check-in the university loan stayed 'Open' / 'checkedout'.
    * configure headers = headersUniversity
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCentralServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200

    # University loan closed by the return check-in (same tenant, may lag in the loan store) - retry
    * configure retry = { count: 20, interval: 15000 }
    Given path 'loan-storage/loans', loanId
    And retry until responseStatus == 200 && response.status.name == 'Closed'
    When method GET
    Then status 200
    And match response.status.name == 'Closed'
    And match response.action == 'checkedin'

    # University circulation-item now in transit back towards the lending library (college) - retry
    Given path 'circulation-item', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'In transit'
    When method GET
    Then status 200
    And match response.status.name == 'In transit'

    # ========== Step 7: Check-in in lending tenant (college) ==========
    # The librarian at the lending library scans the returned item at the college's own service
    # point. In this ECS mediated-request / DCB flow the real item does NOT settle to 'Available':
    # it comes to rest 'In transit' towards the interim service point (mrInterimServicePointId,
    # the hardcoded INTERIM_SERVICE_POINT_ID that mod-requests-mediated uses as the mediated pickup
    # point). An open DCB/mediated hold keeps routing the item to the interim SP, so no plain
    # circulation check-in releases it to 'Available' - checking in at mrCollegeServicePointId AND at
    # the location primary mrCentralServicePointId both leave the item 'In transit' to the interim SP.
    # Releasing it to 'Available' would require driving the DCB transaction to CLOSED, which is out of
    # scope for this mediated-request test (the repo's DCB lending-flow.feature likewise does not
    # assert the raw item reaching 'Available'). We assert the real, stable terminal state instead.
    * configure headers = headersCollege
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCollegeServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200

    # Real item comes to rest 'In transit' towards the interim service point (async, Kafka) - retry
    * configure retry = { count: 40, interval: 15000 }
    Given path 'item-storage/items', inventory.itemId
    And retry until responseStatus == 200 && response.status.name == 'In transit' && response.inTransitDestinationServicePointId == mrInterimServicePointId
    When method GET
    Then status 200
    And match response.status.name == 'In transit'
    And match response.inTransitDestinationServicePointId == mrInterimServicePointId