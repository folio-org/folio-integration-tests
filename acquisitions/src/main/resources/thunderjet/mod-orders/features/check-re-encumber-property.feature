@parallel=false
Feature: Check needReEncumber flag populated correctly

  Background:
    * url baseUrl
    # uncomment below line for development
    # * callonce dev {tenant: 'testorders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def plannedFiscalYearId = karate.get('plannedFiscalYearId', globalPlannedFiscalYearId)

    * def approvalsFundTypeId = karate.get('approvalsFundTypeId', globalFundType)

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def rolloverId = callonce uuid5
    * def rolloverErrorId = callonce uuid6

    * def fundId = callonce uuid7
    * def budgetId = callonce uuid8


  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 9999 }

    Examples:
      | fundId | budgetId |
      | fundId | budgetId |

  Scenario: Create order
    * configure headers = headersUser

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

  Scenario: Create order line
    * configure headers = headersUser
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set orderLine.id = orderLineIdOne
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.fundDistribution[0].fundId = fundId
    And request orderLine
    When method POST
    Then status 201


  Scenario: Create Rollover
    * configure headers = headersAdmin
    Given path 'finance-storage/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(globalLedgerId)",
        "fromFiscalYearId": "#(fiscalYearId)",
        "toFiscalYearId": "#(plannedFiscalYearId)",
        "budgetsRollover": [],
        "encumbrancesRollover": []
      }
    """
    When method POST
    Then status 201

  Scenario: create rolloverError
    * configure headers = headersAdmin
    Given path 'finance-storage/ledger-rollovers-errors'
    And request
    """
      {
        "id": "#(rolloverErrorId)",
        "ledgerRolloverId": "#(rolloverId)",
        "errorType": "Fund",
        "failedAction": "Create Encumbrance",
        "errorMessage": "Not enough money available in the Fund to create encumbrance",
        "details": {
          "amount": 1346.11,
          "fundId": "#(fundId)",
          "fundCode": "HIST",
          "poLineId": "#(orderLineIdOne)",
          "polNumber": "10000-1",
          "purchaseOrderId": "#(orderId)",
        }
      }
    """
    When method POST
    Then status 201

  Scenario: Get order (rollover and rollover error records exist)

    Given path 'orders/composite-orders' , orderId
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match $.needReEncumber == true


  Scenario: Get order (rollover error records not exist)
    * configure headers = headersAdmin
    Given path 'finance-storage/ledger-rollovers-errors', rolloverErrorId

    When method DELETE
    Then status 204

    * configure headers = headersUser
    Given path 'orders/composite-orders' , orderId
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match $.needReEncumber == false
