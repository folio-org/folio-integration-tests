@ignore
Feature: Collection of different verification of encumbrance transaction

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  @ignore @VerifyEncumbranceTransactionStatus
  Scenario: Verify encumbrance transaction status
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + _orderId
    When method GET
    Then status 200
    * match $.transactions[*].transactionType contains 'Encumbrance'
    * match $.transactions[*].encumbrance.status contains _encumbranceStatus
    * match $.transactions[*].encumbrance.orderStatus contains _orderStatus
