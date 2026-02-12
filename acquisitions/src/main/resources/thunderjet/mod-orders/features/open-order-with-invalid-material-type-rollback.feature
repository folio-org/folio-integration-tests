# For MODORDERS-1397
Feature: Open Order With Invalid Material Type Rollback

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleSuffix = call uuid
    * def titleOrPackage = 'Test Order With Invalid Material Type - ' + titleSuffix
    * def invalidMaterialTypeId = call uuid


  @Negative
  Scenario: Verify Inventory Rollback When Opening Order With Invalid Material Type Fails
    * print 'Verify Inventory Rollback When Opening Order With Invalid Material Type Fails'
    * def testStartTime = new Date().getTime()

    # 1. Create Fund And Budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    # 2. Create Order
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    # 3. Create Order Line With Invalid Material Type
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 100
    * set poLine.cost.quantityPhysical = 1
    * set poLine.cost.poLineEstimatedPrice = 100
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.titleOrPackage = titleOrPackage
    * set poLine.orderFormat = 'Physical Resource'
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.physical.materialType = invalidMaterialTypeId
    * set poLine.locations[0].locationId = globalLocationsId
    * set poLine.locations[0].quantityPhysical = 1

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 4. Try To Open Order With Invalid Material Type
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 500
    And match response.errors[0].code contains 'itemCreationFailed'

    # 5. Verify InstanceId Not Set On Order Line
    * configure headers = headersUser
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.instanceId == '#notpresent'

    # 6. Verify No Instances Created After Failed Order Opening
    * configure headers = headersAdmin
    Given path 'inventory/instances'
    And param query = 'title=="' + titleOrPackage + '"'
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 7. Verify No Items Created After Failed Order Opening
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 8. Verify No Pieces Created After Failed Order Opening
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

  @Negative
  Scenario: Verify Matched Instance Is Not Deleted During Rollback When Opening Order With Invalid Material Type Fails
    * print 'Verify Matched Instance Is Not Deleted During Rollback When Opening Order With Invalid Material Type Fails'

    # 1. Create Fund And Budget
    * def fundId2 = call uuid
    * def budgetId2 = call uuid
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId2)', 'ledgerId': '#(globalLedgerId)' }
    * call createBudget { 'id': '#(budgetId2)', 'allocated': 1000, 'fundId': '#(fundId2)', 'status': 'Active' }

    # 2. Create an instance in inventory first (to simulate a matched instance)
    * def instanceId = call uuid
    * def isbn = '978-0-123456-78-9'
    * def instanceSuffix = call uuid
    * def instanceTitle = 'Pre-existing Instance for Matching - ' + instanceSuffix
    * configure headers = headersAdmin
    * def instanceRequest =
    """
    {
      id: '#(instanceId)',
      source: 'FOLIO',
      title: '#(instanceTitle)',
      instanceTypeId: '#(globalInstanceTypeId)',
      statusId: '#(globalInstanceStatusId)',
      identifiers: [
        {
          value: '#(isbn)'
        }
      ]
    }
    """
    * set instanceRequest.identifiers[0].identifierTypeId = globalISBNIdentifierTypeId
    Given path 'inventory/instances'
    And request instanceRequest
    When method POST
    Then status 201

    # 3. Verify instance was created
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.title == instanceTitle

    # 4. Create Order
    * def orderId2 = call uuid
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId2)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    # 5. Create Order Line With Product ID Matching The Existing Instance
    * def poLineId2 = call uuid
    * def invalidMaterialTypeId2 = call uuid
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * set poLine.cost.listUnitPrice = 100
    * set poLine.cost.quantityPhysical = 1
    * set poLine.cost.poLineEstimatedPrice = 100
    * set poLine.fundDistribution[0].fundId = fundId2
    * set poLine.titleOrPackage = instanceTitle
    * set poLine.orderFormat = 'Physical Resource'
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.physical.materialType = invalidMaterialTypeId2
    * set poLine.locations[0].locationId = globalLocationsId
    * set poLine.locations[0].quantityPhysical = 1
    * set poLine.details =
    """
    {
      productIds: [
        {
          productId: '#(isbn)',
          productIdType: '#(globalISBNIdentifierTypeId)'
        }
      ]
    }
    """

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 6. Try To Open Order With Invalid Material Type (should fail and trigger rollback)
    Given path 'orders/composite-orders', orderId2
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId2
    And request orderResponse
    When method PUT
    Then status 500
    And match response.errors[0].code contains 'itemCreationFailed'

    # 7. Verify InstanceId Was Not Set On Order Line (because Inventory operations failed)
    * configure headers = headersUser
    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    And match response.instanceId == '#notpresent'

    # 8. Verify The Matched Instance Still Exists (NOT deleted during rollback)
    * configure headers = headersAdmin
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.title == instanceTitle

    # 9. Verify Instance By Title Search Still Returns The Instance
    Given path 'inventory/instances'
    And param query = 'title=="' + instanceTitle + '"'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.instances[0].id == instanceId

    # 10. Verify No Items Were Created (rollback should have cleaned them up)
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 11. Verify No Pieces Were Created
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId2
    When method GET
    Then status 200
    And match $.totalRecords == 0