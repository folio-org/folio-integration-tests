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
    # Use central-tenant headers WITHOUT x-okapi-consortium-tenant for the consortia sharing API
    # (x-okapi-consortium-tenant causes routing issues on the subsequent GET polling call)
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Authtoken-Refresh-Cache': 'true' }
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
    * karate.log('Instance sharing POST response - instanceId:', instanceId, 'sharingId:', sharingId, 'status:', response.status, 'error:', response.error)

    # Wait for sharing to complete.
    # Uses a JS retryLogic function to:
    #   1. Log every poll attempt (HTTP status + full response body) for diagnostics
    #   2. Handle 401 token expiry by re-logging in as consortia_admin (central tenant)
    #   3. Return true only when status reaches COMPLETE or ERROR
    * def sharingRetryLogic =
      """
      function() {
        karate.log('Sharing poll - HTTP ' + responseStatus + ' | response: ' + karate.toJson(response));
        if (responseStatus == 401) {
          karate.log('Got 401 - refreshing consortia_admin token for tenant: ' + centralTenant);
          var login = karate.call('classpath:common-consortia/eureka/initData.feature@Login',
            { username: consortiaAdmin.username, password: consortiaAdmin.password, tenant: centralTenant });
          karate.configure('headers', {
            'Content-Type': 'application/json', 'Accept': 'application/json',
            'x-okapi-token': login.okapitoken, 'x-okapi-tenant': centralTenant,
            'Authtoken-Refresh-Cache': 'true'
          });
          return false;
        }
        if (responseStatus == 200 && response.sharingInstances && response.sharingInstances.length > 0) {
          var si = response.sharingInstances[0];
          karate.log('Sharing instance status: ' + si.status + ' | error: ' + si.error);
          return si.status == 'COMPLETE' || si.status == 'ERROR';
        }
        karate.log('Sharing instances not yet available (HTTP ' + responseStatus + ')');
        return false;
      }
      """
    * configure retry = { count: 40, interval: 15000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until sharingRetryLogic()
    When method GET
    Then status 200
    * karate.log('Sharing finished - final status:', response.sharingInstances[0].status, '| error:', response.sharingInstances[0].error)
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

