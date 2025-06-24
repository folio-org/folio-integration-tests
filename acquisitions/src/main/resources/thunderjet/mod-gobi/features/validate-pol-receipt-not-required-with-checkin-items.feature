Feature: Validate POL receipt status with checkin items

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * def mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph-receipt-checkin-validation.json')
    * def po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph.xml')

  @Negative
  Scenario: Send order with receipt not required and checkin items false
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request mapping
    When method POST
    Then status 201

    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200

    # Put an order for updated mapping
    # checkinItems flag will be overridden automatically to true
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Verify order line was created with checkinItems flag
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].checkinItems == true

  @Positive
  Scenario: Send order with receipt not required and checkin items true
    # Set receiving workflow mapping default to "INDEPENDENT" instead of "SYNCHRONIZED"
    * set mapping.mappings[17].dataSource.default = "INDEPENDENT"
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request mapping
    When method PUT
    Then status 204

    # Put an order for updated mapping
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Verify order line was created with checkinItems flag
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].checkinItems == true