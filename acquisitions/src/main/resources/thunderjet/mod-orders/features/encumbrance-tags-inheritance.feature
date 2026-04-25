Feature: Verify once order is opened or poline is updated, encumbrance inherit poline's tags

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

    * configure retry = { count: 4, interval: 1000 }


  Scenario: Verify once order is opened or poline is updated, encumbrance inherit poline's tags
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create composite order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.collection = false
    * set orderLine.rush = false
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.tags.tagList = [ "created" ]

    And request orderLine
    When method POST
    Then status 201

    # 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Verify created encumbrance
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePoLineId==' + poLineId
    When method get
    Then status 200
    And match response.transactions[0].tags.tagList == [ "created" ]

    # 5. Update order line
    * configure headers = headersUser
    Given path 'orders/order-lines', poLineId
    When method get
    Then status 200

    * def orderLine = $
    * set orderLine.cost.listUnitPrice = 10
    * table fundDistribution
    | fundId        | distributionType | value |
    | globalFundId  | 'percentage'     | 90.0  |
    | globalFundId2 | 'percentage'     | 10.0  |
    * set orderLine.fundDistribution = fundDistribution
    * set orderLine.tags.tagList = [ "updated" ]

    Given path 'orders/order-lines', poLineId
    And request orderLine
    When method put
    Then status 204

    # 6. Verify updated encumbrances
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePoLineId==' + poLineId
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.transactions[0].tags.tagList == [ "updated" ]
    And match response.transactions[1].tags.tagList == [ "updated" ]
