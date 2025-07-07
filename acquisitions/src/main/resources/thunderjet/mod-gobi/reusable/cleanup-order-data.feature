Feature: Cleanup Order Data
  # parameters: orderId

  Background:
    * url baseUrl

  Scenario: cleanupOrderData
    * configure headers = headersAdmin
    * def v = call deleteOrder { orderId: "#(orderId)" }
    * configure headers = {}
