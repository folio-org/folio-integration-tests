Feature: Open order with many locations from different tenants

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure retry = { count: 5, interval: 1000 }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def centralLocationsId = '6ee65782-ab71-4e07-9561-c400e3004a'
    * def universityLocationsId = '7ee65782-ab71-4e07-9561-c400e3004a'


  @Positive
  Scenario: Prepare data: create fund and budget, and locations
    * def locationsCode = 'LOC'

    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)' }

    # Create 25 locations in central tenant
    * def centralLocations = []
    * def createCentralParameterArray =
      """
      function() {
        for (let i = 10; i < 35; i++) {
          centralLocations.push(
          {
            id: centralLocationsId + i,
            code: locationsCode + i,
            institutionId: centralLocationUnitsInstitutionsId,
            campusId: centralLocationUnitsCampusesId,
            libraryId: centralLocationUnitsLibrariesId,
            servicePointId: centralServicePointsId,

          })
        }
      }
      """
    * eval createCentralParameterArray()

    * def v = call createLocation centralLocations

    # Create 25 locations in university tenant
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }
    * def universityLocations = []
    * def createUniversityParameterArray =
      """
      function() {
        for (let i = 10; i < 35; i++) {
          universityLocations.push(
          {
            id: universityLocationsId + i,
            code: locationsCode + i,
            institutionId: universityLocationUnitsInstitutionsId,
            campusId: universityLocationUnitsCampusesId,
            libraryId: universityLocationUnitsLibrariesId,
            servicePointId: universityServicePointsId,
          })
        }
      }
      """
    * eval createUniversityParameterArray()

    * def v = call createLocation universityLocations

  @Positive
  Scenario: Create Open 'ongoing' order and Verify Instance, Holdings and items in each tenant
    * def orderId = call uuid
    * def poLineId = call uuid

    ## 1.1 Create order
    * def v = call createOrder { id: '#(orderId)'}

    ## 1.2 Create order line
    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId

    * def locations = []

    # Add 25 centralTenant locations to locations
    * def setCentralLocations =
      """
      function() {
        for (let i = 10; i < 35; i++) {
          locations.push(
          {
            tenantId: centralTenant,
            locationId: centralLocationsId + i,
            quantity: 1,
            quantityPhysical: 1
          })
        }
      }
      """
    * eval setCentralLocations()

    # Add 25 universityTenant locations to locations
    * def setUniversityLocations =
      """
      function() {
        for (let i = 10; i < 35; i++) {
          locations.push(
          {
            tenantId: universityTenant,
            locationId: universityLocationsId + i,
            quantity: 1,
            quantityPhysical: 1
          })
        }
      }
      """
    * eval setUniversityLocations()

    # Set all locations to poLine
    * set orderLine.locations = locations
    * set orderLine.cost.quantityPhysical = 50
    Given path 'orders/order-lines'
    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201

    ## 2. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    ## 3. Check locations and searchLocationIds length and Get instanceId from poLine
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.locations.length() == 50
    And match $.searchLocationIds.length() == 50
    * def poLineInstanceId = $.instanceId

    ## 4. Verify Instance, Holdings and items in centralTenant
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

    ## 5. Verify Instance, Holdings and items in universityTenant
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

  @Positive
  Scenario: Open order that contains 10 po lines, each have 5 locations with Affilation for tenant A or tenant B
    * def orderId = call uuid
    * def poLineUuid = '5ee65782-ab71-4e07-9561-c400e3004a'

    ## 1. Create order
    * def v = call createOrder { id: '#(orderId)'}

    ## 2. Create 10 order lines with 5 locations for each line
    * def locations = []
    * def setCentralLocations =
      """
      function() {
        for (let i = 10; i < 15; i++) {
          locations.push(
          {
            tenantId: centralTenant,
            locationId: centralLocationsId + i,
            quantity: 1,
            quantityPhysical: 1
          })
        }
      }
      """
    * eval setCentralLocations()

    * def setUniversityLocations =
      """
      function() {
        for (let i = 10; i < 15; i++) {
          locations.push(
          {
            tenantId: universityTenant,
            locationId: universityLocationsId + i,
            quantity: 1,
            quantityPhysical: 1
          })
        }
      }
      """
    * eval setUniversityLocations()

    * def poLineParameters = []
    * def poLineParametersArray =
      """
      function() {
        for (let i = 10; i < 20; i++) {
          poLineParameters.push({
            id: poLineUuid + i,
            purchaseOrderId: orderId,
            locations: locations,
            quantity: 10
          })
        }
      }
      """
    * eval poLineParametersArray()

    * def v = call createOrderLine poLineParameters

    ## 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    ## 4. Verify all 10 po lines
    * def poLineIds = []
    * def poLineIdsArray =
      """
      function() {
        for (let i = 10; i < 20; i++) {
          poLineIds.push(poLineUuid + i)
        }
      }
      """
    * eval poLineIdsArray()

    Given path 'orders/order-lines'
    And param query = 'id==(' + poLineIds.join(' or ') + ')'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 10
    And match $.poLines[*].locations.length() contains 10
    And match $.poLines[*].searchLocationIds.length() contains 10

    ## 5. Check locations and searchLocationIds length
    Given path 'orders/order-lines', poLineUuid + 10
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.locations.length() == 10
    And match $.searchLocationIds.length() == 10
    * def poLineInstanceId = $.instanceId

    ## 6. Verify Instance, Holdings and items in centralTenant
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 5

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineUuid + 10
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 5

    ## 7. Verify Instance, Holdings and items in universityTenant
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 5

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineUuid + 10
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 5