Feature: Open order with many locations from different tenants

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure retry = { count: 5, interval: 1000 }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleId = call uuid

    * def centralLocationsId = '7ee65782-ab71-4e07-9561-c400e3004a'
    * def universityLocationsId = '6ee65782-ab71-4e07-9561-c400e3004a'
    * def locationsCode = 'LOC'

  Scenario: Prepare data: create fund and budget, and locations
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)' }

    ## Create 25 locations in central tenant
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

    ## Create 25 locations in university tenant
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

  Scenario: Create Open 'ongoing' order and Verify Instance, Holdings and items in each tenant

    ## 1.1 Create order
    * def v = call createOrder { id: '#(orderId)'}

    ## 1.2 Create order line
    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId

    * def locations = []

    # Add 25 centralTenant locations to locations
    * def centralTenantId = centralTenant
    * def centralLocationId = centralLocationsId
    * def setCentralLocations =
      """
      function() {
        for (let i = 10; i < 35; i++) {
          locations.push(
          {
            tenantId: centralTenantId,
            locationId: centralLocationId + i,
            quantity: 1,
            quantityPhysical: 1
          })
        }
      }
      """
    * eval setCentralLocations()

    # Add 25 universityTenant locations to locations
    * def universityTenantId = universityTenant
    * def universityLocationId = universityLocationsId
    * def setUniversityLocations =
      """
      function() {
        for (let i = 10; i < 35; i++) {
          locations.push(
          {
            tenantId: universityTenantId,
            locationId: universityLocationId + i,
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

    ## 3. Get instanceId from poLine
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.locations.length == 50
    And match response.searchLocationIds.length == 50
    * def poLineInstanceId = $.instanceId


    # 4. Verify Instance, Holdings and items in centralTenant
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'inventory/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

    Given path 'inventory/items'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

    # 5. Verify Instance, Holdings and items in universityTenant
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'inventory/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25

    Given path 'inventory/items'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 25