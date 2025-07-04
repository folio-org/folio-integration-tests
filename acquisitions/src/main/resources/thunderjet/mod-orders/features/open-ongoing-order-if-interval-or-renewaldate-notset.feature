@parallel=false
Feature: Should Open ongoing order if interval or renewal date is not set

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderIdWithoutInterval = callonce uuid3
    * def orderIdWithoutRenewalDate = callonce uuid4
    * def orderIdWithoutAll = callonce uuid5
    * def orderLineIdOne = callonce uuid6
    * def orderLineIdTwo = callonce uuid7
    * def orderLineIdThree = callonce uuid8

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * configure headers = headersAdmin
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)' }
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 10000 }

    Examples:
      | fundId | budgetId |
      | fundId | budgetId |

  Scenario: check budget after create
    * configure headers = headersAdmin
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

  Scenario: Create orders without interval

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderIdWithoutInterval)',
      vendor: '#(globalVendorId)',
      orderType: 'Ongoing',
      "ongoing" : {
        "isSubscription" : true,
        "renewalDate" : "2022-05-08T00:00:00.000+00:00"
      }
    }
    """
    When method POST
    Then status 201

  Scenario: Create orders without renewal date

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderIdWithoutRenewalDate)',
      vendor: '#(globalVendorId)',
      orderType: 'Ongoing',
      "ongoing" : {
        "interval" : 123,
        "isSubscription" : true,
      }
    }
    """
    When method POST
    Then status 201

  Scenario: Create orders without all

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderIdWithoutAll)',
      vendor: '#(globalVendorId)',
      orderType: 'Ongoing',
      "ongoing" : {
        "isSubscription": false,
        "manualRenewal": false
      }
    }
    """
    When method POST
    Then status 201

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId                   | orderLineId      | fundId | amount |
      | orderIdWithoutInterval    | orderLineIdOne   | fundId | 100    |
      | orderIdWithoutRenewalDate | orderLineIdTwo   | fundId | 100    |
      | orderIdWithoutAll         | orderLineIdThree | fundId | 100    |

  Scenario Outline: Open order
    # ============= get order to open ===================
    Given path 'orders/composite-orders', <orderId>
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', <orderId>
    And request orderResponse
    When method PUT
    Then status 204

    Examples:
      | orderId
      | orderIdWithoutInterval
      | orderIdWithoutRenewalDate
      | orderIdWithoutAll

  Scenario Outline: Check order line status
    # ============= get order to open ===================
    Given path 'orders/order-lines', <orderLineId>
    When method GET
    Then status 200

    And match response.paymentStatus == 'Ongoing'
    And match response.receiptStatus == 'Ongoing'

    Examples:
      | orderLineId
      | orderLineIdOne
      | orderLineIdTwo
      | orderLineIdThree
