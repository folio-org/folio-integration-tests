# For MODINVOICE-312
@parallel=false
Feature: Batch voucher export with many lines

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

    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')

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
    * def invoiceLineId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def externalAccountNo = call uuid

    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', externalAccountNo: '#(externalAccountNo)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

    * configure headers = headersUser
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: 100, description: '#(<description>)' }

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
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }


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
