@ignore
Feature: Check Invoices and Invoice Lines with VAT

  Background:
    * url baseUrl

  @CheckInvoicesWithAppliedTopAdjustment
  Scenario: Check invoices with applied top adjustment
    # parameters: id, status, total, subTotal, adjustmentsTotal, adjustmentId
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

  @CheckInvoicesWithNoAppliedTopAdjustment
  Scenario: Check invoices with no applied top adjustment
    # parameters: id, status, total, subTotal, adjustmentsTotal
    Given path 'invoice/invoices', id
    When method GET
    Then status 200
    And match response.currency == 'EUR'
    And match response.status == status
    And match response.total == total
    And match response.subTotal == subTotal
    And match response.adjustmentsTotal == adjustmentsTotal
    And match response.adjustments == '#[0]'

  @CheckInvoiceLinesWithAppliedTopAdjustment
  Scenario: Check invoice line with applied top adjustment
    # parameters: id, invoiceLines, lineTotal, lineSubTotals, lineAdjustments, status, adjustmentId
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

  @CheckInvoiceLinesWithAppliedIndividualAdjustment
  Scenario: Check invoice line with applied individual adjustment
    # parameters: id, invoiceLines, lineTotal, lineSubTotals, lineAdjustments, status
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