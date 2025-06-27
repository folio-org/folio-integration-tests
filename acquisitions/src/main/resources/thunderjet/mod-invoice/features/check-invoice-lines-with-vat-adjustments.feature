# For MODINVOICE-576
Feature: Check invoice lines with VAT adjustments

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def checkInvoicesWithAppliedTopAdjustment = read('classpath:thunderjet/mod-invoice/reusable/check-invoices-and-invoice-lines-vat.feature@CheckInvoicesWithAppliedTopAdjustment')
    * def checkInvoicesWithNoAppliedTopAdjustment = read('classpath:thunderjet/mod-invoice/reusable/check-invoices-and-invoice-lines-vat.feature@CheckInvoicesWithNoAppliedTopAdjustment')
    * def checkInvoiceLinesWithAppliedTopAdjustment = read('classpath:thunderjet/mod-invoice/reusable/check-invoices-and-invoice-lines-vat.feature@CheckInvoiceLinesWithAppliedTopAdjustment')
    * def checkInvoiceLinesWithAppliedIndividualAdjustment = read('classpath:thunderjet/mod-invoice/reusable/check-invoices-and-invoice-lines-vat.feature@CheckInvoiceLinesWithAppliedIndividualAdjustment')

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

    ### 2. Create invoices
    * configure headers = headersUser
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

    ### 3. Create invoice lines
    * table invoiceLines
      | invoiceLineId  | invoiceId  | total | fundId |
      | invoiceLineId1 | invoiceId1 | 30.0  | fundId |
      | invoiceLineId2 | invoiceId2 | 30.0  | fundId |
      | invoiceLineId3 | invoiceId2 | 30.0  | fundId |
      | invoiceLineId4 | invoiceId2 | 30.0  | fundId |
    * def v = call createInvoiceLine invoiceLines

    ### 4. Check invoices and invoice lines before approval
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotals | lineAdjustments | lineTotal | status |
      | invoiceId1 | 1.96             | 28.04    | 30.0  | 1            | 28.04         | 1.96            | 30.0      | 'Open' |
      | invoiceId2 | 5.88             | 84.12    | 90.0  | 3            | 28.04         | 1.96            | 30.0      | 'Open' |
    * def v = call checkInvoicesWithAppliedTopAdjustment invoicesExpected
    * def v = call checkInvoiceLinesWithAppliedTopAdjustment invoicesExpected

    ### 5. Remove a single invoice line from the second invoice
    Given path 'invoice/invoice-lines', invoiceLineId4
    When method DELETE
    Then status 204

    ### 6. Recheck invoices and invoice lines to verify that the adjustment calculation was unaffected
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotals | lineAdjustments | lineTotal | status |
      | invoiceId1 | 1.96             | 28.04    | 30.0  | 1            | 28.04         | 1.96            | 30.0      | 'Open' |
      | invoiceId2 | 3.92             | 56.08    | 60.0  | 2            | 28.04         | 1.96            | 30.0      | 'Open' |
    * def v = call checkInvoicesWithAppliedTopAdjustment invoicesExpected
    * def v = call checkInvoiceLinesWithAppliedTopAdjustment invoicesExpected

    ### 7. Approve the invoices
    * def v = call approveInvoice invoices

    ### 8. Check invoices and invoice lines after approval
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotals | lineAdjustments | lineTotal | status     |
      | invoiceId1 | 1.96             | 28.04    | 30    | 1            | 28.04         | 1.96            | 30.0      | 'Approved' |
      | invoiceId2 | 3.92             | 56.08    | 60    | 2            | 28.04         | 1.96            | 30.0      | 'Approved' |
    * def v = call checkInvoicesWithAppliedTopAdjustment invoicesExpected
    * def v = call checkInvoiceLinesWithAppliedTopAdjustment invoicesExpected

  @Positive
  Scenario: Check invoice lines with VAT adjustments added to the Invoice Line directly
    # Check that each invoice line VAT calculation is unaffected by other invoice lines
    # as other forms of adjustments typically involve every invoice line in its adjustment calculation
    * def fundId = call uuid
    * def budgetId = call uuid

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

    ### 2. Create invoices
    * configure headers = headersUser
    * table invoices
      | id         | invoiceId  | currency |
      | invoiceId1 | invoiceId1 | 'EUR'    |
      | invoiceId2 | invoiceId2 | 'EUR'    |
    * def v = call createInvoice invoices

    ### 3. Create invoice lines
    * def invoiceLineAdjustments =
      """
      [{
        "value": 7.0,
        "type": "Percentage",
        "prorate": "By amount",
        "description": "VAT",
        "relationToTotal": "Included in",
        "fundDistributions": [],
        "exportToAccounting": false
      }]
      """
    * table invoiceLines
      | invoiceLineId  | invoiceId  | total | fundId | adjustments            |
      | invoiceLineId1 | invoiceId1 | 30.0  | fundId | invoiceLineAdjustments |
      | invoiceLineId2 | invoiceId2 | 30.0  | fundId | invoiceLineAdjustments |
      | invoiceLineId3 | invoiceId2 | 30.0  | fundId | invoiceLineAdjustments |
      | invoiceLineId4 | invoiceId2 | 30.0  | fundId | null                   |
    * def v = call createInvoiceLine invoiceLines

    ### 4. Check invoices and invoice lines before approval
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotals       | lineAdjustments | lineTotal | status |
      | invoiceId1 | 1.96             | 28.04    | 30.0  | 1            | [28.04]             | [1.96]          | 30.0      | 'Open' |
      | invoiceId2 | 3.92             | 86.08    | 90.0  | 3            | [28.04,28.04,30.0]  | [1.96,1.96,0.0] | 30.0      | 'Open' |
    * def v = call checkInvoicesWithNoAppliedTopAdjustment invoicesExpected
    * def v = call checkInvoiceLinesWithAppliedIndividualAdjustment invoicesExpected

    ### 5. Remove a single invoice line from the second invoice
    Given path 'invoice/invoice-lines', invoiceLineId3
    When method DELETE
    Then status 204

    ### 6. Recheck invoices and invoice lines to verify that the adjustment calculation was unaffected
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotals  | lineAdjustments | lineTotal | status |
      | invoiceId1 | 1.96             | 28.04    | 30.0  | 1            | [28.04]        | [1.96]          | 30.0      | 'Open' |
      | invoiceId2 | 1.96             | 58.04    | 60.0  | 2            | [28.04,30.0]   | [1.96,0.0]      | 30.0      | 'Open' |
    * def v = call checkInvoicesWithNoAppliedTopAdjustment invoicesExpected
    * def v = call checkInvoiceLinesWithAppliedIndividualAdjustment invoicesExpected

    ### 7. Approve the invoices
    * def v = call approveInvoice invoices

    ### 8. Check invoices and invoice lines after approval
    * table invoicesExpected
      | id         | adjustmentsTotal | subTotal | total | invoiceLines | lineSubTotals  | lineAdjustments | lineTotal | status     |
      | invoiceId1 | 1.96             | 28.04    | 30    | 1            | [28.04]        | [1.96]          | 30.0      | 'Approved' |
      | invoiceId2 | 1.96             | 58.04    | 60    | 2            | [28.04,30.0]   | [1.96,0.0]      | 30.0      | 'Approved' |
    * def v = call checkInvoicesWithNoAppliedTopAdjustment invoicesExpected
    * def v = call checkInvoiceLinesWithAppliedIndividualAdjustment invoicesExpected
