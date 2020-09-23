Feature: Create order with invoice that has enough money

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def fundWithExpenseClassesId = callonce uuid9
    * def budgetWithExpenseClassesId = callonce uuid10

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def orderLineIdTwo = callonce uuid5
    * def orderLineIdWithExpenseClasses = callonce uuid11

    * def invoiceId = callonce uuid6
    * def invoiceLineIdOne = callonce uuid7
    * def invoiceLineIdTwo = callonce uuid8
    * def invoiceLineIdWithExpenseClasses = callonce uuid12

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>, <statusExpenseClasses>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * def emptyExpenseClasses = []
    * def presentExpenseClasses = [{'expenseClassId': '#(globalElecExpenseClassId)'}, {'expenseClassId': '#(globalPrnExpenseClassId)'}]
    * def statusExpenseClasses = <statusExpenseClasses>

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 10000, 'statusExpenseClasses': #(statusExpenseClasses)}


    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 10000
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0

    Examples:
      | fundId                   | budgetId                   | statusExpenseClasses  |
      | fundId                   | budgetId                   | emptyExpenseClasses   |
      | fundWithExpenseClassesId | budgetWithExpenseClassesId | presentExpenseClasses |

  Scenario: Create orders

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

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    * def fundDistribution = { 'fundId': #(fundId), 'distributionType': 'percentage', 'value': 100}
    * def fundDistributionElectronic = { 'fundId': #(fundWithExpenseClassesId), 'distributionType': 'percentage', 'value': 50, 'expenseClassId': #(globalElecExpenseClassId)}
    * def fundDistributionPrint = { 'fundId': #(fundWithExpenseClassesId), 'distributionType': 'percentage', 'value': 50, 'expenseClassId': #(globalPrnExpenseClassId)}

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution = <fundDistributions>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId                   | fundDistributions                                          | amount |
      | orderId | orderLineIdOne                | [#(fundDistribution)]                                      | 4500   |
      | orderId | orderLineIdTwo                | [#(fundDistribution)]                                      | 5500   |
      | orderId | orderLineIdWithExpenseClasses | [#(fundDistributionElectronic), #(fundDistributionPrint)]  | 1000   |

  Scenario: Open order
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
      | fundId                    | amount |
      | fundId                    | 10000  |
      | fundWithExpenseClassesId  | 1000   |

    Scenario: check encumbrances
      Given path 'finance/transactions'
      And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
      When method GET
      Then status 200
      And match $.transactions == '#[4]'

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
      | orderLineId                   | invoiceLineId                   |
      | orderLineIdOne                | invoiceLineIdOne                |
      | orderLineIdTwo                | invoiceLineIdTwo                |
      | orderLineIdWithExpenseClasses | invoiceLineIdWithExpenseClasses |

  Scenario: approve invoice
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

  Scenario Outline: check budget amounts
    * def fundId = <fundId>
    * def awaitingPayment = <amount>

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 10000 - awaitingPayment
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == awaitingPayment
    And match budget.unavailable == awaitingPayment

    Examples:
      | fundId                    | amount |
      | fundId                    | 10000  |
      | fundWithExpenseClassesId  | 1000   |

  Scenario: check pending payments
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.transactions == '#[4]'

  Scenario: pay invoice
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

  Scenario Outline: check budget amounts after pay
    * def fundId = <fundId>
    * def expenditures = <amount>

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 10000 - expenditures
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.expenditures == expenditures
    And match budget.unavailable == expenditures

    Examples:
      | fundId                    | amount |
      | fundId                    | 10000  |
      | fundWithExpenseClassesId  | 1000   |

  Scenario: check payments
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.transactions == '#[4]'
