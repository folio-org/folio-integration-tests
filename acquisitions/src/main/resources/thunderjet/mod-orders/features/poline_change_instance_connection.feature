@parallel=false
# for https://issues.folio.org/browse/MODORDERS-890
Feature: PoLine change instance connection

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def instanceId1 = callonce uuid3
    * def instanceId2 = callonce uuid4
    * def instanceId3 = callonce uuid5
    * def orderId = callonce uuid6
    * def poLineId = callonce uuid7

    * def isbn1 = "1-56619-909-3 first-isbn"
    * def isbn1ProductId = "1-56619-909-3"
    * def isbn2 = "1-56619-909-3 second-isbn"
    * def isbn3 = "1-56619-909-3 third-isbn"


  Scenario: Change instance connection with "Find or Create" and "Move" holdings operations
    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }

    # 2. Create instances
    * table instancesData
      | id          | title                | instanceTypeId       | identifiers                                                                  |
      | instanceId1 | "Interesting Times"  | globalInstanceTypeId | [{"value": "#(isbn1)", "identifierTypeId": "#(globalISBNIdentifierTypeId)"}] |
      | instanceId2 | "The New-York Times" | globalInstanceTypeId | [{"value": "#(isbn2)", "identifierTypeId": "#(globalISBNIdentifierTypeId)"}] |
      | instanceId3 | "New instance"       | globalInstanceTypeId | [{"value": "#(isbn3)", "identifierTypeId": "#(globalISBNIdentifierTypeId)"}] |
    * def v = call createInstance instancesData

    # 3. Create order, order line and open the order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLineWithInstance { id: '#(poLineId)', purchaseOrderId: '#(orderId)', instanceId: '#(instanceId1)', productIds: [{ productId: "#(isbn1ProductId)", productIdType: "#(globalISBNIdentifierTypeId)"}] }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Check the order line instanceId
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId1
    And match $.details.productIds[0].productId == '1-56619-909-3'
    And match $.details.productIds[0].qualifier == '#notpresent'

   # 5. Change poLine instance connection
    * def requestEntity = { 'operation': 'Replace Instance Ref', 'replaceInstanceRef': { 'holdingsOperation': 'Find or Create', 'newInstanceId': #(instanceId2) } }
    Given path 'orders/order-lines', poLineId
    And request requestEntity
    When method PATCH
    Then status 204

   # 6. Check the order line instanceId after update
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId2
    And match $.details.productIds[0].productId == '1-56619-909-3 second-isbn'
    And match $.details.productIds[0].qualifier == '#notpresent'

   # 7. Change (move) poLine instance connection
    * def requestEntity = { 'operation': 'Replace Instance Ref', 'replaceInstanceRef': { 'holdingsOperation': 'Move', 'newInstanceId': #(instanceId3) } }
    Given path 'orders/order-lines', poLineId
    And request requestEntity
    When method PATCH
    Then status 204

   # 8. Check the order line instanceId after update
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId3
    And match $.details.productIds[0].productId == '1-56619-909-3 third-isbn'
    And match $.details.productIds[0].qualifier == '#notpresent'