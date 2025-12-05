# For MODORDERS-1378
Feature: Open order with many product IDs

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
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Open order with 400 product IDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1: Create fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

    # 2. Create an Instance with 400 product IDs
    * def instanceIdentifiers = []
    * def poLineProductIds = []
    * def generateIds =
    """
    function() {
      for (let i = 0; i < 400; i++) {
        const id = uuid();
        instanceIdentifiers.push({ value: id, identifierTypeId: globalIdentifierTypeId });
        poLineProductIds.push({ productId: id, productIdType: globalIdentifierTypeId });
      }
    }
    """
    * eval generateIds()
    * def v = call createInstance { id: '#(instanceId)', title: '400 ID Instance', instanceTypeId: '#(globalInstanceTypeId)', identifiers: '#(instanceIdentifiers)' }

    # 2. Create an order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', purchaseOrderId: '#(orderId)', productIds: '#(poLineProductIds)' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }