# For FAT-21333, https://foliotest.testrail.io/index.php?/cases/view/354277
Feature: Change Order Instance Connection

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Change Instance Connection Of POL With Create Inventory Set To None
    * def fundId = call uuid
    * def budgetId = call uuid
    * def dummyInstanceId = call uuid
    * def dummyOrderId = call uuid
    * def dummyPoLineId = call uuid
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)", name: "Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 1000, fundId: "#(fundId)", status: "Active" }

    # 2. Create Dummy Order To Generate Instance With Holdings And Items
    * configure headers = headersUser
    * def v = call createOrder { id: "#(dummyOrderId)" }
    * def v = call createOrderLine { id: "#(dummyPoLineId)", orderId: "#(dummyOrderId)", fundId: "#(fundId)", titleOrPackage: "Dummy Title", createInventory: "Instance, Holding, Item" }
    * def v = call openOrder { orderId: "#(dummyOrderId)" }

    # 3. Get Instance And Holdings From Dummy Order
    Given path 'orders/order-lines', dummyPoLineId
    When method GET
    Then status 200
    * def dummyInstanceId = response.instanceId

    # 4. Create Second Instance For Testing Instance Connection Change
    * configure headers = headersAdmin
    * def v = call createInstance { id: "#(instanceId)", title: "Different Title", instanceTypeId: "#(globalInstanceTypeId)" }

    # 5. Create Order And Order Line With Create Inventory Set To None
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)", orderType: "Ongoing", "ongoing": {"interval": 123, "isSubscription": true, "renewalDate": "2022-05-08T00:00:00.000+00:00"} }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", createInventory: "None" }

    # 5.1. Update Order Line To Connect To Instance
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def orderLineForUpdate = response
    * set orderLineForUpdate.instanceId = instanceId
    * set orderLineForUpdate.titleOrPackage = "Different Title"
    Given path 'orders/order-lines', poLineId
    And request orderLineForUpdate
    When method PUT
    Then status 204

    # 6. Verify Order Line Create Inventory Is Set To None
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId == instanceId && response.physical.createInventory == 'None'
    When method GET
    Then status 200

    # 7. Open Order
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Verify Order Is Open And Contains PO Line
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.poLines != null && response.poLines.length > 0 && response.poLines[0].id == poLineId
    When method GET
    Then status 200

    # 9. Verify PO Line Details And Create Inventory Is None
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId == instanceId && response.titleOrPackage == 'Different Title'
    When method GET
    Then status 200

    # 10. Change Instance Connection - Update Order Line To Connect To Different Instance
    * def updatedOrderLine = response
    * set updatedOrderLine.instanceId = dummyInstanceId
    * set updatedOrderLine.titleOrPackage = "Dummy Title"
    Given path 'orders/order-lines', poLineId
    And request updatedOrderLine
    When method PUT
    Then status 204

    # 11. Verify Instance Connection Has Been Updated Successfully
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId == dummyInstanceId && response.titleOrPackage == "Dummy Title"
    When method GET
    Then status 200
