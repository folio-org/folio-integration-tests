@ignore
Feature: Validate composite orders
  # parameters: id, workflowStatus, titleOrPackage, paymentStatus, receiptStatus

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Validate composite orders
    Given path 'orders/composite-orders', id
    When method GET
    Then status 200
    And match $.workflowStatus == workflowStatus
    And match each $.poLines[*].titleOrPackage == titleOrPackage
    And match each $.poLines[*].paymentStatus == paymentStatus
    And match each $.poLines[*].receiptStatus == receiptStatus