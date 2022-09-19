@ignore
Feature: Test orders

  Background:
    * url baseUrl

#    * callonce dev {tenant: 'testorders'}

    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

  Scenario Outline: create composite orders <poNumber>
    # Create composite orders
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: <id>,
      poNumber: <poNumber>,
      vendor: 'c6dace5d-4574-411e-8ba1-036102fcdc9b',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    Examples:
      | id                                     | poNumber |
      | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b80' | '112027' |
      | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b81' | '112028' |

  Scenario Outline: Create order lines
    Given path 'orders/order-lines'

    * def test = read('classpath:samples/mod-orders/order-line.json')
    * set test.poLineNumber = <poNumber> + '-1'
    * set test.id = <id>
    * set test.purchaseOrderId = <orderId>

    And request test
    When method POST
    Then status 201

    Examples:
      | id                                     | orderId                                | poNumber |
      | '1dd3bf10-09ab-4304-8bd8-ad32b5c12b80' | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b80' | '112027' |
      | '1dd3bf10-09ab-4304-8bd8-ad32b5c12b81' | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b81' | '112028' |

  Scenario Outline: open orders
    Given path 'orders/composite-orders', <id>
    When method GET
    Then status 200

    * def order = response
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', <id>
    And request order
    When method PUT
    Then status 204

    Examples:
      | id                                     |
      | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b80' |
      | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b81' |


  Scenario Outline: delete composite orders <id>
    # Create composite orders
    Given path 'orders/composite-orders', <id>
    When method DELETE
    Then status 204

    Examples:
      | id                                     |
      | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b80' |
      | '0dd3bf10-09ab-4304-8bd8-ad32b5c12b81' |


