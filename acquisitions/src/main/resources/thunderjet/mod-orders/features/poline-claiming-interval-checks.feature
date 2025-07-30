@parallel=false
Feature: Claiming Active/Claiming interval checks

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

  Scenario: Check that claiming fields are inherited from poLine to title
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Order and Po Line with claiming fields
    * def v = call createOrder { 'id': '#(orderId)' }
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 10
    * set poLine.claimingActive = true
    * set poLine.claimingInterval = 1
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 2. Check that claiming fields are inherited to title and metadata is set
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def title = $.titles[0]
    * def titleId = title.id
    And match title.claimingActive == true
    And match title.claimingInterval == 1
    And match title.metadata.createdDate != null
    And match title.metadata.createdByUserId != null

  Scenario: Update claiming values for poLine and title
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Order and Po Line with claiming fields
    * call createOrder { 'id': '#(orderId)' }
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.claimingActive = true
    * set poLine.claimingInterval = 2
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 2. Update Po Line claiming fields
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.claimingInterval = 3
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 3. Check that title claiming fields are updated
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def title = $.titles[0]
    * def titleId = title.id
    And match title.claimingActive == true
    And match title.claimingInterval == 3

    # 4. Update claimingInterval in title
    * set title.claimingInterval = 5
    Given path 'orders/titles', titleId
    And request title
    When method PUT
    Then status 204

    # 5. Validate that claiming interval in poLine is untouched
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    And match poLine.claimingInterval == 3
