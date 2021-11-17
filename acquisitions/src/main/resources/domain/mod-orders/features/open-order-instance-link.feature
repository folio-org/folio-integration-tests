@parallel=false
# for https://issues.folio.org/browse/MODORDERS-573 and https://issues.folio.org/browse/MODORDERS-557
Feature: Check opening an order links to the right instance based on the identifier type and value but only if instance matching is not disabled

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_orders'}
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
    * def instanceTypeId = callonce uuid5
    * def orderId1 = callonce uuid6
    * def orderId2 = callonce uuid7
    * def orderId3 = callonce uuid8
    * def poLineId1 = callonce uuid9
    * def poLineId2 = callonce uuid10
    * def poLineId3 = callonce uuid11
    * def configUUID = callonce uuid12

    * def isbn1 = "9780552142359"
    * def isbn2 = "9781580469968"


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
        },
        {
          "value": "#(isbn2)",
          "identifierTypeId": "#(globalIdentifierTypeId)"
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
      "title": "Music, Liturgy, and Confraternity Devotions in Paris and Tournai, 1300-1550",
      "instanceTypeId": "#(globalInstanceTypeId)",
      "identifiers": [
        {
          "value": "#(isbn2)",
          "identifierTypeId": "#(globalISBNIdentifierTypeId)"
        },
        {
          "value": "#(isbn1)",
          "identifierTypeId": "#(globalIdentifierTypeId)"
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
      id: '#(orderId1)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line
    * print "Create an order line"

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId1
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.details.productIds = [ { productId: "#(isbn2)", productIdType: "#(globalISBNIdentifierTypeId)" } ]

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * print "Open the order"

    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId1
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Check the order line instanceId
    * print "Check the order line"

    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    And match $.instanceId == instanceId2


  Scenario: Create configuration with disabled instance matching
    * configure headers = headersAdmin
    Given path 'configurations/entries'
    And request
    """
    {
      "id": "#(configUUID)",
      "module" : "ORDERS",
      "configName" : "disableInstanceMatching",
      "enabled" : true,
      "value" : "{\"isInstanceMatchingDisabled\":true}"
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
      id: '#(orderId2)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line
    * print "Create an order line"

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * set poLine.details.productIds = [ { productId: "#(isbn2)", productIdType: "#(globalISBNIdentifierTypeId)" } ]

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * print "Open the order"

    Given path 'orders/composite-orders', orderId2
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId2
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Check the order line instanceId
    * print "Check the order line"

    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    And match $.instanceId != instanceId1
    And match $.instanceId != instanceId2


  Scenario: Update configuration with enabled instance matching
    * configure headers = headersAdmin
    Given path 'configurations/entries'
    And param query = 'configName==disableInstanceMatching'
    When method GET
    Then status 200
    * def config = $.configs[0]
    * set config.value = "{\"isInstanceMatchingDisabled\":false}"
    * def configId = $.configs[0].id

    Given path 'configurations/entries', configId
    And request config
    When method PUT
    Then status 204


  Scenario: Create an order
    * print "Create an order"
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId3)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line
    * print "Create an order line"

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId3
    * set poLine.purchaseOrderId = orderId3
    * set poLine.details.productIds = [ { productId: "#(isbn2)", productIdType: "#(globalISBNIdentifierTypeId)" } ]

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * print "Open the order"

    Given path 'orders/composite-orders', orderId3
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId3
    And request orderResponse
    When method PUT
    Then status 204


  Scenario: Check the order line instanceId
    * print "Check the order line"

    Given path 'orders/order-lines', poLineId3
    When method GET
    Then status 200
    And match $.instanceId == instanceId2
