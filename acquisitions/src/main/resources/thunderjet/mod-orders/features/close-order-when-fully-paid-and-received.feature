@parallel=false,
Feature: Verify once poline fully paid and received order should be closed

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testorders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * print okapitokenAdmin

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2

    * configure retry = { count: 4, interval: 1000 }


  Scenario: Create composite order
    * def v = call createOrder { id: #(orderId) }

  Scenario: Create order line
    * def v = callonce createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(globalFundId) }

  Scenario: Open order
    * def v = callonce openOrder { orderId: "#(orderId)" }

  Scenario: Get poLine and update payment and receipt status
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = $
    * set poLineResponse.paymentStatus = 'Fully Paid'
    * set poLineResponse.receiptStatus = 'Fully Received'

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

  Scenario: Check that order closed
    Given path 'orders/composite-orders', orderId
    When method GET
    And retry until response.workflowStatus == 'Closed'
    Then status 200

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'

  Scenario: Check the encumbrance was released
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 1

  Scenario: delete poline
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

  Scenario: delete composite orders
    Given path 'orders/composite-orders', orderId
    When method DELETE
    Then status 204
