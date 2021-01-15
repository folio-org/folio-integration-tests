Feature: Create order that has not enough money

  Background:
    * url baseUrl
    # uncomment below line for development
    # * callonce dev {tenant: 'test_orders'}
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

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def rolloverId = callonce uuid5
    * def rolloverErrorId = callonce uuid6


  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 9999}
    * call createRollover { 'id': '#{rolloverId}'}
    * call createRolloverError { 'id': '#(rolloverErrorId), 'ledgerRolloverId': '#(rolloverId)', 'purchaseOrderId': '#(purchaseOrderId)', 'poLineId': '#(orderLineIdOne)' }

    Examples:
      | fundId | budgetId |
      | fundId | budgetId |

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

  Scenario: Get order (rollover and rollover error records exist)

    Given path 'orders/composite-orders' , orderId
    When method GET
    Then status 200
    And match $.needReEncumber == true


  Scenario: Get order (rollover exist, rollover errors records not exist)

    Given path 'orders/composite-orders' , orderId
    When method GET
    Then status 200
    And match $.needReEncumber == false

  Scenario: Get order (rollover record not exists)

    Given path 'orders/composite-orders' , orderId
    When method GET
    Then status 200
    And match $.needReEncumber == false
