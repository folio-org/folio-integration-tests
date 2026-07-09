@ignore
Feature: Create ECS inventory (instance + holding + item) and share instance to university tenant
  # Creates the inventory via the synchronous sharing direction (central -> university).
  # Sharing FROM the central tenant TO a member tenant completes synchronously -
  # the POST to /consortia/.../sharing/instances returns status=COMPLETE immediately,
  # with no Kafka messaging or async wait required.
  #
  # The original direction (university -> central) is asynchronous and depends on a
  # Kafka consumer in the central tenant that is unreliable in test environments.
  #
  # End state (identical for all callers):
  #   - instanceId   : instance in central (source=FOLIO) AND university (source=CONSORTIUM-FOLIO)
  #   - holdingId    : holding in university tenant
  #   - itemId       : item in university tenant
  #   - itemBarcode  : barcode of the university item
  #
  # Parameters:
  #   okapitoken        - central tenant admin token
  #   centralTenant     - central tenant name
  #   consortiumId      - consortium UUID
  #   uniOkapitoken     - university tenant token
  #   universityTenant  - university tenant name
  #   instanceTypeId    - instance type UUID (must exist in both tenants)
  #   locationId        - permanent location UUID (university tenant)
  #   holdingsSourceId  - holdings source UUID (university tenant)
  #   materialTypeId    - material type UUID
  #   loanTypeId        - loan type UUID
  #   instanceTitle     - title for the new instance
  Background:
    * url baseUrl
    
  @CreateItemForSharedInstanceInUniversity
  Scenario: create instance in central, share to university (sync), create holding and item in university
    * def headersCentral    = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Authtoken-Refresh-Cache': 'true' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    # Step 1: Create instance in the CENTRAL tenant
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
    * karate.log('Instance created in central tenant - instanceId:', instanceId, 'title:', instanceTitle)
    # Step 2: Share CENTRAL -> UNIVERSITY (synchronous)
    # This direction completes synchronously: mod-consortia copies the instance directly
    # into the target (member) tenant and returns status=COMPLETE in the same HTTP response.
    # No Kafka consumer involvement, no async wait needed.
    * def sharingId = uuid()
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
    * karate.log('Sharing POST central->university - status:', response.status, 'error:', response.error)
    And match response.status == 'COMPLETE'
    # Step 3: Verify the university copy has source = CONSORTIUM-FOLIO
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-FOLIO'
    # Step 4: Create holding in university tenant
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
    # Step 5: Create item in university tenant
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

  @CreateItemForSharedInstanceInCollege
  Scenario: create instance in central, share to university and college, create holding and item in college
    # Parameters:
    #   okapitoken        - central tenant admin token
    #   centralTenant     - central tenant name
    #   consortiumId      - consortium UUID
    #   uniOkapitoken     - university tenant token
    #   universityTenant  - university tenant name
    #   collegeOkapitoken - college tenant token
    #   collegeTenant     - college tenant name
    #   instanceTypeId    - instance type UUID (must exist in all tenants)
    #   locationId        - permanent location UUID (college tenant)
    #   holdingsSourceId  - holdings source UUID (college tenant)
    #   materialTypeId    - material type UUID
    #   loanTypeId        - loan type UUID
    #   instanceTitle     - title for the new instance
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Authtoken-Refresh-Cache': 'true' }
    * def headersCollege = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeOkapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }
    # Step 1: Create instance in central tenant
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
    # Step 2: Share central -> university (synchronous)
    * def sharingIdUni = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        "id": "#(sharingIdUni)",
        "instanceIdentifier": "#(instanceId)",
        "sourceTenantId": "#(centralTenant)",
        "targetTenantId": "#(universityTenant)"
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.status == 'COMPLETE'
    # Step 3: Share central -> college (synchronous)
    * def sharingIdCol = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        "id": "#(sharingIdCol)",
        "instanceIdentifier": "#(instanceId)",
        "sourceTenantId": "#(centralTenant)",
        "targetTenantId": "#(collegeTenant)"
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.status == 'COMPLETE'
    # Step 4: Verify college copy has source = CONSORTIUM-FOLIO
    * configure headers = headersCollege
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-FOLIO'
    # Step 5: Create holding in college tenant
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
    # Step 6: Create item in college tenant
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