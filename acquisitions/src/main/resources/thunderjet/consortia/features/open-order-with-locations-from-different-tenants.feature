@parallel=false
# for https://folio-org.atlassian.net/browse/MODORDSTOR-402
Feature: Open ongoing order

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4

  Scenario: Create fund and budget
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active' }

  Scenario: check budget after create
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

  Scenario: Create orders

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'Ongoing',
      "ongoing" : {
        "interval" : 123,
        "isSubscription" : true,
        "renewalDate" : "2022-05-08T00:00:00.000+00:00"
      }
    }
    """
    When method POST
    Then status 201

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * print 'college >>> ' + collegeTenant
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/consortia/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution[0].fundId = <fundId>
    * set orderLine.locations[2].tenantId = collegeTenant

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
    Then status 204
