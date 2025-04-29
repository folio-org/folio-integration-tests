@parallel=false
# for https://issues.folio.org/browse/MODORDERS-658
# for https://issues.folio.org/browse/MODORDERS-927
Feature: Get and put a composite order

  Background:
    * url baseUrl
     # uncomment below line for development
#    * callonce dev {tenant: 'testorders'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def isbn = "9780552142359"

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')


  Scenario: Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), allocated: 1000, fundId: #(fundId) }


  Scenario: Create the order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create an order line with a product id
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.details.productIds = [ { productId: "15934409", productIdType: "439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef" }, { productId: "3787301917", productIdType: "#(globalISBNIdentifierTypeId)" }, { productId: "9783787301911", productIdType: "#(globalISBNIdentifierTypeId)" } ]

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * def v = call openOrder { orderId: "#(orderId)" }


  Scenario: Re-add the product ids with order storage
    * configure headers = headersAdmin
    Given path 'orders-storage/po-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.details.productIds[0] = { productId: "15934409", productIdType: "439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef" }
    * set poLine.details.productIds[1] = { productId: "3787301917 books", productIdType: "#(globalISBNIdentifierTypeId)" }
    * set poLine.details.productIds[2] = { productId: "9783787301911 books", productIdType: "#(globalISBNIdentifierTypeId)" }
    * set poLine.details.productIds[3] = { productId: "12345", productIdType: "#(globalISBNIdentifierTypeId)" }

    Given path 'orders-storage/po-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Get and put the order line without changing it
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def order = $

    Given path 'orders/order-lines', poLineId
    And request order
    When method PUT
    Then status 204

  Scenario: Verify product identifiers after update POL
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.details.productIds[0].productId == '15934409'
    And match $.details.productIds[0].productIdType == '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef'
    And match $.details.productIds[0].qualifier == '#notpresent'

    And match $.details.productIds[1].productId == '3787301917 books'
    And match $.details.productIds[1].productIdType == '#(globalISBNIdentifierTypeId)'
    And match $.details.productIds[1].qualifier == '#notpresent'

    And match $.details.productIds[2].productId == '9783787301911 books'
    And match $.details.productIds[2].productIdType == '#(globalISBNIdentifierTypeId)'
    And match $.details.productIds[2].qualifier == '#notpresent'

    And match $.details.productIds[3].productId == '12345'
    And match $.details.productIds[3].productIdType == '#(globalISBNIdentifierTypeId)'
    And match $.details.productIds[3].qualifier == '#notpresent'

