Feature: Check vendor address included with batch voucher

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testinvoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    # initialize common invoice data
    * def vendorId = callonce uuid1
    * def invoiceId = callonce uuid2
    * def invoiceLineId = callonce uuid3

    * def yesterday = callonce getYesterday
    * def today = callonce getCurrentDate

    * configure retry = { count: 10, interval: 1000 }

  Scenario: Create an invoice, check vendor address included in the batch voucher
    # ============= create an organization with an address =============
    Given path 'organizations-storage/organizations'
    And headers headersAdmin
    And request
    """
    {
      id: '#(vendorId)',
      name: 'MSU Libraries',
      code: 'MSUL',
      isVendor: true,
      status: 'Active',
      addresses: [
        {
          isPrimary: true,
          addressLine1: "MSU Libraries",
          addressLine2: "366 W. Circle Drive",
          city: "East Lansing",
          stateRegion: "MI",
          zipCode: "48824",
          country: "USA",
          language: "en"
        }
      ]
    }
    """
    When method POST
    Then status 201

    # ============= create the invoice ===================
    * set invoicePayload.id = invoiceId
    * set invoicePayload.vendorId = vendorId
    * set invoicePayload.exportToAccounting = true

    Given path 'invoice/invoices'
    And headers headersUser
    And request invoicePayload
    When method POST
    Then status 201

    # ============= create the invoice line ===================
    * set invoiceLinePayload.id = invoiceLineId
    * set invoiceLinePayload.invoiceId = invoiceId
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId

    Given path 'invoice/invoice-lines'
    And headers headersUser
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= get invoice to approve ===================
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"

    # ============= put approved invoice ===================
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    And request invoiceBody
    When method PUT
    Then status 204

    # ============= create batch export configuration ===================
    Given path 'batch-voucher/export-configurations'
    And headers headersUser
    And request
    """
    {
      "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
      "format": "Application/json",
      "uploadURI": "#(ftpUrl)",
      "uploadDirectory": "/files/invoices",
      "ftpFormat": "FTP",
      "ftpPort": "#(ftpPort)"
    }
    """
    When method POST
    Then status 201
    * def batchVoucherExportConfigurationId = $.id


    # ============= create batch export ftp credentials ===================
    Given path 'batch-voucher/export-configurations', batchVoucherExportConfigurationId, 'credentials'
    And headers headersUser
    And request
    """
    {
      "username": "#(ftpUser)",
      "password": "#(ftpPassword)",
      "exportConfigId": "#(batchVoucherExportConfigurationId)",
    }
    """
    When method POST
    Then status 201

    # ============= create batch voucher ===================
    Given path 'batch-voucher/batch-voucher-exports'
    And headers headersUser
    And request
    """
    {
      status: "Pending",
      batchGroupId: "#(globalBatchGroupId)",
      start: "#(yesterday + \"T00:00:01Z\")",
      end: "#(today + \"T23:59:59Z\")"
    }
    """
    When method POST
    Then status 201
    * def batchVoucherExportId = $.id

    # ============= get export later to give it time to create the batch voucher ===================
    Given path 'batch-voucher/batch-voucher-exports', batchVoucherExportId
    And headers headersUser
    And retry until response.status == 'Uploaded'
    When method GET
    Then status 200
    * def batchVoucherId = $.batchVoucherId

    # ============= get batch voucher and check address ===================
    * def expectedAddress = { addressLine1: 'MSU Libraries', addressLine2: '366 W. Circle Drive', city: 'East Lansing', stateRegion: 'MI', zipCode: '48824', country: 'USA'}
    Given path 'batch-voucher/batch-vouchers', batchVoucherId
    And headers headersUser
    When method GET
    Then status 200
    And match $.batchedVouchers[0].vendorName == 'MSU Libraries'
    And match $.batchedVouchers[0].vendorAddress == expectedAddress

    # ============= get it again in XML ===================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/xml'  }
    Given path 'batch-voucher/batch-vouchers', batchVoucherId
    And headers headersUser
    When method GET
    Then status 200
    * def batchedVoucher = $.batchVoucher.batchedVouchers.batchedVoucher
    And match batchedVoucher.vendorName == 'MSU Libraries'
    And match batchedVoucher.vendorAddress == expectedAddress
