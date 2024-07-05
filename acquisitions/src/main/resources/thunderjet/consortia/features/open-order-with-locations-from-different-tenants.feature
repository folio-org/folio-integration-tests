Feature: Open order with member tenant location and verify instance, holding, and item creation [MODORDSTOR-402]

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
    * def ongoing = { interval: 123, isSubscription: true, renewalDate: '2022-05-08T00:00:00.000+00:00' }

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
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # Create order lines with member 'universityTenant' tenantId and member 'universityTenant' location id in 'centralTenant'
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


    ## Open order

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


    ## Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def centralPoLineInstanceId = response.instanceId

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.id == centralPoLineInstanceId

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

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
    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.id == centralPoLineInstanceId

    # Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder = physicalItems[0]
    And match physicalItemAfterOpenOrder != null
    And match physicalItemAfterOpenOrder.status.name == 'On order'

  Scenario: Verify existing of Inventory in member tenant after reopining order with deleteHoldings=true

    ## Create order, orderLine with only 'centralTenant' location

    # Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'Ongoing', ongoing: '#(ongoing)'}

    # Create order lines for 'orderLineId', 'fundId', only location 'centralTenant' (central tenant)
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.titleOrPackage = 'test'
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201


    ## Open order

    Given path 'orders/composite-orders', orderId
    When method GET
    And header x-okapi-tenant = centralTenant
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And param deleteHoldings = false
    And header x-okapi-tenant = centralTenant
    And request orderResponse
    When method PUT
    Then status 204


    ## Verify Instance, Holdings and items in 'universityTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'
    * def centralPoLineInstanceId = response.instanceId

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2

    # Check instances 'poLineInstanceId' in 'universityTenant'
    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check holdings with instance 'poLineInstanceId' in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2


    ## Close Order

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


    ## Reopen order with deleteHoldings = true

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == "Closed"

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # Update Order to Open
    Given path 'orders/composite-orders', orderId
    And param deleteHoldings = true
    And request orderResponse
    When method PUT
    Then status 204


    ## Verify item Inventory 'Instnace, Holding, Item' creation in member tenant

    # Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2

    # Check instances in 'universityTenant'
    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

  Scenario: Create 'on-time' order with different tenant location and Verify Instnace, Holding and Item in each tenant

    # Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }


    # Create order lines with member 'universityTenant' tenantId and member 'universityTenant' location id in 'centralTenant'
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

    ## Open order

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


    ## Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId

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
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2


#    ## Change poLine instance connection
#
#    * def requestEntity = { operation: 'Replace Instance Ref', replaceInstanceRef: { holdingsOperation: 'Move', newInstanceId: '#(universityInstanceId)' }}
#
#    Given path 'orders/order-lines', poLineId
#    And header x-okapi-tenant = centralTenant
#    And request requestEntity
#    When method PATCH
#    Then status 204
#
#    # Check the order line
#    Given path 'orders/order-lines', poLineId
#    And header x-okapi-tenant = centralTenant
#    When method GET
#    Then status 200
#    And match $.instanceId == instanceId2
#    And match $.details.productIds[0].productId == '9781566199094'
#    And match $.details.productIds[0].qualifier == 'second-isbn'
#    * def universityPoLineInstanceId = $.instanceId
#
#    ## Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'
#
#    # Get instance and holdingId
#    Given path 'orders/order-lines', poLineId
#    And header x-okapi-tenant = centralTenant
#    When method GET
#    Then status 200
#    * def poLineInstanceId = response.instanceId
#
#    # Check instances in 'centralTenant'
#    Given path 'inventory/instances', universityPoLineInstanceId
#    And header x-okapi-tenant = centralTenant
#    When method GET
#    Then status 200
#
#    # Check holdings with location in 'centralTenat'
#    Given path 'holdings-storage/holdings'
#    And param query = 'instanceId==' + universityPoLineInstanceId
#    And header x-okapi-tenant = centralTenant
#    When method GET
#    Then status 200
#    And match $.totalRecords == 2
#
#    # Check items in 'centralTenant'
#    Given path 'inventory/items'
#    And param query = 'purchaseOrderLineIdentifier==' + poLineId
#    And header x-okapi-tenant = centralTenant
#    When method GET
#    And match $.totalRecords == 2
#
#    # Check instances in 'universityTenant'
#    Given path 'inventory/instances', universityPoLineInstanceId
#    And header x-okapi-tenant = universityTenant
#    When method GET
#    Then status 200
#
#    # Check holdings with location in 'universityTenant'
#    Given path 'holdings-storage/holdings'
#    And param query = 'instanceId==' + universityPoLineInstanceId
#    And header x-okapi-tenant = universityTenant
#    When method GET
#    Then status 200
#    And match $.totalRecords == 1
#
#    # Check items in 'universityTenant'
#    Given path 'inventory/items'
#    And header x-okapi-tenant = universityTenant
#    And param query = 'purchaseOrderLineIdentifier==' + poLineId
#    When method GET
#    And match $.totalRecords == 2


  Scenario: Create 'on-time' order with different tenant location and Verify Instnace, Holding and Item in each tenant
    # Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # Create order lines with member 'universityTenant' tenantId and member 'universityTenant' location id in 'centralTenant'
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
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2


  Scenario: Create PO Line using free-text and open order.
  Verify creation of instance in central tenant and share with other tenant
    # Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

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
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2


  Scenario: Create PO Line using free-text and open order.
  Verify creation of instance in central tenant and share with other tenant

    ## Create Order and orderLine and open

    # Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'Ongoing', ongoing: '#(ongoing)'}

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


    ## Verify Instance, Holdings and items in 'centralTenant' and 'universityTenant'

    # Get instance and holdingId
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId

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
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Closed"


    ## Update Order to close

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    ## Verify item status should have been changed

    # Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2

    # Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

