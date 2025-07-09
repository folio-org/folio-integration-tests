Feature: Validate POL suppress instance from discovery

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json, text/plain", "x-okapi-tenant": "#(testTenant)" }

    * def poTrueValue = read('classpath:samples/mod-gobi/suppress-instance-from-discovery/po-unlisted-print-monograph-with-true-value.xml')
    * def poFalseValue = read('classpath:samples/mod-gobi/suppress-instance-from-discovery/po-unlisted-print-monograph-with-false-value.xml')
    * def poUnsetValue = read('classpath:samples/mod-gobi/suppress-instance-from-discovery/po-unlisted-print-monograph-with-unset-value.xml')
    * def poInvalidValue = read('classpath:samples/mod-gobi/suppress-instance-from-discovery/po-unlisted-print-monograph-with-invalid-value.xml')
    * def poInvalidPosition = read('classpath:samples/mod-gobi/suppress-instance-from-discovery/po-unlisted-print-monograph-with-invalid-position.xml')
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: Send order with (with SuppressInstanceFromDiscovery = true)
    # Create an order
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request poTrueValue
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Verify order line was created with checkinItems flag
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headersUser
    When method GET
    Then retry until responseStatus == 200
    And match $.poLines[0].suppressInstanceFromDiscovery == true
    * def orderId = $.poLines[0].purchaseOrderId

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  @Positive
  Scenario: Send order with (with SuppressInstanceFromDiscovery = false)
    # Create an order
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request poFalseValue
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Verify order line was created with checkinItems flag
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headersUser
    When method GET
    Then retry until responseStatus == 200
    And match $.poLines[0].suppressInstanceFromDiscovery == false
    * def orderId = $.poLines[0].purchaseOrderId

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  @Positive
  Scenario: Send order with (with SuppressInstanceFromDiscovery unset value)
    # Create an order
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request poUnsetValue
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Verify order line was created with checkinItems flag
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headersUser
    When method GET
    Then retry until responseStatus == 200
    And match $.poLines[0].suppressInstanceFromDiscovery == false
    * def orderId = $.poLines[0].purchaseOrderId

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  @Negative
  Scenario: Send order with (with SuppressInstanceFromDiscovery invalid value)
    # Create an order
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request poInvalidValue
    When method POST
    Then status 400
    And match /Response/Error/Code == "INVALID_XML"
    And match /Response/Error/Message contains "Invalid content was found starting with element 'SuppressFromDiscovery'."

  @Negative
  Scenario: Send order with (with SuppressInstanceFromDiscovery invalid position)
    # Create an order
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request poInvalidPosition
    When method POST
    Then status 400
    And match /Response/Error/Code == "INVALID_XML"
    And match /Response/Error/Message contains "Invalid content was found starting with element 'SuppressFromDiscovery'."