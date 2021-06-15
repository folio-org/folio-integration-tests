Feature: Test order invoice relation can be deleted

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_cross_modules'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def orderIdOne = callonce uuid1
    * def orderIdTwo = callonce uuid2
    * def orderLineIdOne = callonce uuid3
    * def orderLineIdTwo = callonce uuid4

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
      | orderIdOne    |
      | orderIdTwo |

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
      | orderIdTwo | orderLineIdTwo   |


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


  Scenario Outline: Check that order invoice relation has been created
    * def orderId = <orderId>
    * def invoiceId = <invoiceId>
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == 1
    Examples:
      | orderId    | invoiceId |
      | orderIdOne | invoiceId |

  Scenario: Update order line reference in the invoice line
    Given path 'invoice/invoice-lines', invoiceLineIdOne
    When method GET
    Then status 200
    * def invoiceLinePayload = $
    * remove invoiceLinePayload.poLineId

    Given path 'invoice/invoice-lines', invoiceLineIdOne
    And request invoiceLinePayload
    When method PUT
    Then status 204

  Scenario Outline: Check that order invoice relation has been changed
    * def orderId = <orderId>
    * def invoiceId = <invoiceId>
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == <count>
    Examples:
      | orderId    | invoiceId | count |
      | orderIdOne | invoiceId | 0     |
      | orderIdTwo | invoiceId | 0     |
