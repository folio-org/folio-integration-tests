Feature: Verify updating poLine location restricted after open order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Verify updating poLine location restricted after open order
    * def orderId = call uuid
    * def poLineId = call uuid
    * def locationId = call uuid
    * def holdingIdForUpdate = call uuid

    # 1. Create composite order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(globalFundId)' }

    # 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Verify that pieces has been created for poLine
    Given path 'orders-storage/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # 5. get poline and increase the quantity
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = $
    * set poLineResponse.cost.quantityPhysical = 2
    * set poLineResponse.locations[0].quantityPhysical = 2

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 400
    And match $.errors contains deep {code: 'locationCannotBeModifiedAfterOpen'}

    # 6. get poline and update location
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = $
    * set poLineResponse.locations[0].holdingId = holdingIdForUpdate

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 400
    And match $.errors contains deep {code: 'locationCannotBeModifiedAfterOpen'}

    # 7. Verify that pieces has not been increase for poLine
    Given path 'orders-storage/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
