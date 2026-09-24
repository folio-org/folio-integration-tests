# FAT-27423, staff slips for the mediated request workflow (3-tenant ECS + mod-requests-mediated)
#
# SCOPE NOTE - read before extending this file.
# Of the five slips named in FAT-27423, only two can be fetched from an API:
#
#   Pick slip    -> GET circulation-bff/pick-slips/{servicePointId}    (central, via mod-tlr)
#                   GET circulation/pick-slips/{servicePointId}        (data tenant, via mod-circulation)
#   Search slip  -> GET circulation-bff/search-slips/{servicePointId}  (central, via mod-tlr)
#
# Hold, Transit and Request delivery slips have NO render endpoint anywhere in FOLIO. They exist
# only as templates in inventory-storage's staff-slips reference data, and the UI composes the
# printable slip client-side from the check-in response plus the template. This is confirmed by
# mod-circulation's own suite in this repo: the "Transit staff slip" and "Request delivery"
# scenarios in mod-circulation/.../requests-extended.feature read the TEMPLATE from
# staff-slips-storage, drive the item into the relevant state, and then assert item/request data -
# they never GET a rendered slip, because there is nothing to GET.
#
# So this file covers the ticket in the only way the APIs allow:
#   Scenario 1 - Pick slip, fetched and its item/request data verified.
#   Scenario 2 - Search slip, fetched and its title/request data verified.
#   Scenario 3 - Hold / Transit / Request delivery: assert the templates exist in the correct
#                tenants with the tokens the slips are built from. The workflow states at which
#                those three slips are printed ('Open - In transit for approval',
#                'Open - Item arrived', 'Open - Awaiting pickup') are already driven and asserted
#                end-to-end by the "send item in transit and confirm arrival" scenario in
#                mediated-requests.feature, so they are deliberately not re-driven here - that
#                flow takes upwards of ten minutes per run.
@parallel=false
Feature: Mediated requests - staff slips (pick, search, and template-based slips)

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * callonce read('classpath:vega/mediated-requests/mediated-requests-variables.feature')

    # NOTE: mediated-requests-consortium-setup.feature is deliberately NOT called here.
    # It is already run by mediated-requests.feature at @Order(1), which is guaranteed to complete
    # before this feature starts (@Order(2)), and everything this file needs - the MR service
    # points, locations, instance/material/loan types, holdings sources and the interim service
    # point - is created there. Every feature in this suite already depends on class-level ordering
    # (@Order(0) bootstrapConsortium creates the tenants), so this is the same kind of dependency,
    # one step further along.
    #
    # Calling the setup again here would be actively harmful, not merely redundant:
    #   - it fires a full mod-search reindex (search/index/instance-records/reindex/full), and
    #   - it re-runs ecs-circulation-policies.feature, whose circulation-rules PUT is
    #     last-write-wins per tenant.
    # The fixed UUIDs it POSTs also made the second execution fail outright with
    # 422 "id value already exists in table locinstitution" until those POSTs were made idempotent.

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def createPatronUser = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreatePatronUser')
    * def createInventoryInCollege = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreateSharedInstanceWithItemInCollege')
    * def getItem = read('classpath:vega/util/crud-utils.feature@GetItem')
    * def getMediatedRequest = read('classpath:vega/util/crud-utils.feature@GetMediatedRequest')

    * def uniLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def uniOkapitoken = uniLogin.okapitoken
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def centralOkapitoken = centralLogin.okapitoken
    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * def collegeOkapitoken = collegeLogin.okapitoken

    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * def headersCentral    = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralOkapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersCollege    = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeOkapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }

    # circulation-bff slip endpoints are consortium-aware and require the consortium marker header,
    # matching the pattern in vega/staff-slips/features/staff-slips.feature.
    * def headersCentralConsortium = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralOkapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }

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

  # ==================================================================================
  # Scenario 1 - Pick slip
  # ==================================================================================
  # The pick slip tells lending-library staff which item to pull off the shelf, so it is keyed by
  # the service point of the item's EFFECTIVE LOCATION, not by the request's pickup service point.
  # Every location created by mediated-requests-consortium-setup.feature (central, university AND
  # college) uses mrCentralServicePointId as its primaryServicePoint, so the college item's pick
  # slip surfaces at mrCentralServicePointId - which is what the ticket means by "Pick slip from
  # the Central tenant".
  Scenario: pick slip from central tenant for a confirmed item-level Page mediated request
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'FAT-27423 Pick Slip Instance'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    # Confirming a mediated request makes mod-requests-mediated query mod-search to pick the
    # lending tenant, so the college copy must be in the shared index first. Same gate, and same
    # rationale, as the confirm scenario in mediated-requests.feature.
    * configure headers = headersCentral
    * configure retry = { count: 40, interval: 15000 }
    Given path 'search/instances'
    And param query = 'items.id=="' + inventory.itemId + '"'
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1 && response.instances[0].id == inventory.instanceId
    When method GET
    Then status 200

    # ========== Create and confirm the mediated request in the secure tenant ==========
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
    And match response.status == 'New - Awaiting confirmation'

    * configure retry = { count: 10, interval: 15000 }
    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'confirm'
    And retry until responseStatus == 204
    When method POST
    Then status 204

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    * def confirmedRequestId = response.confirmedRequestId
    And match confirmedRequestId == '#notnull'

    # A pick slip is only produced for a Paged item, so assert the precondition explicitly -
    # otherwise an empty slip collection below is ambiguous between "no slip" and "no paged item".
    * configure headers = headersCollege
    * call getItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Paged'

    # ========== The Pick slip template staff will print into ==========
    * configure headers = headersCentral
    Given path 'staff-slips-storage', 'staff-slips'
    When method GET
    Then status 200
    And match response.staffSlips[*].name contains 'Pick slip'

    # ========== Generate the pick slip from the central tenant (mod-tlr) ==========
    # Other scenarios in this suite share the same service point, so filter the collection down to
    # this test's own item rather than trusting index 0.
    * configure headers = headersCentralConsortium
    * configure retry = { count: 12, interval: 10000 }
    Given path 'circulation-bff/pick-slips', mrCentralServicePointId
    And retry until responseStatus == 200 && karate.filter(response.pickSlips, function(s){ return s.item.barcode == inventory.itemBarcode }).length > 0
    When method GET
    Then status 200
    * def pickSlip = karate.filter(response.pickSlips, function(s){ return s.item.barcode == inventory.itemBarcode })[0]

    # ========== Verify the slip carries the expected item and request data ==========
    And match pickSlip.item.title == 'FAT-27423 Pick Slip Instance'
    And match pickSlip.item.barcode == inventory.itemBarcode
    And match pickSlip.item.effectiveLocationSpecific == 'MR College Location'
    And match pickSlip.request.requestType == 'Page'
    And match pickSlip.requester.barcode == patron.requesterBarcode
    And match pickSlip.requester.lastName == 'MRTest'
    And match pickSlip.requester.firstName == 'Requester'

  # ==================================================================================
  # Scenario 2 - Search slip
  # ==================================================================================
  # Search slips list Hold requests that staff must go looking for on the shelves. This uses a
  # title-level Hold, the second request shape the ticket calls out.
  Scenario: search slip from central tenant for a title-level Hold mediated request
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def inventoryParams = baseInventoryParams
    * set inventoryParams.instanceTitle = 'FAT-27423 Search Slip Instance'
    * def inv = call createInventoryInCollege inventoryParams
    * def inventory = inv.inventory

    * configure headers = headersCentral
    * configure retry = { count: 40, interval: 15000 }
    Given path 'search/instances'
    And param query = 'items.id=="' + inventory.itemId + '"'
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1 && response.instances[0].id == inventory.instanceId
    When method GET
    Then status 200

    # ========== Title-level Hold mediated request (no itemId - mod-tlr picks the item) ==========
    * configure headers = headersUniversity
    Given path 'requests-mediated/mediated-requests'
    And request
      """
      {
        "requestType": "Hold",
        "fulfillmentPreference": "Hold Shelf",
        "requestLevel": "Title",
        "requestDate": "#(java.time.Instant.now().toString())",
        "instanceId": "#(inventory.instanceId)",
        "requesterId": "#(patron.requesterId)",
        "pickupServicePointId": "#(mrCentralServicePointId)"
      }
      """
    When method POST
    Then status 201
    * def mediatedRequestId = response.id
    And match mediatedRequestId == '#notnull'
    And match response.requestLevel == 'Title'
    And match response.requestType == 'Hold'
    And match response.status == 'New - Awaiting confirmation'

    * configure retry = { count: 10, interval: 15000 }
    Given path 'requests-mediated/mediated-requests', mediatedRequestId, 'confirm'
    And retry until responseStatus == 204
    When method POST
    Then status 204

    * call getMediatedRequest { mediatedRequestId: '#(mediatedRequestId)' }
    And match response.status == 'Open - Not yet filled'
    And match response.confirmedRequestId == '#notnull'

    # ========== The Search slip template staff will print into ==========
    * configure headers = headersCentral
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Search slip (Hold requests)"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.staffSlips[0].template == '#notnull'

    # ========== Generate the search slip from the central tenant (mod-tlr) ==========
    * configure headers = headersCentralConsortium
    * configure retry = { count: 12, interval: 10000 }
    Given path 'circulation-bff/search-slips', mrCentralServicePointId
    And retry until responseStatus == 200 && karate.filter(response.searchSlips, function(s){ return s.requester.barcode == patron.requesterBarcode }).length > 0
    When method GET
    Then status 200
    * def searchSlip = karate.filter(response.searchSlips, function(s){ return s.requester.barcode == patron.requesterBarcode })[0]

    # ========== Verify the slip carries the expected title and request data ==========
    And match searchSlip.item.title == 'FAT-27423 Search Slip Instance'
    And match searchSlip.request.requestType == 'Hold'
    And match searchSlip.requester.barcode == patron.requesterBarcode
    And match searchSlip.requester.lastName == 'MRTest'
    And match searchSlip.requester.firstName == 'Requester'

  # ==================================================================================
  # Scenario 3 - Hold, Transit and Request delivery slips
  # ==================================================================================
  # These three have no render endpoint (see the scope note at the top of this file), so what is
  # verifiable is that each template exists in the tenant that prints it and carries the tokens
  # the printed slip is built from. The ticket asks for the Request delivery slip "from the Secure
  # tenant" and the Hold/Transit slips from Central, which is how the tenants are split below.
  Scenario: hold, transit and request delivery slip templates exist in the printing tenants
    # ========== Central tenant: Hold and Transit ==========
    * configure headers = headersCentral
    Given path 'staff-slips-storage', 'staff-slips'
    When method GET
    Then status 200
    * def centralSlipNames = response.staffSlips[*].name
    And match centralSlipNames contains 'Hold'
    And match centralSlipNames contains 'Transit'

    * def holdSlip = karate.filter(response.staffSlips, function(s){ return s.name == 'Hold' })[0]
    And match holdSlip.template == '#notnull'
    # The Hold slip identifies the item on the hold shelf and who it is waiting for.
    And match holdSlip.template contains 'item.title'
    And match holdSlip.template contains 'requester'

    * def transitSlip = karate.filter(response.staffSlips, function(s){ return s.name == 'Transit' })[0]
    And match transitSlip.template == '#notnull'
    # The Transit slip routes the item onward, so it names the destination service point.
    And match transitSlip.template contains 'item.toServicePoint'

    # ========== Secure (university) tenant: Request delivery ==========
    * configure headers = headersUniversity
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Request delivery"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def deliverySlip = response.staffSlips[0]
    And match deliverySlip.template == '#notnull'
    And match deliverySlip.template contains 'item.title'
