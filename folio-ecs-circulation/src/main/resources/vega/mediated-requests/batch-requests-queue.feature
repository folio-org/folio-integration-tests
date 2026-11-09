# FAT-29135 / CIRC-2697 (formerly MCBFF-202)
@parallel=false
Feature: Batch requests keep unique queue positions after one request is fulfilled

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin
    * callonce read('classpath:vega/mediated-requests/mediated-requests-variables.feature')
    * callonce read('classpath:vega/common/mediated-requests-consortium-setup.feature')

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def createPatronUser = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreatePatronUser')
    * def createInventory = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreateSharedInstanceWithItemInCollege')
    * def createItem = read('classpath:vega/mediated-requests/batch-requests-helpers.feature@CreateItem')
    * def createBatch = read('classpath:vega/mediated-requests/batch-requests-helpers.feature@CreateBatch')
    * def verifyQueue = read('classpath:vega/mediated-requests/batch-requests-helpers.feature@VerifyQueue')

    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def centralOkapitoken = centralLogin.okapitoken
    * def uniLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def uniOkapitoken = uniLogin.okapitoken
    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * def collegeOkapitoken = collegeLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralOkapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersCollege = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeOkapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }

  Scenario: two batches for the same three items have no duplicate queue positions before or after checkout
    # Each patron's group is present in all three tenants, and the patrons live in central.
    * def patronParams = { patronTenant: '#(centralTenant)', patronOkapitoken: '#(centralOkapitoken)' }
    * def firstPatron = call createPatronUser patronParams
    * def secondPatron = call createPatronUser patronParams

    * def inv = call createInventory { instanceTitle: 'FAT-29135 Batch Request Queue' }
    * def inventory = inv.inventory
    * def secondItemId = uuid()
    * def thirdItemId = uuid()
    * table additionalItems
      | itemId       |
      | secondItemId |
      | thirdItemId  |
    * call createItem additionalItems

    # Wait for every member item to reach the shared search index used by batch processing.
    * configure headers = headersCentral
    * configure retry = { count: 40, interval: 15000 }
    Given path 'search/instances'
    And param query = 'id=="' + inventory.instanceId + '"'
    And param expandAll = true
    And retry until responseStatus == 200 && response.totalRecords == 1 && karate.jsonPath(response, '$.instances[0].items[*].id').indexOf(inventory.itemId) != -1 && karate.jsonPath(response, '$.instances[0].items[*].id').indexOf(secondItemId) != -1 && karate.jsonPath(response, '$.instances[0].items[*].id').indexOf(thirdItemId) != -1
    When method GET
    Then status 200

    # Use two pickup points, as in the original reproduction. Both are provisioned in central.
    * def secondPickupServicePointId = uuid()
    Given path 'service-points'
    And request { id: '#(secondPickupServicePointId)', name: 'FAT-29135 Second Pickup', code: 'FAT-29135-PICKUP', discoveryDisplayName: 'FAT-29135 Second Pickup', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    * table itemRequests
      | itemId           | pickupServicePointId       |
      | inventory.itemId | mrCentralServicePointId    |
      | secondItemId     | secondPickupServicePointId |
      | thirdItemId      | mrCentralServicePointId    |
    * def firstBatch = call createBatch { requesterId: '#(firstPatron.requesterId)' }
    * def secondBatch = call createBatch { requesterId: '#(secondPatron.requesterId)' }
    * def firstRequestIds = firstBatch.requestIds
    * def secondRequestIds = secondBatch.requestIds
    * table queueTenants
      | tenantHeaders  |
      | headersCentral |
      | headersCollege |

    # TLR is enabled: all six item requests share the instance queue (first batch 1-3, second 4-6).
    * call verifyQueue queueTenants
    * def filledRequestId = karate.filter(firstBatch.details, function(d) { return d.itemId == inventory.itemId })[0].confirmedRequestId

    # Send the first item from the member tenant to the central pickup point.
    * configure headers = headersCollege
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCollegeServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200
    Given path 'request-storage/requests', filledRequestId
    And retry until responseStatus == 200 && response.status == 'Open - In transit'
    When method GET
    Then status 200

    * configure headers = headersCentral
    Given path 'request-storage/requests', filledRequestId
    And retry until responseStatus == 200 && response.status == 'Open - In transit'
    When method GET
    Then status 200
    Given path 'circulation/check-in-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', servicePointId: '#(mrCentralServicePointId)', checkInDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 200
    Given path 'request-storage/requests', filledRequestId
    And retry until responseStatus == 200 && response.status == 'Open - Awaiting pickup'
    When method GET
    Then status 200

    Given path 'circulation/check-out-by-barcode'
    And request { itemBarcode: '#(inventory.itemBarcode)', userBarcode: '#(firstPatron.requesterBarcode)', servicePointId: '#(mrCentralServicePointId)', loanDate: '#(java.time.Instant.now().toString())' }
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.itemId == inventory.itemId
    And match response.userId == firstPatron.requesterId

    Given path 'request-storage/requests', filledRequestId
    And retry until responseStatus == 200 && response.status == 'Closed - Filled'
    When method GET
    Then status 200

    # Five requests remain: the first patron's Pages occupy 1-2, the second batch occupies 3-5.
    * def firstRequestIds = karate.filter(firstRequestIds, function(id) { return id != filledRequestId })
    * call verifyQueue queueTenants
