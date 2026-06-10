# For MODGOBI-232, https://foliotest.testrail.io/index.php?/cases/view/852053
Feature: TenantId is not populated by mod-gobi on non-ECS environment

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    # Per AC: Electronic default = "Instance, holdings"
    * def v = call read('classpath:thunderjet/mod-orders/reusable/set-create-inventory.feature') { eresource: 'Instance, Holding', physical: 'Instance, Holding, Item', other: 'None' }

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * callonce variables

    * def po = read('classpath:samples/mod-gobi/po-listed-electronic-monograph.xml')
    * configure retry = { count: 10, interval: 6000 }

  @C852053
  @Positive
  Scenario: GOBI Order Locations Do Not Contain TenantId And Instance Connection Change Creates New Holding On Target Instance
    # 1. Precondition: Create An Instance With One Holding (Simulates "Instance With One Holding" From The Manual Precondition)
    * def precondInstanceId = call uuid
    * def precondHoldingId = call uuid

    Given path 'inventory/instances'
    And headers headersAdmin
    And request { id: '#(precondInstanceId)', title: 'Precondition Instance for MODGOBI-232', instanceTypeId: '#(globalInstanceTypeId)', source: 'FOLIO', identifiers: [] }
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And headers headersAdmin
    And request { id: '#(precondHoldingId)', instanceId: '#(precondInstanceId)', permanentLocationId: '#(globalLocationsId)', sourceId: '#(globalHoldingsSourceId)' }
    When method POST
    Then status 201

    # 2. Submit A GOBI Order That Links To An Existing Location
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-bypass-cache': 'true' }
    And request po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # 3. Verify The Composite Order Was Created
    Given path '/orders/composite-orders'
    And headers headersUser
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    * def orderId = response.purchaseOrders[0].id

    # 4. Verify The PO Line Has A Location With Expected Fields But No TenantId (The MODGOBI-232 Fix)
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headersUser
    When method GET
    Then status 200
    And match $.poLines[0].orderFormat == 'Electronic Resource'
    And match $.poLines[0].cost.quantityElectronic == 1
    And match $.poLines[0].locations[0].holdingId == '#present'
    And match $.poLines[0].locations[0].quantityElectronic == 1
    And match $.poLines[0].locations[0].tenantId == '#notpresent'
    * def poLineId = $.poLines[0].id

    # 5. Change Instance Connection To The Precondition Instance With "Create New" Holdings And Delete Abandoned Holdings
    Given path 'orders/order-lines', poLineId
    And headers headersUser
    And request { operation: 'Replace Instance Ref', replaceInstanceRef: { deleteAbandonedHoldings: true, holdingsOperation: 'Create', newInstanceId: '#(precondInstanceId)' } }
    When method PATCH
    Then status 204

    # 6. Verify The PO Line Now Points To The Precondition Instance And A Fresh Holding Was Created For Its Location
    Given path 'orders/order-lines', poLineId
    And headers headersUser
    And retry until response.instanceId == precondInstanceId && response.locations[0].holdingId != null
    When method GET
    Then status 200
    And match $.locations[0].tenantId == '#notpresent'

    # 7. Verify The Precondition Instance Now Has Two Holdings (Original Plus The One Created For The POL Location)
    Given path 'holdings-storage/holdings'
    And headers headersUser
    And param query = 'instanceId==' + precondInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    And match response.holdingsRecords[*].id contains precondHoldingId

    # 8. Cleanup Order Data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }
