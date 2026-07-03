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
    * def createInventory = read('classpath:vega/mediated-requests/mediated-requests-init-data.feature@CreateInventory')

    # Shared logins reused by every scenario
    * def uniLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def uniOkapitoken = uniLogin.okapitoken
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def centralOkapitoken = centralLogin.okapitoken

    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    # Shared inventory params reused by helpers
    * def baseInventoryParams =
      """
      {
        "centralOkapitoken": "#(centralOkapitoken)",
        "centralTenant": "#(centralTenant)",
        "consortiumId": "#(consortiumId)",
        "uniOkapitoken": "#(uniOkapitoken)",
        "universityTenant": "#(universityTenant)",
        "mrInstanceTypeId": "#(mrInstanceTypeId)",
        "mrUniLocationId": "#(mrUniLocationId)",
        "mrUniHoldingsSourceId": "#(mrUniHoldingsSourceId)",
        "mrMaterialTypeId": "#(mrMaterialTypeId)",
        "mrLoanTypeId": "#(mrLoanTypeId)"
      }
      """

  Scenario: create Item-level Page mediated request and verify it can be retrieved
    * def patron = call createPatronUser { uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)' }
    * def inv = call createInventory { centralOkapitoken: '#(centralOkapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(uniOkapitoken)', universityTenant: '#(universityTenant)', mrInstanceTypeId: '#(mrInstanceTypeId)', mrUniLocationId: '#(mrUniLocationId)', mrUniHoldingsSourceId: '#(mrUniHoldingsSourceId)', mrMaterialTypeId: '#(mrMaterialTypeId)', mrLoanTypeId: '#(mrLoanTypeId)', instanceTitle: 'MR Page Item-level Test Instance' }
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
    And match response.requesterId == patron.requesterId
    And match response.pickupServicePointId == mrCentralServicePointId
