Feature: Open order with member tenant location and verify instance, holding, and item creation [MODORDSTOR-402]

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = call uuid
    * def poLineId = call uuid

  Scenario: Prepare data: create fund and budget
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active' }

    # Verify budgets in 'centralTenant' with fundId
    Given path '/finance/budgets'
    And header x-okapi-tenant = centralTenant
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

  Scenario: Create Open 'ongoing' order and Verify Instance, Holdings and items in each tenant
    # Create orders
    Given path 'orders/composite-orders'
    And header x-okapi-tenant = centralTenant
    And request
      """
      {
        id: '#(orderId)',
        vendor: '#(centralVendorId)',
        orderType: 'Ongoing',
        "ongoing" : {
          "interval" : 123,
          "isSubscription" : true,
          "renewalDate" : "2022-05-08T00:00:00.000+00:00"
        }
      }
      """
    When method POST
    Then status 201

    # Create order lines for <orderLineId> and <fundId> in member tenant
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201


    # Verify there is no instance in memeber tenant that already created in 'centralTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId
    * def poLineHoldingId = response.locations[0].holdingId

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Verify no-instance in 'universityTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # Verify no-holdings with 'poLininstanceId' in 'universityTenant'
    Given path 'holdings-storage/holdings', poLineHoldingId
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # Verify no-items with 'poLineId' in 'universityTenant',
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0


    # Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    And header x-okapi-tenant = centralTenant
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And header x-okapi-tenant = centralTenant
    And request orderResponse
    When method PUT
    Then status 204


    # Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'On order'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'On order'

    # Check instances in 'universityTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'On order'


  Scenario: Create 'on-time' order with different tenant location and Verify Instnace, Holding and Item in each tenant
    # Create orders
    Given path 'orders/composite-orders'
    And header x-okapi-tenant = centralTenant
    And request
      """
      {
        id: '#(orderId)',
        orderType: "One-Time",
        vendor: '#(globalVendorId)'
      }
      """
    When method POST
    Then status 201

    # Create order lines for <orderLineId> and <fundId>
    * print 'university >>> ' + universityTenant

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201

    # Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    And header x-okapi-tenant = centralTenant
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And header x-okapi-tenant = centralTenant
    And request orderResponse
    When method PUT
    Then status 204


    # Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'
    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId
    * def poLineHoldingId = response.locations[0].holdingId

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords != 0

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'On order'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'On order'

    # Check instances in 'universityTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'On order'


  Scenario: Create PO Line using free-text and open order.
  Verify creation of instance in central tenant and share with other tenant
    # Create orders
    Given path 'orders/composite-orders'
    And header x-okapi-tenant = centralTenant
    And request
      """
      {
        id: '#(orderId)',
        vendor: '#(globalVendorId)',
        orderType: 'Ongoing',
        "ongoing" : {
          "interval" : 123,
          "isSubscription" : true,
          "renewalDate" : "2022-05-08T00:00:00.000+00:00"
        }

      }
      """
    When method POST
    Then status 201

    # Create order lines for 'orderLineId', 'fundId', location 'universityTenant' (member tenant) and free-text title
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'test'

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201

    # Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    And header x-okapi-tenant = centralTenant
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And header x-okapi-tenant = centralTenant
    And request orderResponse
    When method PUT
    Then status 204


    # Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId
    * def poLineHoldingId = response.locations[0].holdingId

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords != 1

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'On order'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'On order'

    # Check instances in 'universityTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'On order'


  Scenario: Create PO Line using free-text and open order.
  Verify creation of instance in central tenant and share with other tenant
    # Create orders
    Given path 'orders/composite-orders'
    And header x-okapi-tenant = centralTenant
    And request
      """
      {
        id: '#(orderId)',
        vendor: '#(globalVendorId)',
        orderType: 'Ongoing',
        "ongoing" : {
          "interval" : 123,
          "isSubscription" : true,
          "renewalDate" : "2022-05-08T00:00:00.000+00:00"
        }

      }
      """
    When method POST
    Then status 201

    # Create order lines for 'orderLineId', 'fundId', location 'universityTenant' (member tenant) and free-text title
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'test'

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201

    # Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    And header x-okapi-tenant = centralTenant
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And header x-okapi-tenant = centralTenant
    And request orderResponse
    When method PUT
    Then status 204


    # Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId
    * def poLineHoldingId = response.locations[0].holdingId

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords != 0

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'On order'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'On order'

    # Check instances in 'universityTenant'
    Given path 'inventory/instances', poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'On order'

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Closed"


    # Update Order to close
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # Verify item status should have been changed
    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And match physicalItemAfterOpenOrder1 != null
    And match physicalItemAfterOpenOrder1.status.name == 'Order closed'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And match physicalItemAfterOpenOrder2 != null
    And match physicalItemAfterOpenOrder2.status.name == 'Order closed'

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'Order closed'