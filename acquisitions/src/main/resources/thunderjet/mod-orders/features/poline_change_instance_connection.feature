@parallel=false
# for https://issues.folio.org/browse/MODORDERS-890
Feature: poline_change_instance_connection

  Background:
    * url baseUrl
#    * callonce dev {tenant: 'testorders2'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def instanceId1 = callonce uuid3
    * def instanceId2 = callonce uuid4
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6

    * def isbn1 = "1-56619-909-3 first-isbn"
    * def isbn1ProductId = "1-56619-909-3"
    * def isbn1Qualifier = "first-isbn"
    * def isbn2 = "1-56619-909-3 second-isbn"


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

  Scenario: Create instances
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
    * set poLine.details.productIds = [ { productId: "#(isbn1ProductId)", qualifier: "#(isbn1Qualifier)" , productIdType: "#(globalISBNIdentifierTypeId)" } ]

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
    And match $.details.productIds[0].productId == '9781566199094'
    And match $.details.productIds[0].qualifier == 'first-isbn'

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
    And match $.details.productIds[0].productId == '9781566199094'
    And match $.details.productIds[0].qualifier == 'second-isbn'