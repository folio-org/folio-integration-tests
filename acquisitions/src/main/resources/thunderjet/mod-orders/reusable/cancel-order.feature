@ignore
Feature: Cancel order
  # parameters: orderId

  Background: cancelOrder
    * url baseUrl

  Scenario: Cancel order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Closed'
    * set order.closeReason = { reason: 'Cancelled' }

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204