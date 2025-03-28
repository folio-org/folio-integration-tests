@ignore
Feature: Validate composite orders
  # parameters: id, workflowStatus, titleOrPackage, paymentStatus, receiptStatus

  Background:
    * url baseUrl

  Scenario: validateCompositeOrders
    Given path 'orders/composite-orders', id
    When method GET
    Then status 200
    And match $.workflowStatus == workflowStatus
    And match each $.compositePoLines[*].titleOrPackage == titleOrPackage
    And match each $.compositePoLines[*].paymentStatus == paymentStatus
    And match each $.compositePoLines[*].receiptStatus == receiptStatus