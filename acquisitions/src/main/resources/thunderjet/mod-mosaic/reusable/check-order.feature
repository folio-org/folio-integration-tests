@ignore
Feature: Check order
  # parameters: poNumber, orderTemplateId, workflowStatus?

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Check order
    Given path "orders/composite-orders"
    And param query = "poNumber==" + poNumber
    When method GET
    Then status 200
    And match $.purchaseOrders == "#[1]"
    And match each $.purchaseOrders[*].template == orderTemplateId
    And match each $.purchaseOrders[*].workflowStatus == karate.get("workflowStatus", "Pending")