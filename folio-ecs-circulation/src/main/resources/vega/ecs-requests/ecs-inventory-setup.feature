@ignore
Feature: Create ECS inventory (instance + holding + item) and share instance to central tenant

  # Parameters:
  #   okapitoken        - central tenant admin token (for sharing API)
  #   centralTenant     - central tenant name
  #   consortiumId      - consortium UUID
  #   uniOkapitoken     - university tenant token
  #   universityTenant  - university tenant name
  #   instanceTypeId    - instance type UUID
  #   locationId        - permanent location UUID (university tenant)
  #   holdingsSourceId  - holdings source UUID (university tenant)
  #   materialTypeId    - material type UUID
  #   loanTypeId        - loan type UUID
  #   instanceTitle     - title for the new instance
  #
  # Returns (via karate.set):
  #   instanceId, holdingId, itemId, itemBarcode

  Background:
    * url baseUrl

  Scenario: create instance, share to central, create holding and item in university tenant
    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    # Create instance in university tenant
    * def instanceId = uuid()
    * configure headers = headersUniversity
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

    # Share instance from university to central tenant
    * def sharingId = uuid()
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        "id": "#(sharingId)",
        "instanceIdentifier": "#(instanceId)",
        "sourceTenantId": "#(universityTenant)",
        "targetTenantId": "#(centralTenant)"
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId

    # Wait for sharing to complete
    * configure retry = { count: 20, interval: 30000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
    When method GET
    Then status 200
    And match response.sharingInstances[0].status == 'COMPLETE'

    # Verify instance source updated to CONSORTIUM-FOLIO
    * java.lang.Thread.sleep(5000)
    * configure headers = headersUniversity
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-FOLIO'

    # Create holding in university tenant
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

