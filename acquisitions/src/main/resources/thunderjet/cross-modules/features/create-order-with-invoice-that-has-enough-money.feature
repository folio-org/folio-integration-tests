@parallel=false
Feature: Create order with invoice that has enough money

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

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

    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 10000, 'statusExpenseClasses': #(statusExpenseClasses)}

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

  Scenario: Create order
    * def v = call createOrder { id: '#(orderId)' }

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>
    * def amount = <amount>

    * def fundDistribution = { 'fundId': #(fundId), 'distributionType': 'percentage', 'value': 100}
    * def fundDistributionElectronic = { 'fundId': #(fundWithExpenseClassesId), 'distributionType': 'percentage', 'value': 50, 'expenseClassId': #(globalElecExpenseClassId)}
    * def fundDistributionPrint = { 'fundId': #(fundWithExpenseClassesId), 'distributionType': 'percentage', 'value': 50, 'expenseClassId': #(globalPrnExpenseClassId)}

    * def fundDistributions = <fundDistributions>

    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: '#(amount)', fundDistribution: '#(fundDistributions)' }

    Examples:
      | orderId | orderLineId                   | fundDistributions                                          | amount |
      | orderId | orderLineIdOne                | [#(fundDistribution)]                                      | 4500   |
      | orderId | orderLineIdTwo                | [#(fundDistribution)]                                      | 5500   |
      | orderId | orderLineIdWithExpenseClasses | [#(fundDistributionElectronic), #(fundDistributionPrint)]  | 1000   |

  Scenario: Open order
    * def v = call openOrder { orderId: '#(orderId)' }

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

    # ============= Create invoice line ===================
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fd)', total: '#(lineAmount)' }

    Examples:
      | orderLineId                   | invoiceLineId                   |
      | orderLineIdOne                | invoiceLineIdOne                |
      | orderLineIdTwo                | invoiceLineIdTwo                |
      | orderLineIdWithExpenseClasses | invoiceLineIdWithExpenseClasses |

  Scenario: approve invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

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
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

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
