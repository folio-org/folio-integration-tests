@ignore
Feature: Helper for "rollover-and-pay-invoice-using-past-fiscal-year.feature"

  Background:
    * url baseUrl

  @CheckOrderLineStatuses #(id, orderType, paymentStatus, receiptStatus)
  Scenario: checkOrderLineStatuses
    Given path 'orders/order-lines', id
    When method GET
    Then status 200
    * def paymentStatus = orderType == 'One-Time' ? 'Fully Paid' : 'Ongoing'
    * def receiptStatus = orderType == 'One-Time' ? 'Awaiting Receipt' : 'Ongoing'
    And match $.paymentStatus == paymentStatus
    And match $.receiptStatus == receiptStatus

  @VerifyEncumbranceTransactionsInNewYear #(fiscalYearId, reEncumber, totalRecords, amount, status)
  Scenario: verifyEncumbranceTransactionsInNewYear
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

  @VerifyPendingPaymentsWereCreatedInPastFiscalYear #(fiscalYearId, invoiceLineId)
  Scenario: verifyPendingPaymentsWereCreatedInPastFiscalYear
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' And transactionType==Pending payment'
    When method GET
    Then status 200
    And match each $.transactions[*].fiscalYearId == fiscalYearId