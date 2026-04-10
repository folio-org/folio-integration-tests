@parallel=false
Feature: Test order invoice relation logic

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

    * def orderId = callonce uuid1
    * def orderIdTwo = callonce uuid2
    * def orderLineIdOne = callonce uuid3
    * def orderLineIdTwo = callonce uuid4
    * def orderLineIdThree = callonce uuid5

    * def invoiceId = callonce uuid6
    * def invoiceLineIdOne = callonce uuid7
    * def invoiceLineIdTwo = callonce uuid8
    * def invoiceLineIdThree = callonce uuid9

  Scenario Outline: Create orders
    * def orderId = <orderId>
    * def v = call createOrder { id: '#(orderId)' }

    Examples:
      | orderId    |
      | orderId    |
      | orderIdTwo |

  Scenario Outline: Create order lines for <orderLineId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(globalFundId)' }

    Examples:
      | orderId    | orderLineId      |
      | orderId    | orderLineIdOne   |
      | orderId    | orderLineIdTwo   |
      | orderIdTwo | orderLineIdThree |

  Scenario: Create invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

  Scenario Outline: Create invoice lines
    * def orderLineId = <orderLineId>
    * def invoiceLineId = <invoiceLineId>

    # ============= get order line with fund distribution ===================
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def fd = response.fundDistribution
    * def lineAmount = response.cost.listUnitPrice

    # ============= Create invoice line ===================
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fd)', poLineId: '#(orderLineId)', total: '#(lineAmount)' }

    Examples:
      | orderLineId      | invoiceLineId      |
      | orderLineIdOne   | invoiceLineIdOne   |
      | orderLineIdTwo   | invoiceLineIdTwo   |
      | orderLineIdThree | invoiceLineIdThree |

  Scenario Outline: Check that order invoice relation has been created
    * def orderId = <orderId>
    * def invoiceId = <invoiceId>
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query
    * configure headers = headersAdmin
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == 1
    Examples:
      | orderId    | invoiceId |
      | orderId    | invoiceId |
      | orderIdTwo | invoiceId |


  Scenario Outline: delete invoice lines
    Given path 'invoice/invoice-lines', <invoiceLineId>
    When method DELETE
    Then status 204

    Examples:
      | invoiceLineId      |
      | invoiceLineIdOne   |
      | invoiceLineIdThree |

  Scenario Outline: Check that order invoice relation still in place
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
      | orderId    | invoiceId | 1     |
      | orderIdTwo | invoiceId | 0     |

  Scenario: check that delete order line delete order invoice relation
    Given path 'invoice/invoice-lines', invoiceLineIdTwo
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
      | orderId    | invoiceId | 0     |
      | orderIdTwo | invoiceId | 0     |
