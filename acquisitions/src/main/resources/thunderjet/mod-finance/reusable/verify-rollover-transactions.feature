@ignore
Feature: Verify Rollover Transactions

  Background:
    * url baseUrl

  @VerifyEncumbranceTransactionsInNewYear
  Scenario: verifyEncumbranceTransactionsInNewYear
    # parameters: fiscalYearId, reEncumber, totalRecords, amount, status
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance And fiscalYearId==' + fiscalYearId + ' And encumbrance.reEncumber==' + reEncumber
    When method GET
    Then status 200
    And match $.totalRecords == totalRecords
    And match each $.transactions[*].amount == amount
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == status
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == amount

  @VerifyPendingPaymentsWereCreatedInPastFiscalYear
  Scenario: verifyPendingPaymentsWereCreatedInPastFiscalYear
    # parameters: fiscalYearId, invoiceLineId
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' And transactionType==Pending payment'
    When method GET
    Then status 200
    And match each $.transactions[*].fiscalYearId == fiscalYearId