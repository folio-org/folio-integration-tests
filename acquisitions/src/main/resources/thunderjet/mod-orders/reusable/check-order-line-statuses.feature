@ignore
Feature: Check order line statuses
  # parameters: id, orderType, paymentStatus, receiptStatus

  Background:
    * url baseUrl

  Scenario: checkOrderLineStatuses
    Given path 'orders/order-lines', id
    When method GET
    Then status 200
    * def paymentStatus = orderType == 'One-Time' ? 'Fully Paid' : 'Ongoing'
    * def receiptStatus = orderType == 'One-Time' ? 'Awaiting Receipt' : 'Ongoing'
    And match $.paymentStatus == paymentStatus
    And match $.receiptStatus == receiptStatus