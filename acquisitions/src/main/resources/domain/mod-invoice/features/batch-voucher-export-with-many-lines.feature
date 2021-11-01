# For https://issues.folio.org/browse/MODINVOICE-312
@parallel=false
Feature: Batch voucher export with many lines

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def batchGroupId = callonce uuid1
    * def invoiceId = callonce uuid2


  Scenario: Create a batch group
    * def bg = { id: "#(batchGroupId)", name: "test batch group" }
    Given path 'batch-groups'
    And request bg
    When method POST
    Then status 201


  Scenario: Create an invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    * set invoice.exportToAccounting = true
    * set invoice.batchGroupId = batchGroupId

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201


  Scenario Outline: Create <description> with a new fund
    * def fundId = call uuid
    * def budgetId = call uuid
    * def externalAccountNo = call uuid
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', externalAccountNo: '#(externalAccountNo)' }
    * call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }
    * configure headers = headersUser

    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = call uuid
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.description = '<description>'
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * remove invoiceLine.fundDistributions[0].expenseClassId

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    Examples:
      | description |
      | line 1      |
      | line 2      |
      | line 3      |
      | line 4      |
      | line 5      |
      | line 6      |
      | line 7      |
      | line 8      |
      | line 9      |
      | line 10     |
      | line 11     |
      | line 12     |
      | line 13     |
      | line 14     |
      | line 15     |
      | line 16     |


  Scenario: Approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


  Scenario: Create the batch voucher and check the number of lines
    Given path 'batch-voucher/batch-voucher-exports'
    And request
    """
    {
      status: "Pending",
      batchGroupId: "#(batchGroupId)",
      start: "2020-03-01T00:00:00.000+0000",
      end: "2099-01-01T00:00:00.000+0000"
    }
    """
    When method POST
    Then status 201
    * def batchVoucherExportId = $.id

    * call pause 1000

    Given path 'batch-voucher/batch-voucher-exports', batchVoucherExportId
    When method GET
    Then status 200
    * def batchVoucherId = $.batchVoucherId

    Given path 'batch-voucher/batch-vouchers', batchVoucherId
    When method GET
    Then status 200
    And match $.batchedVouchers[0].batchedVoucherLines == '#[16]'
