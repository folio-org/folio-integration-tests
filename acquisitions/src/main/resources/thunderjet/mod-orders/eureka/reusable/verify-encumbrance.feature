@ignore
Feature: Collection of different verifcation of encumbrance transaction

  Background:
    * url baseUrl

  @ignore @VerifyEncumbranceTransactionStatus
  Scenario: Verify encumbrnace transaction status
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + _orderId
    When method GET
    Then status 200
    * match $.transactions[*].transactionType contains 'Encumbrance'
    * match $.transactions[*].encumbrance.status contains _encumbranceStatus
    * match $.transactions[*].encumbrance.orderStatus contains _orderStatus
