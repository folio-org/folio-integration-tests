Feature: Check that totalEncumbered and totalExpended calculated correctly

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_orders32'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersAdmin
    # load global variables
    * callonce variables

    * def previousFiscalYear = callonce uuid1
    * def currentFiscalYear = callonce uuid2
    * def ledgerId = callonce uuid3
    * def fundId1 = callonce uuid4
    * def fundId2 = callonce uuid11

    * def encumbranceOnlyOrderId = callonce uuid5
    * def encumbranceOnlyLineId = callonce uuid6

    * def noEncumbranceOrderId = callonce uuid7
    * def noEncumbranceLineId = callonce uuid8

    * def paymentsOrderId = callonce uuid9
    * def paymentsLineId = callonce uuid10

    * def previousInvoiceId = callonce uuid12
    * def currentInvoiceId = callonce uuid16

    * def previousEnc = callonce uuid13
    * def currentEncPayment = callonce uuid14
    * def currentEncCredit = callonce uuid15


    * def codePrefix = callonce random_string
    * def toYear = callonce getCurrentYear
    * def fromYear = parseInt(toYear) -1

  Scenario Outline: prepare fiscal year for <year>
    * def fiscalYearId = <fiscalYearId>
    * def year = <year>

    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": '#(fiscalYearId)',
      "name": '#(codePrefix + year)',
      "code": '#(codePrefix + year)',
      "periodStart": '#(year + "-01-01T00:00:00Z")',
      "periodEnd": '#(year + "-12-30T23:59:59Z")'
    }
    """
    When method POST
    Then status 201

    Examples:
      | fiscalYearId       | year     |
      | previousFiscalYear | fromYear |
      | currentFiscalYear  | toYear   |

  Scenario: prepare ledger

    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(ledgerId)",
      "ledgerStatus": "Active",
      "name": "#(ledgerId)",
      "code": "#(ledgerId)",
      "fiscalYearOneId":"#(previousFiscalYear)",
      "restrictEncumbrance": false
    }
    """
    When method POST
    Then status 201

  Scenario Outline: prepare fund with fundId
    * def fundId = <fundId>

    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId)",
      "code": "#(fundId)",
      "description": "Fund for API Tests",
      "externalAccountNo": "#(fundId)",
      "fundStatus": "Active",
      "ledgerId": "#(ledgerId)",
      "name": "Fund for API Tests"
    }
    """
    When method POST
    Then status 201

    Examples:
     | fundId  |
     | fundId1 |
     | fundId2 |


  Scenario Outline: Create a budgets for fiscal year <fiscalYearId> and fund <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def fundId = <fundId>

    Given path 'finance/budgets'
    And request
    """
    {
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(fiscalYearId + fundId)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": 9990
    }
    """
    When method POST
    Then status 201

   Examples:
    | fiscalYearId       | fundId  |
    | previousFiscalYear | fundId1 |
    | currentFiscalYear  | fundId1 |
    | previousFiscalYear | fundId2 |
    | currentFiscalYear  | fundId2 |

  Scenario Outline: Create orders with one line

    * def orderId = <orderId>
    * def poLineId = <orderLineId>


    Given path 'orders-storage/purchase-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      workflowStatus: 'Open'
    }
    """
    When method POST
    Then status 201

  Given path '/orders-storage/po-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 10
    * set orderLine.fundDistribution[0].fundId = fundId1

    And request orderLine
    When method POST
    Then status 201

    Examples:
     | orderId                | orderLineId           |
     | encumbranceOnlyOrderId | encumbranceOnlyLineId |
     | noEncumbranceOrderId   | noEncumbranceLineId   |
     | paymentsOrderId        | paymentsLineId        |


  Scenario Outline: Create order-transaction-summary for order <orderId>
    * def orderId = <orderId>

    Given path 'finance/order-transaction-summaries'
    And request
    """
      {
        "id": "#(orderId)",
        "numTransactions": <numTransactions>
      }
    """
    When method POST
    Then status 201

    Examples:
      | orderId                | numTransactions |
      | encumbranceOnlyOrderId | 4               |
      | noEncumbranceOrderId   | 1               |
      | paymentsOrderId        | 3               |

  Scenario Outline: Create invoice-transaction-summary for paymentsOrderId
    * def invoiceId = <invoiceId>

    Given path 'finance/invoice-transaction-summaries'
    And request
    """
      {
        "id": '#(invoiceId)',
        "numPendingPayments": <num>,
        "numPaymentsCredits": <num>
      }

    """
    When method POST
    Then status 201
    Examples:
      | invoiceId         | num |
      | previousInvoiceId | 1   |
      | currentInvoiceId  | 2   |

  Scenario Outline: Create encumbrances for order <orderId>
    * def transactionId = <transactionId>
    * def orderId = <orderId>
    * def orderLineId = <orderLineId>
    * def fiscalYearId = <fiscalYearId>
    * def fundId = <fundId>

    Given path 'finance/encumbrances'
    And request
    """
      {
        "id": "#(transactionId)",
        "amount": <amount>,
        "currency": "USD",
        "fiscalYearId": "#(fiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Encumbrance",
        "encumbrance": {
          "initialAmountEncumbered": <amount>,
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": "#(orderId)",
          "sourcePoLineId": "#(orderLineId)"
        }
      }
    """
    When method POST
    Then status 201

    Examples:
      | transactionId     | orderId                | orderLineId           | amount | fiscalYearId       | fundId  |
      | null              | encumbranceOnlyOrderId | encumbranceOnlyLineId | 100    | previousFiscalYear | fundId1 |
      | null              | encumbranceOnlyOrderId | encumbranceOnlyLineId | 100    | previousFiscalYear | fundId2 |
      | null              | encumbranceOnlyOrderId | encumbranceOnlyLineId | 152.33 | currentFiscalYear  | fundId1 |
      | null              | encumbranceOnlyOrderId | encumbranceOnlyLineId | 452.33 | currentFiscalYear  | fundId2 |
      | null              | noEncumbranceOrderId   | noEncumbranceLineId   | 1000   | previousFiscalYear | fundId1 |
      | previousEnc       | paymentsOrderId        | paymentsLineId        | 1000   | previousFiscalYear | fundId1 |
      | currentEncPayment | paymentsOrderId        | paymentsLineId        | 2152.3 | currentFiscalYear  | fundId1 |
      | currentEncCredit  | paymentsOrderId        | paymentsLineId        | 1452.5 | currentFiscalYear  | fundId2 |

  Scenario Outline: create payments, credits for <encumbranceId>
    * def encumbranceId = <encumbranceId>
    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def invoiceId = <invoiceId>

    Given path 'finance-storage/transactions'
    And request
    """
      {
        "amount": <amount>,
        "currency": "USD",
        "fiscalYearId": "#(fiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "transactionType": "Pending payment",
        "sourceInvoiceId": "#(invoiceId)",
        "awaitingPayment": {
          "encumbranceId": "#(encumbranceId)"
        }
      }
    """
    When method POST
    Then status 201

    Examples:
      | encumbranceId     | amount | fundId  | fiscalYearId       | invoiceId         |
      | previousEnc       | 500    | fundId1 | previousFiscalYear | previousInvoiceId |
      | currentEncPayment | 152.29 | fundId1 | currentFiscalYear  | currentInvoiceId  |
      | currentEncCredit  | -99.37 | fundId2 | currentFiscalYear  | currentInvoiceId  |


  Scenario Outline: create payments, credits for <encumbranceId>
    * def encumbranceId = <encumbranceId>
    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def invoiceId = <invoiceId>

    Given path 'finance-storage/transactions'
    And request
    """
      {
        "amount": <amount>,
        "currency": "USD",
        "fiscalYearId": "#(fiscalYearId)",
        "source": "User",
        "fromFundId": "#(fundId)",
        "toFundId": "#(fundId)",
        "transactionType": <type>,
        "sourceInvoiceId": "#(invoiceId)",
        "paymentEncumbranceId": "#(encumbranceId)"
      }
    """
    When method POST
    Then status 201

    Examples:
      | encumbranceId     | amount | fundId  | fiscalYearId       | type      | invoiceId         |
      | previousEnc       | 500    | fundId1 | previousFiscalYear | 'Payment' | previousInvoiceId |
      | currentEncPayment | 152.29 | fundId1 | currentFiscalYear  | 'Payment' | currentInvoiceId  |
      | currentEncCredit  | 99.37  | fundId2 | currentFiscalYear  | 'Credit'  | currentInvoiceId  |

  Scenario Outline: Check totalEncumbered, totalExpended values of order <orderId>
    * configure headers = headersUser

    # ============= get order to open ===================
    Given path 'orders/composite-orders', <orderId>
    When method GET
    Then status 200
    * match $.totalEncumbered == <totalEncumbered>
    * match $.totalExpended == <totalExpended>


    Examples:
      | orderId                | totalEncumbered | totalExpended |
      | encumbranceOnlyOrderId | 604.66          | 0             |
      | noEncumbranceOrderId   | 0               | 0             |
      | paymentsOrderId        | 3551.88         | 152.29         |