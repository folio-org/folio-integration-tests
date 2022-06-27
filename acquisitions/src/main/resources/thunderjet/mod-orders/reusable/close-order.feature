Feature: Close order
  # parameters: orderId

  Background:
    * url baseUrl

  Scenario: Close order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Closed'
    * remove order.compositePoLines

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204
