Feature: Modify inventory data

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def samplesPath = 'classpath:firebird/mod-audit/samples/'
    * def util = call read('classpath:common/util/uuid1.feature')
    * def defaultPermanentLocationId = '81209c20-0d52-44c8-b8d6-59d7b3a16b37'

  @CreateInstance
  Scenario: Create Instance
    Given path 'inventory/instances'
    And request read(samplesPath + 'instance.json')
    When method POST
    Then status 201
    And def location = responseHeaders['Location'][0]
    And def id = location.substring(location.lastIndexOf('/') + 1)

  @UpdateInstance
  Scenario: Update instance
    Given path 'inventory/instances/' + instanceId
    And request instance
    When method PUT
    Then status 204

  @GetInstance
  Scenario: Get instance
    Given path 'inventory/instances/' + instanceId
    When method GET
    Then status 200

  @CreateHoldings
  Scenario: Create Holdings
    Given path 'holdings-storage/holdings'
    ### Get value or set default
    And def permanentLocationId = karate.get('permanentLocationId', defaultPermanentLocationId)
    And request read(samplesPath + 'holdings.json')
    When method POST
    Then status 201
    And def id = response.id

  @UpdateHolding
  Scenario: Update holding
    Given path 'inventory/holdings/' + holdingId
    And request holding
    When method PUT
    Then status 204

  @GetHolding
  Scenario: Get holding
    Given path 'holdings-storage/holdings/' + holdingId
    When method GET
    Then status 200

  @DeleteHolding
  Scenario: Delete holding
    Given path 'holdings-storage/holdings/' + holdingId
    When method DELETE
    Then status 204

  @CreateItems
  Scenario: Create Items
    Given path 'inventory/items'
    ### Get value or set default
    And def permanentLocationId = karate.get('permanentLocationId', defaultPermanentLocationId)
    And def barcode = karate.get('barcode', util.uuid1())
    And request read(samplesPath + 'items.json')
    When method POST
    Then status 201
    And def id = response.id

  @UpdateItem
  Scenario: Update Item
    Given path 'inventory/items/' + itemId
    And request item
    When method PUT
    Then status 204

  @GetItem
  Scenario: Get item
    Given path 'inventory/items/' + itemId
    When method GET
    Then status 200

  @DeleteItem
  Scenario: Delete item
    Given path 'inventory/items/' + itemId
    When method DELETE
    Then status 204

  @GetInstanceAuditData
  Scenario: Get audit data for instance
    Given path 'audit-data/inventory/instance/' + instanceId
    When method GET
    Then status 200

  @GetHoldingAuditData
  Scenario: Get audit data for holding
    Given path 'audit-data/inventory/holdings/' + holdingId
    When method GET
    Then status 200

  @GetItemAuditData
  Scenario: Get audit data for iten
    Given path 'audit-data/inventory/item/' + itemId
    When method GET
    Then status 200

  @GetPageSizeAuditData
  Scenario: Get page size audit data
    Given path 'audit/config/groups/audit.inventory/settings'
    When method GET
    Then status 200

  @PutPageSizeAuditData
  Scenario: Get page size audit data
    Given path 'audit/config/groups/audit.inventory/settings/records.page.size'
    And request setting
    When method PUT
    Then status 204

  @PostHoldingsSource
  Scenario: create holdings sources
    Given path 'holdings-sources'
    And request holdingsSource
    When method POST