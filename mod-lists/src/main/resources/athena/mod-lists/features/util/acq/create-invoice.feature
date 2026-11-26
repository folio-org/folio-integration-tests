Feature: Create open invoice in storage
  # parameters: id, vendorId, vendorInvoiceNo, fiscalYearId, batchGroupId, poNumbers
  Background:
    * url baseUrl

  Scenario: Create open invoice
    * def invoice =
      """
      {
        id: '#(id)',
        vendorId: '#(vendorId)',
        vendorInvoiceNo: '#(vendorInvoiceNo)',
        fiscalYearId: '#(fiscalYearId)',
        batchGroupId: '#(batchGroupId)',
        poNumbers: '#(poNumbers)',
        invoiceDate: '2020-01-01T00:00:00.000+0000',
        status: 'Open',
        currency: 'USD',
        paymentMethod: 'EFT',
        source: 'User'
      }
      """
    Given path 'invoice-storage/invoices'
    And request invoice
    When method POST
    Then status 201
