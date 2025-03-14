# For MODINVOICE-576
Feature: Check invoice lines with VAT adjustments

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

  @Positive
  Scenario: Check invoice lines with VAT adjustments
    # Check that each invoice line VAT calculation is unaffected by other invoice lines
    # as other forms of adjustments typically involve every invoice line in its adjustment calculation
    * def fundId = call uuid
    * def budgetId = call uuid

    * def adjustmentId = call uuid
    * def invoiceId1 = call uuid
    * def invoiceId2 = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def invoiceLineId4 = call uuid

    ### 1. Create fund and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }
    * configure headers = headersUser

    ### 4. Create invoices
    * def invoiceAdjustments =
      """
      [{
        "id": "#(adjustmentId)",
        "value": 7.0,
        "type": "Percentage",
        "prorate": "By amount",
        "description": "VAT",
        "relationToTotal": "Included in",
        "fundDistributions": [],
        "exportToAccounting": false
      }]
      """
    * table invoices
      | id         | invoiceId  | currency | adjustments        |
      | invoiceId1 | invoiceId1 | 'EUR'    | invoiceAdjustments |
      | invoiceId2 | invoiceId2 | 'EUR'    | invoiceAdjustments |
    * def v = call createInvoice invoices

    ### 5. Add invoice lines
    * table invoiceLines
      | invoiceLineId  | invoiceId  | total | fundId |
      | invoiceLineId1 | invoiceId1 | 30.0  | fundId |
      | invoiceLineId2 | invoiceId2 | 30.0  | fundId |
      | invoiceLineId3 | invoiceId2 | 30.0  | fundId |
      | invoiceLineId4 | invoiceId2 | 30.0  | fundId |
    * def v = call createInvoiceLine invoiceLines

    ### 6. Check invoices and invoice lines before approval
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotal | lineAdjustments | lineTotal | status |
      | invoiceId1 | 1.96             | 28.04    | 30.0  | 1            | 28.04        | 1.96            | 30.0      | 'Open' |
      | invoiceId2 | 5.88             | 84.12    | 90.0  | 3            | 28.04        | 1.96            | 30.0      | 'Open' |
    * def v = call read('@CheckInvoices') invoicesExpected
    * def v = call read('@CheckInvoiceLines') invoicesExpected

    ### 7. Remove a single invoice line from the second invoice
    Given path 'invoice/invoice-lines', invoiceLineId4
    When method DELETE
    Then status 204

    ### 8. Recheck invoices and invoice lines to verify that the adjustment calculation was unaffected
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotal | lineAdjustments | lineTotal | status |
      | invoiceId1 | 1.96             | 28.04    | 30.0  | 1            | 28.04        | 1.96            | 30.0      | 'Open' |
      | invoiceId2 | 3.92             | 56.08    | 60.0  | 2            | 28.04        | 1.96            | 30.0      | 'Open' |
    * def v = call read('@CheckInvoices') invoicesExpected
    * def v = call read('@CheckInvoiceLines') invoicesExpected

    ### 9. Approve the invoices
    * def v = call approveInvoice invoices

    ### 10. Check invoices and invoice lines after approval
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotal | lineAdjustments | lineTotal | status     |
      | invoiceId1 | 1.96             | 28.04    | 30    | 1            | 28.04        | 1.96            | 30.0      | 'Approved' |
      | invoiceId2 | 3.92             | 56.08    | 60    | 2            | 28.04        | 1.96            | 30.0      | 'Approved' |
    * def v = call read('@CheckInvoices') invoicesExpected
    * def v = call read('@CheckInvoiceLines') invoicesExpected

  @ignore @CheckInvoices
  Scenario: Check invoices
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

  @ignore @CheckInvoiceLines
  Scenario: Check invoice line
    Given path 'invoice/invoice-lines'
    And param query = 'invoiceId==' + id
    When method GET
    Then status 200
    And match response.totalRecords == invoiceLines
    And match each response.invoiceLines[*].quantity == 1
    And match each response.invoiceLines[*].total == lineTotal
    And match each response.invoiceLines[*].subTotal == lineSubTotal
    And match each response.invoiceLines[*].adjustmentsTotal == lineAdjustments
    And match each response.invoiceLines[*].invoiceLineStatus == status
    And match each response.invoiceLines[*].adjustments[*].adjustmentId == adjustmentId
    And match each response.invoiceLines[*].adjustments[*].value == lineAdjustments
    And match each response.invoiceLines[*].adjustments[*].type == 'Amount'
    And match each response.invoiceLines[*].adjustments[*].prorate == 'Not prorated'
    And match each response.invoiceLines[*].adjustments[*].description == 'VAT'
    And match each response.invoiceLines[*].adjustments[*].relationToTotal == 'Included in'
