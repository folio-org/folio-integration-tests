@parallel=false
Feature: Open order with member tenant location and verify instance, holding, and item creation [MODORDSTOR-402]

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * configure headers = headersCentral

    * configure retry = { interval: 10000, count: 5 }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleId = call uuid
    * def ongoing = { interval: 123, isSubscription: true, renewalDate: '2022-05-08T00:00:00.000+00:00' }

  @Positive
  Scenario: Prepare data: create fund and budget
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active' }

    # Verify budgets in 'centralTenant' with fundId
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

  @Positive
  Scenario: Create Open 'ongoing' order and Verify Instance, Holdings and items in each tenant
    # 1.1 Create order
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # 1.2 Create order lines with member 'universityTenant' tenantId and member 'universityTenant' location id in 'centralTenant'
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId

    And request orderLine
    When method POST
    Then status 201

    # 2. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 3. Get instance in poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def centralPoLineInstanceId = $.instanceId

    # 4. Verify Instance, Holdings and items in 'centralTenant'
    # 4.1 Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLineInstanceId
    When method GET
    Then status 200
    And match $.id == centralPoLineInstanceId

    # 4.2 Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # 4.2 Check items details in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'On order'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'On order'

    # 5. Verify Shadow Instance, Holdings and Items in 'universityTenant'
    # 5.1 Check instances in 'universityTenant'
    * configure headers = headersUni
    Given path 'inventory/instances', centralPoLineInstanceId
    When method GET
    Then status 200
    And match $.id == centralPoLineInstanceId

    # 5.2 Check holdings in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And retry until $.totalRecords == 2
    When method GET
    Then status 200

    # 5.3 Check items details in 'universityTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And retry until response.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'On order'

  @Positive
  Scenario: Create PO Line using free-text and open order. Verify creation of instance in central tenant and share with other tenant
    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # 1.2 Create order lines for 'orderLineId', 'fundId', location 'universityTenant' (member tenant) and free-text title
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'test'

    And request orderLine
    When method POST
    Then status 201

    # 2. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 3. Get instance from poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def poLineInstanceId = $.instanceId

    # 4. Verify Instance, Holdings and Items in 'centralTenant'
    # 4.1 Check instances in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    # 4.2 Check holdings in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    # 4.3 Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

    # 5. Verify Shadow Instance, Holdings and Items in 'universityTenant'
    # 5.1 Check instances in 'universityTenant'
    * configure headers = headersUni
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    # 5.2 Check holdings in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    # 5.3 Check items in 'universityTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

  @Positive
  Scenario: Create 'on-time' order with different tenant location and Verify Instnace, Holding and Item in each tenant
    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # 1.2 Create order lines with member 'universityTenant' tenantId and member 'universityTenant' location id in 'centralTenant'
    Given path 'orders/order-lines'
    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId
    And request orderLine
    When method POST
    Then status 201

    # 2. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 3. Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def poLineInstanceId = $.instanceId

    # 4. Verify Instance, Holdings and Items in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

    # 5. Verify Shadow Instance, Holdings and Items in 'universityTenant'
    * configure headers = headersUni
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

  @Positive
  Scenario: Open order with 'centralTenant' and 'universityTenant' locations. Verify items status changed from 'On order to 'Order closed in both 'centralTenant' and 'universityTenant'
    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'Ongoing', ongoing: '#(ongoing)'}

    # 1.2 Create order lines for 'orderLineId', 'fundId', location 'universityTenant' (member tenant) and free-text title
    Given path 'orders/order-lines'
    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'test'
    And request orderLine
    When method POST
    Then status 201

    # 2. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 3. Check instanceId in poLine after opening order
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def poLineInstanceId = $.instanceId

    # 4. Verify Instance, Holdings and Items in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords != 0
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

    # 5. Verify Shadow Instance, Holdings and Items in 'universityTenant'
    * configure headers = headersUni

    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

    # 6. Update Order to close
    * configure headers = headersCentral
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Closed"
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 7. Check item status have changed to 'Order closed' in both 'centralTenant' and 'universityTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'Order closed'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'Order closed'

    * configure headers = headersUni
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'Order closed'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'Order closed'

  @Positive
  Scenario: Do unopen the order, check appropriate state of Inventory objects
    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'Ongoing', ongoing: '#(ongoing)'}

    # 1.2 Create order lines for 'orderLineId', 'fundId', location 'universityTenant' (member tenant) and free-text title
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'test'

    And request orderLine
    When method POST
    Then status 201

    # 2. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 3. Check instanceId in poLine after opening order
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def poLineInstanceId = $.instanceId

    # 4. Verify Instance, Holdings and Items in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords != 0
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

    # 5. Verify Shadow Instance, Holdings and Items in 'universityTenant'
    * configure headers = headersUni
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET

    ## 6. Unopen order
    * configure headers = headersCentral
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Pending"
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 7. Check Instance, Holdings and No Items in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords != 0
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 0
    When method GET

    # 8. Verify Shadow Instance, Holdings and No Items in 'universityTenant'
    * configure headers = headersUni
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 0
    When method GET

    # 9. 'Open' the order to 'Unopen' with deleteHolding=true
    * configure headers = headersCentral
    # 9.1. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 9.2 Unopen order
    * set orderResponse.workflowStatus = "Pending"
    Given path 'orders/composite-orders', orderId
    And param deleteHoldings = true
    And request orderResponse
    When method PUT
    Then status 204

    # 10. Verify Instance, No Holdings and No Items in both tenents
    # 10.1 Check 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 0
    When method GET

    # 10.2. Check 'universityTenant'
    * configure headers = headersUni
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 0
    When method GET
