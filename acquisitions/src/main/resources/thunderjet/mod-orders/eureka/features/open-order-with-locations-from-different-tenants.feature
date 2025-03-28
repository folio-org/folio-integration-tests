@parallel=false
# for https://folio-org.atlassian.net/browse/MODORDSTOR-402
Feature: Open ongoing order

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testorders'}
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


  Scenario: Create fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active' }


    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4

  Scenario: Create an order
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


  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201



  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/multi-location-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId    | fundId | amount |
      | orderId | orderLineIdOne | fundId | 100    |

  Scenario: Open order
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # Attempt to update order to open, it should fail
    # Fund A in POL     - Loc1 [createRestrictedFund.feature]
    # Fund B in POL     - not exists
    # Locations in POL  - Loc2 [multi-location-order-line.json]
    # Result:           - Fail (Fund A doesn't have valid location)
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 422
    And match $.errors[0].code == 'fundLocationRestrictionViolation'
    And match $.errors[0].parameters[2].key == 'restrictedLocations'
    And match $.errors[0].parameters[2].value contains globalLocationsId
