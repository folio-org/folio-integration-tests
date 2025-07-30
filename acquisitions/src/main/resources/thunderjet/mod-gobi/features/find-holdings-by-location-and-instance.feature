Feature: Find holdings by location and instance

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }

    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * def locationId = 'b32c5ce2-6738-42db-a291-2796b1c3c4c8'

  Scenario: Create first order
    * def sample_po_1 = read('classpath:samples/mod-gobi/po-physical-annex-holding-1.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_1
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

    # checked first order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    * def orderId = response.purchaseOrders[0].id

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  Scenario: Create second order
    * def sample_po_2 = read('classpath:samples/mod-gobi/po-physical-annex-holding-2.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

    # checked second order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    * def orderId = response.purchaseOrders[0].id

    # matched order lines requested and stored information
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].details.productIds[0].productId == '9780547572482'
    * def poLine = $.poLines[0]

    # for current instanceId and permanentLocationId have to be just one holding
    Given path '/holdings-storage/holdings'
    And param query = 'instanceId==' + poLine.instanceId + ' and permanentLocationId==' + locationId
    And headers headers
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }