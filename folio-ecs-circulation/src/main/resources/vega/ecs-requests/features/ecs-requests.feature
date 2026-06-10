# FAT-21604, Create Karate tests for ILR and TLR ECS requests via mod-circulation-bff
@parallel=false
Feature: ECS ILR and TLR requests creation via mod-circulation-bff

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

  Scenario: create ILR ECS request via mod-circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Create user group and patron user in central tenant
    * configure headers = headersCentral
    * def groupId = uuid()
    Given path 'groups'
    And request { id: '#(groupId)', group: '#("ecs-ilr-grp-" + randomMillis())', desc: 'ECS ILR test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def userId = uuid()
    * def userBarcode = 'ECS-ILR-' + randomMillis()
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
        "personal": { "lastName": "ECSTest", "firstName": "ILRUser", "email": "ecs-ilr@test.com", "preferredContactTypeId": "002", "addresses": [] },
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
    * def inventoryParams = { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(universityLogin.okapitoken)', universityTenant: '#(universityTenant)', instanceTypeId: '#(uniInstanceTypeId)', locationId: '#(uniLocationId)', holdingsSourceId: '#(uniHoldingsSourceId)', materialTypeId: '#(uniMaterialTypeId)', loanTypeId: '#(uniLoanTypeId)', instanceTitle: 'ECS ILR Test Instance' }
    * def inventory = call setupInventory inventoryParams

    # Wait until allowed-service-points confirms ecsServicePointId is available for pickup.
    # Uses JSON.stringify to tolerate any response format (object-array or plain-UUID Page values).
    # After 5 polls (75 s) fails with the full response body to expose the actual API output.
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    * karate.set('_ilrSpPoll', 0)
    * def ilrSpCheckFn =
      """
      function() {
        var n = karate.get('_ilrSpPoll') + 1;
        karate.set('_ilrSpPoll', n);
        var respStr = JSON.stringify(response);
        karate.log('ILR SP poll #' + n + ' HTTP=' + responseStatus + ' resp=' + respStr.substring(0, 600));
        if (responseStatus == 200 && respStr.indexOf(ecsServicePointId) >= 0) return true;
        if (n >= 5) {
          karate.fail('ILR: ecsServicePointId (' + ecsServicePointId + ') absent after ' + n + ' polls. HTTP=' + responseStatus + ' response=' + respStr);
        }
        return false;
      }
      """
    * configure retry = { count: 40, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = userId
    And param operation = 'create'
    And param itemId = inventory.itemId
    And retry until ilrSpCheckFn()
    When method GET
    Then status 200

    # Create ILR ECS request via mod-circulation-bff
    Given path 'circulation-bff/requests'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    And request
      """
      {
        "id": "#(uuid())",
        "requestType": "Page",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(inventory.instanceId)",
        "holdingsRecordId": "#(inventory.holdingId)",
        "itemId": "#(inventory.itemId)",
        "item": { "barcode": "#(inventory.itemBarcode)" },
        "requesterId": "#(userId)",
        "requester": "#(requester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    And match response.requestLevel == 'Item'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.requesterId == userId
    And match response.pickupServicePointId == ecsServicePointId
    And match response.status == 'Open - Not yet filled'

  Scenario: create TLR ECS request via mod-circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Create user group and patron user in central tenant
    * configure headers = headersCentral
    * def groupId = uuid()
    Given path 'groups'
    And request { id: '#(groupId)', group: '#("ecs-tlr-grp-" + randomMillis())', desc: 'ECS TLR test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def userId = uuid()
    * def userBarcode = 'ECS-TLR-' + randomMillis()
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
        "personal": { "lastName": "ECSTest", "firstName": "TLRUser", "email": "ecs-tlr@test.com", "preferredContactTypeId": "002", "addresses": [] },
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

    # Create instance in central tenant, share to university (sync), create holding+item in university
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def inventoryParams = { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(universityLogin.okapitoken)', universityTenant: '#(universityTenant)', instanceTypeId: '#(uniInstanceTypeId)', locationId: '#(uniLocationId)', holdingsSourceId: '#(uniHoldingsSourceId)', materialTypeId: '#(uniMaterialTypeId)', loanTypeId: '#(uniLoanTypeId)', instanceTitle: 'ECS TLR Test Instance' }
    * def inventory = call setupInventory inventoryParams

    # Wait until allowed-service-points confirms ecsServicePointId is available for pickup.
    # Uses JSON.stringify to tolerate any response format (object-array or plain-UUID Page values).
    # After 5 polls (75 s) fails with the full response body to expose the actual API output.
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    * karate.set('_tlrSpPoll', 0)
    * def tlrSpCheckFn =
      """
      function() {
        var n = karate.get('_tlrSpPoll') + 1;
        karate.set('_tlrSpPoll', n);
        var respStr = JSON.stringify(response);
        karate.log('TLR SP poll #' + n + ' HTTP=' + responseStatus + ' resp=' + respStr.substring(0, 600));
        if (responseStatus == 200 && respStr.indexOf(ecsServicePointId) >= 0) return true;
        if (n >= 5) {
          karate.fail('TLR: ecsServicePointId (' + ecsServicePointId + ') absent after ' + n + ' polls. HTTP=' + responseStatus + ' response=' + respStr);
        }
        return false;
      }
      """
    * configure retry = { count: 40, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = userId
    And param operation = 'create'
    And param instanceId = inventory.instanceId
    And retry until tlrSpCheckFn()
    When method GET
    Then status 200

    # Create TLR ECS request via mod-circulation-bff
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
    And match response.instanceId == inventory.instanceId
    And match response.requesterId == userId
    And match response.pickupServicePointId == ecsServicePointId
    And match response.status == 'Open - Not yet filled'
