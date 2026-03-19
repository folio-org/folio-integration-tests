@ignore
Feature: Unopen order
  # parameters: orderId

  Background:
    * url baseUrl

  Scenario: unopenOrderDeleteHoldings
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Pending'
    * remove order.poLines

    Given path 'orders/composite-orders', orderId
    And param deleteHoldings = true
    And request order
    When method PUT
    Then status 204