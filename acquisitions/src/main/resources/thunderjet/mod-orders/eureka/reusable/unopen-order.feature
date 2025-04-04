@ignore
Feature: Unopen order
  # parameters: orderId

  Background:
    * url baseUrl

  Scenario: Unopen order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Pending'
    * remove order.compositePoLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204
