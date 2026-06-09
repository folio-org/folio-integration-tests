@parallel=false
Feature: ECS staff slips (pick slips and search slips) via circulation-bff

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    # Fixed UUIDs for inventory entities shared across scenarios
    * callonce read('classpath:vega/ecs-requests/ecs-requests-variables.feature')

    # Run common consortium setup (tenants, inventory, policies, ECS TLR)
    * callonce read('classpath:vega/common/ecs-consortium-setup.feature')

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupInventory = read('classpath:vega/ecs-requests/ecs-inventory-setup.feature')

  Scenario: verify pick slips and search slips via circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Create user group and patron user in central tenant
    * configure headers = headersCentral
    * def groupId = uuid()
    Given path 'groups'
    And request { id: '#(groupId)', group: '#("staff-slip-grp-" + randomMillis())', desc: 'Staff slip test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def userId = uuid()
    * def userBarcode = 'PICK-SLIP-' + randomMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(userId)",
        "username": "#(userBarcode)",
        "barcode": "#(userBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(groupId)",
        "personal": { "lastName": "PickSlipTest", "firstName": "User", "email": "pick-slip@test.com", "preferredContactTypeId": "002", "addresses": [] },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    Given path 'users', userId
    When method GET
    Then status 200
    * def requester = response

    # Create inventory in university tenant and share instance to central
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def inventoryParams = { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(universityLogin.okapitoken)', universityTenant: '#(universityTenant)', instanceTypeId: '#(uniInstanceTypeId)', locationId: '#(uniLocationId)', holdingsSourceId: '#(uniHoldingsSourceId)', materialTypeId: '#(uniMaterialTypeId)', loanTypeId: '#(uniLoanTypeId)', instanceTitle: 'Staff Slip Test Instance' }
    * def inventory = call setupInventory inventoryParams

    # setupInventory already waited for the item to be indexed in university mod-search
    # (intra-tenant Kafka is reliable). Go directly to request creation.
    * def headersCentralEcs = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }

    # ========== Pick slips ==========
    # Create TLR Page request via mod-circulation-bff (item becomes Paged)
    Given path 'circulation-bff/requests'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    And request
      """
      {
        "id": "#(uuid())",
        "requestType": "Page",
        "requestLevel": "Title",
        "requestDate": "#(java.time.Instant.now().toString())",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(inventory.instanceId)",
        "requesterId": "#(userId)",
        "requester": "#(requester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    And match response.requestLevel == 'Title'
    And match response.status == 'Open - Not yet filled'

    # Verify pick slip is returned
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    * configure retry = { count: 10, interval: 5000 }
    Given path 'circulation-bff/pick-slips', ecsServicePointId
    And retry until responseStatus == 200 && response.totalRecords > 0
    When method GET
    Then status 200
    * assert response.totalRecords > 0
    And match response.pickSlips[0].item.title == 'Staff Slip Test Instance'
    And match response.pickSlips[0].requester.lastName == 'PickSlipTest'
    And match response.pickSlips[0].requester.firstName == 'User'
    And match response.pickSlips[0].requester.barcode == userBarcode

    # ========== Search slips ==========
    # Create a second patron user for the Hold request
    * def searchSlipUserId = uuid()
    * def searchSlipUserBarcode = 'SEARCH-SLIP-' + randomMillis()
    * configure headers = headersCentral
    Given path 'users'
    And request
      """
      {
        "id": "#(searchSlipUserId)",
        "username": "#(searchSlipUserBarcode)",
        "barcode": "#(searchSlipUserBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(groupId)",
        "personal": { "lastName": "SearchSlipTest", "firstName": "User", "email": "search-slip@test.com", "preferredContactTypeId": "002", "addresses": [] },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    Given path 'users', searchSlipUserId
    When method GET
    Then status 200
    * def searchSlipRequester = response

    # Create item-level Hold request on the same (now Paged) item
    Given path 'circulation-bff/requests'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    And request
      """
      {
        "id": "#(uuid())",
        "requestType": "Hold",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(inventory.instanceId)",
        "holdingsRecordId": "#(inventory.holdingId)",
        "itemId": "#(inventory.itemId)",
        "item": { "barcode": "#(inventory.itemBarcode)" },
        "requesterId": "#(searchSlipUserId)",
        "requester": "#(searchSlipRequester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    And match response.requestLevel == 'Item'
    And match response.status == 'Open - Not yet filled'

    # Verify search slip is returned
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    * configure retry = { count: 10, interval: 5000 }
    Given path 'circulation-bff/search-slips', ecsServicePointId
    And retry until responseStatus == 200 && response.totalRecords > 0
    When method GET
    Then status 200
    * assert response.totalRecords > 0
    And match response.searchSlips[0].item.title == 'Staff Slip Test Instance'
    And match response.searchSlips[0].requester.lastName == 'SearchSlipTest'
    And match response.searchSlips[0].requester.firstName == 'User'
    And match response.searchSlips[0].requester.barcode == searchSlipUserBarcode
