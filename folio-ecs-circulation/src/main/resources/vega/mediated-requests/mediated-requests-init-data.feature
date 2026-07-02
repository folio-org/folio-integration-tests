@ignore
Feature: Reusable setup helpers for mediated-requests scenarios

  # Parameters accepted by @CreatePatronUser:
  #   uniOkapitoken  - university tenant token
  #   universityTenant
  # Returns: requesterId, requesterBarcode, groupId

  # Parameters accepted by @CreateInventory:
  #   centralOkapitoken, uniOkapitoken, centralTenant, universityTenant,
  #   consortiumId, mrInstanceTypeId, mrUniLocationId, mrUniHoldingsSourceId,
  #   mrMaterialTypeId, mrLoanTypeId, instanceTitle
  # Returns: inventory (instanceId, holdingId, itemId, itemBarcode)

  Background:
    * url baseUrl

  @CreatePatronUser
  Scenario: create a patron user group and user in the university tenant
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(uniOkapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

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

  @CreateInventory
  Scenario: create instance in central, share to university, create holding and item
    * def setupInventory = read('classpath:vega/ecs-requests/ecs-inventory-setup.feature')
    * def inventory = call setupInventory
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
        "instanceTitle": "#(instanceTitle)"
      }
      """
