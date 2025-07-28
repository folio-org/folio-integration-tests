@ignore
Feature: Unopen order
  # parameters: orderId

  Background:
    * url baseUrl

  Scenario: unopenOrder
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Pending'
    * remove order.poLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204