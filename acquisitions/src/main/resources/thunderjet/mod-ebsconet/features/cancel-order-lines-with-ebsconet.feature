@parallel=false
# For https://issues.folio.org/browse/MODEBSNET-22
Feature: Cancel order lines with ebsconet

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

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def poLineId3 = callonce uuid6
    * def poLineId4 = callonce uuid7


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario Outline: Create a po line with paymentStatus=<paymentStatus> and receiptStatus=<receiptStatus>
    * copy poLine = orderLineTemplate
    * set poLine.id = <id>
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = '<paymentStatus>'
    * set poLine.receiptStatus = '<receiptStatus>'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    Examples:
      | id        | paymentStatus        | receiptStatus        |
      | poLineId1 | Awaiting Payment     | Partially Received   |
      | poLineId2 | Payment Not Required | Awaiting Receipt     |
      | poLineId3 | Fully Paid           | Receipt Not Required |
      | poLineId4 | Partially Paid       | Fully Received       |


  Scenario: Open the order
    * def v = call openOrder { orderId: #(orderId) }


  Scenario Outline: Use ebsconet to cancel po line <id>
    Given path 'orders/order-lines', <id>
    When method GET
    Then status 200
    * def poLineNumber = $.poLineNumber

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    * def ebsconetLine = $
    * set ebsconetLine.type = 'non-renewal'

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    And request ebsconetLine
    When method PUT
    Then status <expectedCode>

    Examples:
      | id        | expectedCode |
      | poLineId1 | 204          |
      | poLineId2 | 204          |
      | poLineId3 | 422          |
      | poLineId4 | 204          |


  Scenario: Check error when cancelling again
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def poLineNumber = $.poLineNumber

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    * def ebsconetLine = $
    * set ebsconetLine.type = 'non-renewal'

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    And request ebsconetLine
    When method PUT
    Then status 422


  Scenario Outline: Check the po lines paymentStatus and receiptStatus
    Given path 'orders/order-lines', <id>
    When method GET
    Then status 200
    And match paymentStatus == '<paymentStatus>'
    And match receiptStatus == '<receiptStatus>'

    Examples:
      | id        | paymentStatus        | receiptStatus        |
      | poLineId1 | Cancelled            | Cancelled            |
      | poLineId2 | Payment Not Required | Cancelled            |
      | poLineId3 | Fully Paid           | Receipt Not Required |
      | poLineId4 | Cancelled            | Fully Received       |
