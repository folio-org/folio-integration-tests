@parallel=false
# for https://issues.folio.org/browse/MODORDERS-855
Feature: Reopen order with 50 lines

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def closeOrder = read('classpath:thunderjet/mod-orders/reusable/close-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3

    * configure readTimeout = 600000


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create 50 order lines
    * def lineParameters = []
    * def createParameterArray =
      """
      function() {
        for (let i=0; i<50; i++) {
          lineParameters.push({ id: uuid(), orderId: orderId, fundId: fundId });
        }
      }
      """
    * eval createParameterArray()
    * def v = call createOrderLine lineParameters


  Scenario: Open the order
    * def v = call openOrder { orderId: "#(orderId)" }

  Scenario: Close the order
    * def v = call closeOrder { orderId: #(orderId) }

  Scenario: Check the encumbrances were all released
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 50


  Scenario: Reopen the order
    * def v = call openOrder { orderId: "#(orderId)" }

  Scenario: Check the encumbrances were all unreleased
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 0
