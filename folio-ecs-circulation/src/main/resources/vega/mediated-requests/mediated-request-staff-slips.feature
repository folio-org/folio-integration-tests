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

    # ========== Verify the slip carries the expected item data ==========
    And match pickSlip.item.title == 'FAT-27423 Pick Slip Instance'
    And match pickSlip.item.barcode == inventory.itemBarcode
    And match pickSlip.item.status == 'Paged'
    And match pickSlip.item.effectiveLocationSpecific == 'MR College Location'
    And match pickSlip.item.effectiveLocationLibrary == 'MR Test Library College'

    # ========== Verify the request data, and the tenant context it reflects ==========
    # The slip's 'request' object carries only requestDate, requestID and servicePointPickup -
    # there is no requestType on it, so the Page nature of the request is asserted on the mediated
    # request itself (above) rather than here.
    And match pickSlip.request.requestID == confirmedRequestId
    And match pickSlip.request.requestDate == '#notnull'

    # The confirmed request's pickup service point is the DCB-prefixed clone of the interim service
    # point, NOT the mediated request's own mrCentralServicePointId: mod-requests-mediated's
    # buildRequest() pins the circulation request to INTERIM_SERVICE_POINT_ID, and mod-tlr clones
    # that service point into the lending tenant with a 'DCB_' name prefix. The pickup point only
    # reverts to the patron's chosen one at confirm-item-arrival.
    And match pickSlip.request.servicePointPickup contains 'MR Interim Service Point'

    # ========== Verify the requester is the SECURE patron, not the real one ==========
    # This is the privacy guarantee of the mediated-request workflow: the lending library must not
    # learn who actually placed the request. mod-requests-mediated substitutes a shadow user, so the
    # slip shows 'Secure Patron' with a 'securepatron_<uuid>' barcode. Asserting the real patron's
    # name here would be asserting a privacy leak.
    And match pickSlip.requester.lastName == 'Patron'
    And match pickSlip.requester.firstName == 'Secure'
    And match pickSlip.requester.barcode contains 'securepatron_'
    And match pickSlip.requester.barcode != patron.requesterBarcode

  # ==================================================================================
  # Scenario 2 - Search slip
  # ==================================================================================
  # Search slips list Hold requests that staff must go looking for on the shelves. This uses a
  # title-level Hold, the second request shape the ticket calls out.
  #
  # ORDER MATTERS: a Hold cannot be placed on an Available item. mod-circulation rejects it, and in
  # the mediated/ECS flow that surfaces from confirm as an opaque
  #   500 RequestCreatingException "Failed to create secondary request for instance <id> in all
  #   potential tenants: [college...]"
  # rather than anything mentioning item status. So the item is first Paged by a separate mediated
  # request, exactly as vega/staff-slips/features/staff-slips.feature does for the non-mediated
  # case ("Create item-level Hold request on the same (now Paged) item").
  Scenario: search slip from central tenant for a title-level Hold mediated request
    * def pagePatron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
    * def holdPatron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', collegeOkapitoken: '#(collegeOkapitoken)', collegeTenant: '#(collegeTenant)', centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)' }
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

    # ========== Step 1: Page the item so it is no longer Available ==========
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
        "requesterId": "#(pagePatron.requesterId)",
        "pickupServicePointId": "#(mrCentralServicePointId)"
      }
      """
    When method POST
    Then status 201
    * def pageRequestId = response.id

    * configure retry = { count: 10, interval: 15000 }
    Given path 'requests-mediated/mediated-requests', pageRequestId, 'confirm'
    And retry until responseStatus == 204
    When method POST
    Then status 204

    * configure headers = headersCollege
    * call getItem { itemId: '#(inventory.itemId)' }
    And match response.status.name == 'Paged'

    # ========== Step 2: Title-level Hold on the now-Paged item ==========
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
        "requesterId": "#(holdPatron.requesterId)",
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
    * def confirmedHoldRequestId = response.confirmedRequestId
    And match confirmedHoldRequestId == '#notnull'

    # ========== The Search slip template staff will print into ==========
    * configure headers = headersCentral
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Search slip (Hold requests)"'
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # ========== Generate the search slip from the central tenant (mod-tlr) ==========
    # Filter on the request ID rather than the requester barcode: the mediated workflow replaces the
    # requester with a shadow 'Secure Patron' whose barcode is generated, so holdPatron's barcode
    # never appears on the slip (see the privacy note in Scenario 1).
    * configure headers = headersCentralConsortium
    * configure retry = { count: 12, interval: 10000 }
    Given path 'circulation-bff/search-slips', mrCentralServicePointId
    And retry until responseStatus == 200 && karate.filter(response.searchSlips, function(s){ return s.request.requestID == confirmedHoldRequestId }).length > 0
    When method GET
    Then status 200
    * def searchSlip = karate.filter(response.searchSlips, function(s){ return s.request.requestID == confirmedHoldRequestId })[0]

    # ========== Verify the slip carries the expected title and request data ==========
    And match searchSlip.item.title == 'FAT-27423 Search Slip Instance'
    And match searchSlip.request.requestID == confirmedHoldRequestId
    And match searchSlip.request.requestDate == '#notnull'
    And match searchSlip.requester.lastName == 'Patron'
    And match searchSlip.requester.firstName == 'Secure'

  # ==================================================================================
  # Scenario 3 - Hold, Transit and Request delivery slips
  # ==================================================================================
  # These three have no render endpoint (see the scope note at the top of this file), so what is
  # verifiable is that each slip is provisioned in the tenant that prints it. The ticket asks for the
  # Request delivery slip "from the Secure tenant" and the Hold/Transit slips from Central, which is
  # how the tenants are split below.
  #
  # Deliberately NOT asserted: template CONTENT. On a freshly provisioned tenant every staff slip
  # ships with an empty body - literally template == '<p></p>' with no {{...}} tokens at all. Tokens
  # only appear once a library authors the template, so asserting on them would be asserting on
  # local configuration rather than on FOLIO behaviour. (mod-circulation's own slip tests in this
  # repo PUT a template containing the token they need before checking it renders, precisely because
  # the default is empty.)
  Scenario: hold, transit and request delivery slips are provisioned in the printing tenants
    # ========== Central tenant: Hold and Transit ==========
    * configure headers = headersCentral
    Given path 'staff-slips-storage', 'staff-slips'
    When method GET
    Then status 200
    # '[*]' is JsonPath, not JavaScript - it is only valid inside a 'match', and blows up with
    # "SyntaxError: Expected an operand but found *" if used in a 'def'.
    And match response.staffSlips[*].name contains 'Hold'
    And match response.staffSlips[*].name contains 'Transit'
    # The mediated workflow ships its own transit slip alongside the generic one.
    And match response.staffSlips[*].name contains 'Transit (mediated requests)'
    And match response.staffSlips[*].name contains 'Pick slip'
    And match response.staffSlips[*].name contains 'Search slip (Hold requests)'

    * def holdSlip = karate.filter(response.staffSlips, function(s){ return s.name == 'Hold' })[0]
    And match holdSlip.id == '#uuid'
    And match holdSlip.template == '#string'

    * def transitSlip = karate.filter(response.staffSlips, function(s){ return s.name == 'Transit' })[0]
    And match transitSlip.id == '#uuid'
    And match transitSlip.template == '#string'

    * def mediatedTransitSlip = karate.filter(response.staffSlips, function(s){ return s.name == 'Transit (mediated requests)' })[0]
    And match mediatedTransitSlip.id == '#uuid'
    And match mediatedTransitSlip.template == '#string'

    # ========== Secure (university) tenant: Request delivery ==========
    * configure headers = headersUniversity
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Request delivery"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.staffSlips[0].id == '#uuid'
    And match response.staffSlips[0].template == '#string'

    # The mediated transit slip must also exist in the secure tenant, since that is where the
    # mediated request's own transit steps (send-item-in-transit / confirm-item-arrival) happen.
    Given path 'staff-slips-storage', 'staff-slips'
    And param query = 'name=="Transit (mediated requests)"'
    When method GET
    Then status 200
    And match response.totalRecords == 1
