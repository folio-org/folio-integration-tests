@ignore
Feature: Validate po lines

  Background:
    * url baseUrl

  @ignore @VerifyPoLineReceiptStatus
  Scenario: Verify PoLine receipt status
    Given path 'orders/order-lines', _poLineId
    And retry until response.receiptStatus == _receiptStatus
    When method GET
    Then status 200
