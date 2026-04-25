# For MODORDERS-658, MODORDERS-927
Feature: Get and put a composite order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def isbn = "9780552142359"



  Scenario: Get and put a composite order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), allocated: 1000, fundId: #(fundId) }

    # 2. Create the order
    * configure headers = headersUser
    * def v = call createOrder { id: #(orderId) }

    # 3. Create an order line with a product id
    * table productIds
      | productId       | productIdType                          |
      | '15934409'      | '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef' |
      | '3787301917'    | globalISBNIdentifierTypeId             |
      | '9783787301911' | globalISBNIdentifierTypeId             |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', productIds: '#(productIds)' }

    # 4. Open the order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Re-add the product ids with order storage
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

    # 6. Get and put the order line without changing it
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def order = $

    Given path 'orders/order-lines', poLineId
    And request order
    When method PUT
    Then status 204

    # 7. Verify product identifiers after updating the POL
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
