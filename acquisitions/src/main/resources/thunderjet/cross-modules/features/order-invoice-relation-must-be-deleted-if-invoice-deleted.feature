@parallel=false
Feature: When invoice is deleted, then order vs invoice relation must be deleted and POL can be deleted

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

    * def orderIdOne = callonce uuid1
    * def orderLineIdOne = callonce uuid3

    * def invoiceId = callonce uuid6
    * def invoiceLineIdOne = callonce uuid7


  Scenario Outline: Create orders
    * def orderId = <orderId>
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    Examples:
      | orderId    |
      | orderIdOne |


  Scenario Outline: Create order lines for <orderLineId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.fundDistribution[0].fundId = globalFundId

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId    | orderLineId      |
      | orderIdOne | orderLineIdOne   |


  Scenario: Create invoice
    Given path 'invoice/invoices'
    And request
    """
    {
        "id": "#(invoiceId)",
        "chkSubscriptionOverlap": true,
        "currency": "USD",
        "source": "User",
        "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
        "status": "Open",
        "invoiceDate": "2020-05-21",
        "vendorInvoiceNo": "test",
        "accountingCode": "G64758-74828",
        "paymentMethod": "Physical Check",
        "vendorId": "c6dace5d-4574-411e-8ba1-036102fcdc9b"
    }
    """
    When method POST
    Then status 201


  Scenario Outline: Create invoice lines
    * def orderLineId = <orderLineId>
    * def invoiceLineId = <invoiceLineId>

    # ============= get order line with fund distribution ===================
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def fd = response.fundDistribution
    * def lineAmount = response.cost.listUnitPrice

    # ============= Create lines ===================

    Given path 'invoice/invoice-lines'
    And request
    """
    {
        "id": "#(invoiceLineId)",
        "invoiceId": "#(invoiceId)",
        "poLineId": "#(orderLineId)",
        "invoiceLineStatus": "Open",
        "fundDistributions": #(fd),
        "subTotal": #(lineAmount),
        "description": "test",
        "quantity": "1"
    }
    """
    When method POST
    Then status 201
    Examples:
      | orderLineId      | invoiceLineId      |
      | orderLineIdOne   | invoiceLineIdOne   |


  Scenario Outline: Check that order invoice relation has been changed

    * def orderId = <orderId>
    * def invoiceId = <invoiceId>
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query

    * configure headers = headersAdmin
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == <count>
    Examples:
      | orderId    | invoiceId | count |
      | orderIdOne | invoiceId | 1     |


  Scenario: Delete invoice
    Given path 'invoice/invoices', invoiceId
    And request
    When method DELETE
    Then status 204


  Scenario Outline: Check that order invoice relation has been deleted
    * def orderId = <orderId>
    * def invoiceId = <invoiceId>
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query

    * configure headers = headersAdmin
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == <count>
    Examples:
      | orderId    | invoiceId | count |
      | orderIdOne | invoiceId | 0     |


  Scenario: Delete order lines
    Given path 'orders/order-lines', orderLineIdOne
    When method DELETE
    Then status 204

    Given path 'orders/order-lines', orderLineIdOne
    When method GET
    Then status 404
