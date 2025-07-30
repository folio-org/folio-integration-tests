@ignore
Feature: checkOrder
  # parameters: poNumber, orderTemplateId, workflowStatus?

  Background:
    * url baseUrl

  Scenario: checkOrder
    Given path "orders/composite-orders"
    And param query = "poNumber==" + poNumber
    When method GET
    Then status 200
    And match $.purchaseOrders == "#[1]"
    And match each $.purchaseOrders[*].template == orderTemplateId
    And match each $.purchaseOrders[*].workflowStatus == karate.get("workflowStatus", "Pending")