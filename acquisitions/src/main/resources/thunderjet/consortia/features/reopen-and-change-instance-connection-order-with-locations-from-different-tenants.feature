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
    * def instanceId1 = callonce uuid3
    * def instanceId2 = callonce uuid4

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

    ## Create new instance
    * table instances
      | id                | title        | instanceTypeId        |
      | instanceId1       | 'instance 1' | centralInstanceTypeId |
      | instanceId2       | 'instance 2' | centralInstanceTypeId |
    * def v = call createInstance instances

  Scenario: Verify existance of Inventory in member tenant after reopining order with deleteHoldings=true

    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'Ongoing', ongoing: '#(ongoing)'}

    # 1.2 Create order lines with member tenant location
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


    ## 2. Open order

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


    ## 3. Check instance in poLine after opening order

    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def centralPoLineInstanceId = $.instanceId


    ## 4. Verify Instance, Holdings and items in 'centralTenant'

    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2


    ## 5. Verify Shadow Instance, Holdings and items in 'universityTenant'

    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2


    ## 6. Close Order

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


    ## 7. Reopen order with deleteHoldings = true

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


    ## 8. Verify Inventory 'Instnace, Holding, Item' existance in 'centralTenant'

    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2


    ## 9. Verify Shadow Inventory 'Instnace, Holding, Item' existance in 'universityTenant' (member tenant)

    Given path 'inventory/instances', centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLineInstanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2

    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2


  Scenario: Change instance connection 'MOVE' for the order to some member tenant, where the shadow instance is located.
  Verify that associated holdings and items moved to the same tenant

    ## 1. Create Order and orderLine

    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # 1.2 Create order lines with location in member and newly created holdingId in central tenant
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'title 1'

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201


    ## 2. Open order

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


    ## 3. Verify Instance, Holding, Item in 'centralTenant'

    # 3.1 Check the order line have an instanceId 'centralInstanceId1'
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def centralPoLinInstanceId1 = $.instanceId

    # 3.2 Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLinInstanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # 3.3 Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLinInstanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def centralPoLineHoldingId1 = response.holdingsRecords[0].id
    * def centralPoLineHoldingId2 = response.holdingsRecords[1].id

    # 3.4 Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def centralPoLineItemId1 = response.items[0].id
    * def centralPoLineItemId2 = response.items[1].id


    ## 4. Verify Shadow Instance, Holding, Item in 'universityTenant'

    # 4.1 Check instances in 'universityTenant'
    Given path 'inventory/instances', centralPoLinInstanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # 4.2 Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLinInstanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def universityPoLineHoldingId1 = response.holdingsRecords[0].id
    * def universityPoLineHoldingId2 = response.holdingsRecords[1].id

    # 4.3 Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2
    * def universityPoLineItemId1 = response.items[0].id
    * def universityPoLineItemId2 = response.items[1].id


    ## 4. Create second orders and order line to create instance in 'centralTenant' and shadow instance in 'universityTenant'

    * def orderId2 = call uuid
    * def poLineId2 = call uuid

    * def v = call createOrder { id: '#(orderId2)', vendor: '#(centralVendorId)', orderType: 'Ongoing', ongoing: '#(ongoing)'}

    # 4.1 Create order lines with second holdingId
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId2
    * set orderLine.purchaseOrderId = orderId2
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.titleOrPackage = 'title 2'
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201


    ## 5. Open order

    Given path 'orders/composite-orders', orderId2
    When method GET
    And header x-okapi-tenant = centralTenant
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId2
    And param deleteHoldings = false
    And header x-okapi-tenant = centralTenant
    And request orderResponse
    When method PUT
    Then status 204


    ## 6 Check the order line have an instanceId 'centralInstanceId1'

    Given path 'orders/order-lines', poLineId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def centralPoLinInstanceId2 = $.instanceId


    ## 7. Verify Instance and shadow Instance in 'centralTenant' and 'universityTenant

    # 7.1 Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLinInstanceId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # 7.2 Check instances in 'universityTenant'
    Given path 'inventory/instances', centralPoLinInstanceId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200


    ## 7. Change 'first' poLine instance 'centralInstanceId1' connection to the 'centralInstanceId2'
    ## that has shadow instance in 'universityTenant

    * def requestEntity = { operation: 'Replace Instance Ref', replaceInstanceRef: { holdingsOperation: 'Move', newInstanceId: '#(centralPoLinInstanceId2)' }}

    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    And request requestEntity
    When method PATCH
    Then status 204

    # 7.2 Check instance moving from 'centralPoLinInstanceId1' to 'centralPoLinInstanceId2'
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == centralPoLinInstanceId2


    ## 8. Verify Instance, Holdings and Items 'centralTenant'
    ## Check both Holdings moved to 'centralPoLineInstanceId2'

    Given path 'inventory/instances', centralPoLinInstanceId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings', centralPoLineHoldingId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == centralPoLinInstanceId2

    Given path 'holdings-storage/holdings', centralPoLineHoldingId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == centralPoLinInstanceId2

    Given path 'inventory/items', centralPoLineItemId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    Given path 'inventory/items', centralPoLineItemId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200


    ## 9. Verify Shadow Instance, Holdings and items moving from 'centralPoLinInstanceId1' to 'centralPoLinInstanceId2'
    ## after changing instance connection in 'universityTenant'

    Given path 'inventory/instances', centralPoLinInstanceId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings', universityPoLineHoldingId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.instanceId == centralPoLinInstanceId2

    Given path 'holdings-storage/holdings', universityPoLineHoldingId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.instanceId == centralPoLinInstanceId2

    Given path 'inventory/items', universityPoLineItemId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'inventory/items', universityPoLineItemId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

  Scenario: Change instance connection 'FIND_OR_CREATE' for the order to some member tenant, where the shadow instance is located.
  Verify that associated holdings and items moved to the same tenant

    ## 1. Create Order and orderLine

    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # 1.2 Create order lines with location in member and newly created holdingId in central tenant
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'title 1'

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201

    ## 2. Open order

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


    ## 3. Verify Instance, Holding, Item in 'centralTenant'

    # 3.1 Check the order line have an instanceId 'centralInstanceId1'
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def centralPoLinInstanceId1 = $.instanceId

    # 3.2 Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLinInstanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # 3.3 Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLinInstanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def centralPoLineHoldingId1 = response.holdingsRecords[0].id
    * def centralPoLineHoldingId2 = response.holdingsRecords[1].id

    # 3.4 Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def centralPoLineItemId1 = response.items[0].id
    * def centralPoLineItemId2 = response.items[1].id


    ## 4. Verify Shadow Instance, Holding, Item in 'universityTenant'

    # 4.1 Check instances in 'universityTenant'
    Given path 'inventory/instances', centralPoLinInstanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # 4.2 Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLinInstanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def universityPoLineHoldingId1 = response.holdingsRecords[0].id
    * def universityPoLineHoldingId2 = response.holdingsRecords[1].id

    # 4.3 Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2
    * def universityPoLineItemId1 = response.items[0].id
    * def universityPoLineItemId2 = response.items[1].id

    ## 5. Change 'first' poLine instance 'centralInstanceId1' connection to the 'instanceId1'
    ## that has shadow instance in 'universityTenant
    * def requestEntity = { operation: 'Replace Instance Ref', replaceInstanceRef: { holdingsOperation: 'Find or Create', newInstanceId: '#(instanceId1)' }}

    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    And request requestEntity
    When method PATCH
    Then status 204

    # 5.2 Check instance moving from 'centralPoLinInstanceId1' to 'instanceId1'
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId1

    ## 6. Verify Instance, Holdings and Items 'centralTenant'
    Given path 'inventory/instances', instanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    ## 6.1 Check both Holdings moved to 'instanceId1'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def newCentralPoLineHoldingId1 = response.holdingsRecords[0].id
    * def newCentralPoLineHoldingId2 = response.holdingsRecords[1].id

    Given path 'holdings-storage/holdings', newCentralPoLineHoldingId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId1

    Given path 'holdings-storage/holdings', newCentralPoLineHoldingId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId1

    ## 6.2 Check both items moved to new holding
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.items[*].holdingsRecordId contains newCentralPoLineHoldingId1
    And match $.items[*].holdingsRecordId contains newCentralPoLineHoldingId2


    ## 7. Verify Shadow Instance, Holdings and items moving from 'centralPoLinInstanceId1' to 'instanceId1'
    ## after changing instance connection in 'universityTenant'

    Given path 'inventory/instances', instanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def newUniversityPoLineHoldingId1 = response.holdingsRecords[0].id
    * def newUniversityPoLineHoldingId2 = response.holdingsRecords[1].id

    Given path 'holdings-storage/holdings', newUniversityPoLineHoldingId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId1

    Given path 'holdings-storage/holdings', newUniversityPoLineHoldingId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId1

    ## 7.2 Check both items moved to new holding
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.items[*].holdingsRecordId contains newUniversityPoLineHoldingId1
    And match $.items[*].holdingsRecordId contains newUniversityPoLineHoldingId2

  Scenario: Change instance connection 'CREATE' for the order to some member tenant, where the shadow instance is located.
  Verify that associated holdings and items moved to the same tenant
    ## 1. Create Order and orderLine

    # 1.1 Create orders
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)', orderType: 'One-Time', ongoing: null }

    # 1.2 Create order lines with location in member and newly created holdingId in central tenant
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.locations[2].tenantId = universityTenant
    * set orderLine.locations[2].locationId = universityLocationsId
    * set orderLine.titleOrPackage = 'title 1'

    And header x-okapi-tenant = centralTenant
    And request orderLine
    When method POST
    Then status 201

    ## 2. Open order

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


    ## 3. Verify Instance, Holding, Item in 'centralTenant'

    # 3.1 Check the order line have an instanceId 'centralInstanceId1'
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def centralPoLinInstanceId1 = $.instanceId

    # 3.2 Check instances in 'centralTenant'
    Given path 'inventory/instances', centralPoLinInstanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # 3.3 Check holdings with location in 'centralTenat'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLinInstanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def centralPoLineHoldingId1 = response.holdingsRecords[0].id
    * def centralPoLineHoldingId2 = response.holdingsRecords[1].id

    # 3.4 Check items in 'centralTenant'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    And match $.totalRecords == 2
    * def centralPoLineItemId1 = response.items[0].id
    * def centralPoLineItemId2 = response.items[1].id


    ## 4. Verify Shadow Instance, Holding, Item in 'universityTenant'

    # 4.1 Check instances in 'universityTenant'
    Given path 'inventory/instances', centralPoLinInstanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # 4.2 Check holdings with location in 'universityTenant'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + centralPoLinInstanceId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def universityPoLineHoldingId1 = response.holdingsRecords[0].id
    * def universityPoLineHoldingId2 = response.holdingsRecords[1].id

    # 4.3 Check items in 'universityTenant'
    Given path 'inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2
    * def universityPoLineItemId1 = response.items[0].id
    * def universityPoLineItemId2 = response.items[1].id

    ## 5. Change 'first' poLine instance 'centralInstanceId1' connection to the 'instanceId2'
    ## that has shadow instance in 'universityTenant
    * def requestEntity = { operation: 'Replace Instance Ref', replaceInstanceRef: { holdingsOperation: 'Create', newInstanceId: '#(instanceId2)' }}

    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    And request requestEntity
    When method PATCH
    Then status 204

    # 5.2 Check instance moving from 'centralPoLinInstanceId1' to 'centralPoLinInstanceId2'
    Given path 'orders/order-lines', poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId2

    ## 6. Verify Instance, Holdings and Items 'centralTenant'
    Given path 'inventory/instances', instanceId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    ## 6.1 Check both Holdings moved to 'centralPoLineInstanceId2'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def newCentralPoLineHoldingId1 = response.holdingsRecords[0].id
    * def newCentralPoLineHoldingId2 = response.holdingsRecords[1].id

    Given path 'holdings-storage/holdings', newCentralPoLineHoldingId1
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId2

    Given path 'holdings-storage/holdings', newCentralPoLineHoldingId2
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId2

    ## 6.2 Check both items moved to new holding
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match $.items[*].holdingsRecordId contains newCentralPoLineHoldingId1
    And match $.items[*].holdingsRecordId contains newCentralPoLineHoldingId2


    ## 7. Verify Shadow Instance, Holdings and items moving from 'centralPoLinInstanceId1' to 'instanceId1'
    ## after changing instance connection in 'universityTenant'

    Given path 'inventory/instances', instanceId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def newUniversityPoLineHoldingId1 = response.holdingsRecords[0].id
    * def newUniversityPoLineHoldingId2 = response.holdingsRecords[1].id

    Given path 'holdings-storage/holdings', newUniversityPoLineHoldingId1
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId2

    Given path 'holdings-storage/holdings', newUniversityPoLineHoldingId2
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.instanceId == instanceId2

    ## 7.2 Check both items moved to new holding
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match $.items[*].holdingsRecordId contains newUniversityPoLineHoldingId1
    And match $.items[*].holdingsRecordId contains newUniversityPoLineHoldingId2