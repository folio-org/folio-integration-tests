Feature: Delete order
  # parameters: orderId

  Background:
    * url baseUrl

  Scenario: deleteOrder
    Given path '/orders/composite-orders', orderId
    When method DELETE
    Then status 204
