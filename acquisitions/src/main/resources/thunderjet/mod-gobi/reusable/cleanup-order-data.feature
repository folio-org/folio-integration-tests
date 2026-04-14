Feature: Cleanup Order Data
  # parameters: orderId

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Cleanup Order Data
    * configure headers = headersAdmin
    * def v = call deleteOrder { orderId: "#(orderId)" }
    * configure headers = {}
