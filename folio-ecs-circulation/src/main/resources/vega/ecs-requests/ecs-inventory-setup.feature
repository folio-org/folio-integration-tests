@ignore
Feature: Create ECS inventory (instance + holding + item) via central-to-university sharing

  # Parameters:
  #   okapitoken        - central tenant admin token (for instance creation and sharing API)
  #   centralTenant     - central tenant name
  #   consortiumId      - consortium UUID
  #   uniOkapitoken     - university tenant token
  #   universityTenant  - university tenant name
  #   instanceTypeId    - instance type UUID (same UUID used in both tenants)
  #   locationId        - permanent location UUID (university tenant)
  #   holdingsSourceId  - holdings source UUID (university tenant)
  #   materialTypeId    - material type UUID
  #   loanTypeId        - loan type UUID
  #   instanceTitle     - title for the new instance
  #
  # Returns (via karate.set):
  #   instanceId, holdingId, itemId, itemBarcode
  #
  # Strategy: create instance in CENTRAL tenant, then share FROM central TO university.
  # Sharing from central → member is SYNCHRONOUS (returns COMPLETE immediately),
  # which avoids the long async Kafka wait that occurs when sharing from member → central.

  Background:
    * url baseUrl

  Scenario: create instance in central, share to university, create holding and item in university
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * def headersConsortium = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }

    # Create instance in CENTRAL tenant
    * def instanceId = uuid()
    * configure headers = headersCentral
    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(instanceId)",
        "title": "#(instanceTitle)",
        "instanceTypeId": "#(instanceTypeId)",
        "source": "FOLIO",
        "hrid": "#('in' + randomMillis())"
      }
      """
    When method POST
    Then status 201

    # Share FROM CENTRAL TO UNIVERSITY
    # When sourceTenantId = central, mod-consortia returns COMPLETE synchronously — no Kafka wait.
    * def sharingId = uuid()
    * configure headers = headersConsortium
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        "id": "#(sharingId)",
        "instanceIdentifier": "#(instanceId)",
        "sourceTenantId": "#(centralTenant)",
        "targetTenantId": "#(universityTenant)"
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    * def sharingInstanceId = response.id
    * print 'ECS inventory setup: sharing status after POST:', response.status

    # Poll for COMPLETE (fast for central→university; guard against rare IN_PROGRESS edge case)
    * configure retry = { count: 20, interval: 15000 }
    Given path 'consortia', consortiumId, 'sharing/instances', sharingInstanceId
    And retry until responseStatus == 200 && (response.status == 'COMPLETE' || response.status == 'ERROR')
    When method GET
    Then status 200
    * print 'ECS inventory setup: sharing final status:', response.status
    * if (response.status == 'ERROR') karate.fail('Instance sharing central→university failed: ' + karate.toJson(response))
    And match response.status == 'COMPLETE'

    # Verify the shared CONSORTIUM-FOLIO instance is visible in the university tenant
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-FOLIO'

    # Create holding in university tenant (against the CONSORTIUM-FOLIO shadow instance)
    * def holdingId = uuid()
    Given path 'holdings-storage/holdings'
    And request
      """
      {
        "id": "#(holdingId)",
        "instanceId": "#(instanceId)",
        "permanentLocationId": "#(locationId)",
        "sourceId": "#(holdingsSourceId)"
      }
      """
    When method POST
    Then status 201

    # Create item in university tenant
    * def itemId = uuid()
    * def itemBarcode = 'ECS-ITEM-' + randomMillis()
    Given path 'inventory/items'
    And request
      """
      {
        "id": "#(itemId)",
        "holdingsRecordId": "#(holdingId)",
        "barcode": "#(itemBarcode)",
        "status": { "name": "Available" },
        "materialType": { "id": "#(materialTypeId)" },
        "permanentLoanType": { "id": "#(loanTypeId)" },
        "permanentLocation": { "id": "#(locationId)" }
      }
      """
    When method POST
    Then status 201

    # Trigger mod-search full reindex from the CENTRAL tenant.
    # If a previous reindex is still in progress (e.g. from consortium setup), wait for it
    # to finish (400 "already in progress") then retry until a new reindex starts (200).
    # The new reindex will include the holding and item just created in mod-inventory-storage.
    * configure headers = headersCentral
    * configure retry = { count: 20, interval: 30000 }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    And retry until responseStatus == 200
    When method POST
    Then status 200

    # Also trigger an item-specific reindex to ensure item-level data is indexed.
    # This uses a separate endpoint that reindexes items without requiring a full instance reindex.
    Given path 'search/index/inventory/reindex'
    And request { recreateIndex: false, resourceName: 'item' }
    When method POST
    * print 'ECS inventory setup: item reindex response status:', responseStatus
    # 200 = started, 400 = already running; both are acceptable — items will be indexed either way

    # Wait until the item appears in mod-search using a targeted CQL items.id query.
    # This avoids assumptions about the consortium response structure (expandAll varies per tenant).
    * def headersSearchConsortium = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    * configure headers = headersSearchConsortium
    * configure retry = { count: 20, interval: 15000 }
    Given path 'search/instances'
    And param query = 'items.id==' + itemId
    And retry until responseStatus == 200 && response.totalRecords > 0
    When method GET
    Then status 200
    * print 'ECS inventory setup: item indexed in mod-search, found in', response.totalRecords, 'instance(s)'

