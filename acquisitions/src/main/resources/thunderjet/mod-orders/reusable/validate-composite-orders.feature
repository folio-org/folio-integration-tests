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
    And match each $.poLines[*].titleOrPackage == titleOrPackage
    And match each $.poLines[*].paymentStatus == paymentStatus
    And match each $.poLines[*].receiptStatus == receiptStatus