Feature: Check invoice approve flow if lockTotal is specified

  Background:
    * url baseUrl
    # uncomment below line for development
   #* callonce dev {tenant: 'testinvoices1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    # initialize common invoice data
     * def invoiceId = callonce uuid7
     * def invoiceLineId = callonce uuid8

#   * def invoiceId = "34ead894-57a0-4276-8802-87fc7851f935"
#   * def invoiceLineId = "34ead894-57a0-4276-8801-87fc7851f535"
   * configure retry = { count: 2, interval: 2000 }

  Scenario: Create invoice with lockTotal and without adjustment
    * set invoicePayload.id = invoiceId
    * set invoicePayload.lockTotal = 12.34
    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 0.0
    And match $.lockTotal == 12.34
    And match $.subTotal == 0.0
    And match $.total == 0.0

  Scenario: Add invoice line to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = invoiceLineId
    * set invoiceLinePayload.invoiceId = invoiceId
    * set invoiceLinePayload.quantity = 1
    * set invoiceLinePayload.subTotal = 10.02
    * set invoiceLinePayload.total = 10.02
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId

    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 10.02
    And match $.total == 10.02

  # ============= approve invoice ===================
  Scenario: Approve invoice with lock total is not equal to calculated total
  Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 400
    And match $.errors[0].code == 'lockCalculatedTotalsMismatch'

  Scenario: Verify invoice totals are not updated and invoice stay in Open status
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == "Open"
    And match $.lockTotal == 12.34
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 10.02
    And match $.total == 10.02

    # ============= approve invoice ===================
  Scenario: Approve invoice with lock total is equal to calculated total
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.lockTotal = 10.02
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204


  Scenario: Verify get invoice by id - invoice totals are not updated and invoice move to Approved status
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And retry until $.subTotal == 10.02
    And match $.status == "Approved"
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 10.02
    And match $.lockTotal == 10.02
    And match $.total == 10.02

  Scenario: Verify invoice totals are updated - by query
    Given path 'invoice/invoices'
    And param query = 'id==' + invoiceId
    When method GET
    Then status 200
    And match $.invoices[0].status == "Approved"
    And match $.invoices[0].adjustmentsTotal == 0.0
    And match $.invoices[0].subTotal == 10.02
    And match $.invoices[0].lockTotal == 10.02
    And match $.invoices[0].total == 10.02


      # ============= Verify voucher lines ===================
  Scenario: Verify voucher lines after invoice approve
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def voucherLine = $.voucherLines[0]
    * def fundDistributions = voucherLine.fundDistributions[0]
    And match $.voucherLines == '#[1]'
    And match voucherLine.fundDistributions == '#[1]'
    And match voucherLine.voucherId == voucher.id
    And match ([fundDistributions.fundId]) contains any ['#(globalFundId)']
    And match ([fundDistributions.invoiceLineId]) contains any [ '#(invoiceLineId)']
