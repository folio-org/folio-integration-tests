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


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }

  Scenario: Create instances
    * configure headers = headersAdmin
    * print "Create instances"
    Given path 'inventory/instances'
    And request
    """
    {
      "id": "#(instanceId1)",
      "source": "FOLIO",
      "title": "Interesting Times",
      "instanceTypeId": "#(globalInstanceTypeId)",
      "identifiers": [
        {
          "value": "#(isbn1)",
          "identifierTypeId": "#(globalISBNIdentifierTypeId)"
        }
      ]
    }
    """
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request
    """
    {
      "id": "#(instanceId2)",
      "source": "FOLIO",
      "title": "The New-York Times",
      "instanceTypeId": "#(globalInstanceTypeId)",
      "identifiers": [
        {
          "value": "#(isbn2)",
          "identifierTypeId": "#(globalISBNIdentifierTypeId)"
        }
      ]
    }
    """
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request
    """
    {
      "id": "#(instanceId3)",
      "source": "FOLIO",
      "title": "New instance",
      "instanceTypeId": "#(globalInstanceTypeId)",
      "identifiers": [
        {
          "value": "#(isbn3)",
          "identifierTypeId": "#(globalISBNIdentifierTypeId)"
        }
      ]
    }
    """
    When method POST
    Then status 201

  Scenario: Create an order
    * print "Create an order"
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

  Scenario: Create an order line
    * print "Create an order line"

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.instanceId = instanceId1
    * set poLine.details.productIds = [ { productId: "#(isbn1ProductId)", productIdType: "#(globalISBNIdentifierTypeId)" } ]

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  Scenario: Open the order
    * print "Open the order"

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check the order line instanceId
    * print "Check the order line instanceId"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId1
    And match $.details.productIds[0].productId == '1-56619-909-3'
    And match $.details.productIds[0].qualifier == '#notpresent'

  Scenario: change poLine instance connection
    * print "change poLine instance connection"
    * def requestEntity =   { 'operation': 'Replace Instance Ref', 'replaceInstanceRef': { 'holdingsOperation': 'Find or Create', 'newInstanceId': #(instanceId2) }}

    Given path 'orders/order-lines', poLineId
    And request requestEntity
    When method PATCH
    Then status 204

  Scenario: Check the order line instanceId after update
    * print "Check the order line"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId2
    And match $.details.productIds[0].productId == '1-56619-909-3 second-isbn'
    And match $.details.productIds[0].qualifier == '#notpresent'

  Scenario: change (move) poLine instance connection
    * print "change poLine instance connection (move)"
    * def requestEntity =   { 'operation': 'Replace Instance Ref', 'replaceInstanceRef': { 'holdingsOperation': 'Move', 'newInstanceId': #(instanceId3) }}

    Given path 'orders/order-lines', poLineId
    And request requestEntity
    When method PATCH
    Then status 204

  Scenario: Check the order line instanceId after update
    * print "Check the order line"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId3
    And match $.details.productIds[0].productId == '1-56619-909-3 third-isbn'
    And match $.details.productIds[0].qualifier == '#notpresent'