@ignore
Feature: Helper for "check-invoice-lines-with-vat-adjustments.feature"

  Background:
    * url baseUrl

  @CheckInvoicesWithAppliedTopAdjustment #(id, status, total, subTotal, adjustmentsTotal, adjustmentId)
  Scenario: Check invoices with applied top adjustment
    Given path 'invoice/invoices', id
    When method GET
    Then status 200
    And match response.currency == 'EUR'
    And match response.status == status
    And match response.total == total
    And match response.subTotal == subTotal
    And match response.adjustmentsTotal == adjustmentsTotal
    And match each response.adjustments[*].id == adjustmentId
    And match each response.adjustments[*].value == 7.0
    And match each response.adjustments[*].type == 'Amount'
    And match each response.adjustments[*].prorate == 'By amount'
    And match each response.adjustments[*].description == 'VAT'
    And match each response.adjustments[*].relationToTotal == 'Included in'

  @CheckInvoicesWithNoAppliedTopAdjustment #(id, status, total, subTotal, adjustmentsTotal)
  Scenario: Check invoices with no applied top adjustment
    Given path 'invoice/invoices', id
    When method GET
    Then status 200
    And match response.currency == 'EUR'
    And match response.status == status
    And match response.total == total
    And match response.subTotal == subTotal
    And match response.adjustmentsTotal == adjustmentsTotal
    And match response.adjustments == '#[0]'

  @CheckInvoiceLinesWithAppliedTopAdjustment #(id, invoiceLines, lineTotal, lineSubTotals, lineAdjustments, status, adjustmentId)
  Scenario: Check invoice line with applied top adjustment
    Given path 'invoice/invoice-lines'
    And param query = 'invoiceId==' + id
    When method GET
    Then status 200
    And match response.totalRecords == invoiceLines
    And match each response.invoiceLines[*].quantity == 1
    And match each response.invoiceLines[*].total == lineTotal
    And match each response.invoiceLines[*].subTotal == lineSubTotals
    And match each response.invoiceLines[*].adjustmentsTotal == lineAdjustments
    And match each response.invoiceLines[*].invoiceLineStatus == status
    And match each response.invoiceLines[*].adjustments[*].adjustmentId == adjustmentId
    And match each response.invoiceLines[*].adjustments[*].value == lineAdjustments
    And match each response.invoiceLines[*].adjustments[*].type == 'Amount'
    And match each response.invoiceLines[*].adjustments[*].prorate == 'Not prorated'
    And match each response.invoiceLines[*].adjustments[*].description == 'VAT'
    And match each response.invoiceLines[*].adjustments[*].relationToTotal == 'Included in'

  @CheckInvoiceLinesWithAppliedIndividualAdjustment #(id, invoiceLines, lineTotal, lineSubTotals, lineAdjustments, status)
  Scenario: Check invoice line with applied individual adjustment
    Given path 'invoice/invoice-lines'
    And param query = 'invoiceId==' + id
    When method GET
    Then status 200
    And match response.totalRecords == invoiceLines
    And match each response.invoiceLines[*].quantity == 1
    And match each response.invoiceLines[*].total == lineTotal
    And match response.invoiceLines[*].subTotal contains any lineSubTotals
    And match response.invoiceLines[*].adjustmentsTotal contains any lineAdjustments
    And match each response.invoiceLines[*].invoiceLineStatus == status
    And match response.invoiceLines[*].adjustments[*].value contains any lineAdjustments
    And match each response.invoiceLines[*].adjustments[*].type == 'Amount'
    And match each response.invoiceLines[*].adjustments[*].prorate == 'Not prorated'
    And match each response.invoiceLines[*].adjustments[*].description == 'VAT'
    And match each response.invoiceLines[*].adjustments[*].relationToTotal == 'Included in'