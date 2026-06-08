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

