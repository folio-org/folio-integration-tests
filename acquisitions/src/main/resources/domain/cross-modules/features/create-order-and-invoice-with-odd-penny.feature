Feature: Create orders and invoices with odd penny

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_cross_modules'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def fundId1 = callonce uuid1
    * def budgetId1 = callonce uuid2

    * def fundId2 = callonce uuid3
    * def budgetId2 = callonce uuid4

    * def fundId3 = callonce uuid5
    * def budgetId3 = callonce uuid6

    * def orderId1 = callonce uuid7
    * def orderId2 = callonce uuid8
    * def orderId3 = callonce uuid9

    * def orderLineIdWithTwoFD = callonce uuid10
    * def orderLineIdWithThreeFD = callonce uuid11
    * def orderLineIdWithThreeFDCredit = callonce uuid12

    * def invoiceId1 = callonce uuid13
    * def invoiceId2 = callonce uuid14
    * def invoiceId3 = callonce uuid15

    * def invoiceLineIdWithTwoFD = callonce uuid16
    * def invoiceLineIdWithThreeFD = callonce uuid17
    * def invoiceLineIdWithThreeFDCredit = callonce uuid18

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>, <statusExpenseClasses>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

    Examples:
      | fundId  | budgetId  |
      | fundId1 | budgetId1 |
      | fundId2 | budgetId2 |
      | fundId3 | budgetId3 |

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
      | orderId  |
      | orderId1 |
      | orderId2 |
      | orderId3 |

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    * def fd1_50 = { 'fundId': #(fundId1), 'distributionType': 'percentage', 'value': 50}
    * def fd2_50 = { 'fundId': #(fundId2), 'distributionType': 'percentage', 'value': 50}

    * def fd1_30 = { 'fundId': #(fundId1), 'distributionType': 'percentage', 'value': 30}
    * def fd2_30 = { 'fundId': #(fundId2), 'distributionType': 'percentage', 'value': 30}
    * def fd3_40 = { 'fundId': #(fundId3), 'distributionType': 'percentage', 'value': 40}

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.cost.exchangeRate = <exchangeRate>
    * set orderLine.fundDistribution = <fundDistributions>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId  | orderLineId                  | fundDistributions                 | amount | exchangeRate |
      | orderId1 | orderLineIdWithTwoFD         | [#(fd1_50), #(fd2_50)]            | 100.03 | 1.03         |
      | orderId2 | orderLineIdWithThreeFD       | [#(fd1_30), #(fd2_30), #(fd3_40)] | 100.01 | 1.0          |
      | orderId3 | orderLineIdWithThreeFDCredit | [#(fd1_30), #(fd2_30), #(fd3_40)] | 100.01 | 1.0          |

  Scenario Outline: Open order
    * def orderId = <orderId>
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    Examples:
      | orderId  |
      | orderId1 |
      | orderId2 |
      | orderId3 |

  Scenario Outline: check budget after open order
    * def fundId = <fundId>
    * def expectedEncumbered = <amount>

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 10000 - expectedEncumbered
    And match budget.expenditures == 0
    And match budget.encumbered == expectedEncumbered
    And match budget.awaitingPayment == 0
    And match budget.unavailable == expectedEncumbered

    Examples:
      | fundId  | amount |
      | fundId1 | 110.01 |
      | fundId2 | 110.02 |
      | fundId3 | 80.02  |
#
  Scenario Outline: check encumbances
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and fromFundId==' + <fundId> + ' and encumbrance.sourcePurchaseOrderId=='+ <orderId>
    When method GET
    Then status 200
    And match $.transactions[0].amount == <amount>

    Examples:
      | orderId  | fundId  | amount |
      | orderId1 | fundId1 | 50.01  |
      | orderId1 | fundId2 | 50.02  |
      | orderId2 | fundId1 | 30     |
      | orderId2 | fundId2 | 30     |
      | orderId2 | fundId3 | 40.01  |
      | orderId3 | fundId1 | 30     |
      | orderId3 | fundId2 | 30     |
      | orderId3 | fundId3 | 40.01  |

  Scenario Outline: Create invoice
    * def invoiceId = <invoiceId>
    Given path 'invoice/invoices'
    And request
    """
    {
        "id": "#(invoiceId)",
        "exchangeRate": <exchangeRate>,
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
    Examples:
      | invoiceId  | exchangeRate |
      | invoiceId1 | 1.03         |
      | invoiceId2 | 1.0          |
      | invoiceId3 | 1.0          |

  Scenario Outline: Create invoice lines for Payment
    * def orderLineId = <orderLineId>
    * def invoiceId = <invoiceId>
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
      | orderLineId            | invoiceId  | invoiceLineId            |
      | orderLineIdWithTwoFD   | invoiceId1 | invoiceLineIdWithTwoFD   |
      | orderLineIdWithThreeFD | invoiceId2 | invoiceLineIdWithThreeFD |

  Scenario Outline: Create invoice lines for Credit
    * def orderLineId = <orderLineId>
    * def invoiceId = <invoiceId>
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
        "invoiceLineStatus": "Open",
        "fundDistributions": #(fd),
        "subTotal": #(-lineAmount),
        "description": "test",
        "quantity": "1"
    }
    """
    When method POST
    Then status 201
    Examples:
      | orderLineId                  | invoiceId  | invoiceLineId                  |
      | orderLineIdWithThreeFDCredit | invoiceId3 | invoiceLineIdWithThreeFDCredit |

  Scenario Outline: approve invoice
    * def invoiceId = <invoiceId>
    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    Examples:
      | invoiceId  |
      | invoiceId1 |
      | invoiceId2 |
      | invoiceId3 |

  Scenario Outline: check budget after invoice approve
    * def fundId = <fundId>

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.awaitingPayment == <amount>

    Examples:
      | fundId  | amount |
      | fundId1 | 50.01  |
      | fundId2 | 50.02  |
      | fundId3 | 0      |

  Scenario Outline: check pending payments
    Given path 'finance/transactions'
    And param query = 'transactionType==Pending Payment and fromFundId==' + <fundId> + ' and sourceInvoiceId=='+ <invoiceId>
    When method GET
    Then status 200
    And match $.transactions[0].amount == <amount>

    Examples:
      | invoiceId  | fundId  | amount |
      | invoiceId1 | fundId1 | 50.01  |
      | invoiceId1 | fundId2 | 50.02  |
      | invoiceId2 | fundId1 | 30     |
      | invoiceId2 | fundId2 | 30     |
      | invoiceId2 | fundId3 | 40.01  |
      | invoiceId3 | fundId1 | -30    |
      | invoiceId3 | fundId2 | -30    |
      | invoiceId3 | fundId3 | -40.01 |

  Scenario Outline: pay invoice
    * def invoiceId = <invoiceId>
    # ============= pay invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Paid"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    Examples:
      | invoiceId  |
      | invoiceId1 |
      | invoiceId2 |
      | invoiceId3 |

  Scenario Outline: check payments
    Given path 'finance/transactions'
    And param query = 'transactionType==Payment and fromFundId==' + <fundId> + ' and sourceInvoiceId=='+ <invoiceId>
    When method GET
    Then status 200
    And match $.transactions[0].amount == <amount>

    Examples:
      | invoiceId  | fundId  | amount |
      | invoiceId1 | fundId1 | 50.01  |
      | invoiceId1 | fundId2 | 50.02  |
      | invoiceId2 | fundId1 | 30     |
      | invoiceId2 | fundId2 | 30     |
      | invoiceId2 | fundId3 | 40.01  |

  Scenario Outline: check credits
    Given path 'finance/transactions'
    And param query = 'transactionType==Credit and toFundId==' + <fundId> + ' and sourceInvoiceId=='+ <invoiceId>
    When method GET
    Then status 200
    And match $.transactions[0].amount == <amount>

    Examples:
      | invoiceId  | fundId  | amount |
      | invoiceId3 | fundId1 | 30     |
      | invoiceId3 | fundId2 | 30     |
      | invoiceId3 | fundId3 | 40.01  |

  Scenario Outline: check budget after pay
    * def fundId = <fundId>

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.expenditures == <amount>

    Examples:
      | fundId  | amount |
      | fundId1 | 50.01  |
      | fundId2 | 50.02  |
      | fundId3 | 0.0    |
