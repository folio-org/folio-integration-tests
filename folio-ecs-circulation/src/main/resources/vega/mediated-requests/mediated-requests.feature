# FAT-26989, Create Karate tests for mediated requests - create and verify mediated request persisted to DB
@parallel=false
Feature: Mediated requests - create and retrieve via mod-requests-mediated

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    # Fixed UUIDs for inventory entities shared across scenarios
    * callonce read('classpath:vega/mediated-requests/mediated-requests-variables.feature')

    # Run common consortium setup (central + university + college tenants, inventory, policies)
    * callonce read('classpath:vega/common/mediated-requests-consortium-setup.feature')

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupInventory = read('classpath:vega/ecs-requests/ecs-inventory-setup.feature')

  Scenario: create mediated request in university (secure) tenant and verify it is persisted to DB
    # Login as university user — mediated requests are created in the university (secure) tenant
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def uniOkapitoken = universityLogin.okapitoken
    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    # Login as central admin for consortium-level operations (instance sharing)
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def centralOkapitoken = centralLogin.okapitoken

    # ========== Create patron user in university tenant ==========
    * configure headers = headersUniversity

    * def groupId = uuid()
    Given path 'groups'
    And request { id: '#(groupId)', group: '#("mr-grp-" + randomMillis())', desc: 'Mediated request test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def requesterId = uuid()
    * def requesterBarcode = 'MR-USER-' + randomMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(requesterId)",
        "username": "#(requesterBarcode)",
        "barcode": "#(requesterBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(groupId)",
        "personal": { "lastName": "MRTest", "firstName": "Requester", "email": "mr-test@test.com", "preferredContactTypeId": "002", "addresses": [] },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    # ========== Create inventory: instance in central, share to university, holding + item in university ==========
    * def inventoryParams =
      """
      {
        "okapitoken": "#(centralOkapitoken)",
        "centralTenant": "#(centralTenant)",
        "consortiumId": "#(consortiumId)",
        "uniOkapitoken": "#(uniOkapitoken)",
        "universityTenant": "#(universityTenant)",
        "instanceTypeId": "#(mrInstanceTypeId)",
        "locationId": "#(mrUniLocationId)",
        "holdingsSourceId": "#(mrUniHoldingsSourceId)",
        "materialTypeId": "#(mrMaterialTypeId)",
        "loanTypeId": "#(mrLoanTypeId)",
        "instanceTitle": "MR Test Instance"
      }
      """
    * def inventory = call setupInventory inventoryParams

    # ========== POST mediated request in university tenant ==========
    * def mediatedRequestId = uuid()
    * configure headers = headersUniversity

    Given path 'requests-mediated/mediated-requests'
    And request
      """
      {
        "id": "#(mediatedRequestId)",
        "requestType": "Page",
        "fulfillmentPreference": "Hold Shelf",
        "item": { "barcode": "#(inventory.itemBarcode)" },
        "itemId": "#(inventory.itemId)",
        "requesterId": "#(requesterId)",
        "pickupServicePointId": "#(mrUniServicePointId)",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "instanceId": "#(inventory.instanceId)",
        "holdingsRecordId": "#(inventory.holdingId)"
      }
      """
    When method POST
    Then status 201
    And match response.id == mediatedRequestId
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == requesterId
    And match response.pickupServicePointId == mrUniServicePointId

    # ========== GET mediated request by ID and verify it was persisted to DB ==========
    Given path 'requests-mediated/mediated-requests', mediatedRequestId
    When method GET
    Then status 200
    And match response.id == mediatedRequestId
    And match response.requestType == 'Page'
    And match response.requestLevel == 'Item'
    And match response.fulfillmentPreference == 'Hold Shelf'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.holdingsRecordId == inventory.holdingId
    And match response.requesterId == requesterId
    And match response.pickupServicePointId == mrUniServicePointId
