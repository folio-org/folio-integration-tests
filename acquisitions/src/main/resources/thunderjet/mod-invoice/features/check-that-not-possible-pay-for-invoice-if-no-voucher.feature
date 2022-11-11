Feature: Checking that it is impossible to pay for the invoice if no voucher for invoice

  Background:
    * url baseUrl
    # uncomment below line for development
   #* callonce dev {tenant: 'testinvoices1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    # initialize common invoice data
     * def invoiceId = callonce uuid1
     * def invoiceLineId = callonce uuid2

#    * def invoiceId = "34ead894-57a0-4276-8802-87fc7851f715"
#    * def invoiceLineId = "34ead894-57a0-4276-8801-87fc7851f745"

  Scenario: Create invoice with lockTotal and without adjustment
    * set invoicePayload.id = invoiceId
    * set invoicePayload.lockTotal = 10.02
    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And headers headersUser
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 0.0
    And match $.lockTotal == 10.02
    And match $.subTotal == 0.0
    And match $.total == 0.0

  Scenario: Add invoice line to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And headers headersUser
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

  Scenario: Approve invoice with lock total which equal to calculated total
  Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    And request invoicePayload
    When method PUT
    Then status 204

  Scenario: Delete voucher with voucher lines after invoice approve
    Given path '/voucher/vouchers'
    And headers headersUser
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    * def voucherId = $.vouchers[0].id

    Given path '/voucher/voucher-lines'
    And headers headersUser
    And param limit = '1000'
    And param query = 'voucherId==' + voucherId
    When method GET
    Then status 200
    * def voucherLineId = $.voucherLines[0].id

    Given path '/voucher-storage/voucher-lines', voucherLineId
    And headers headersAdmin
    When method DELETE
    Then status 204

    Given path '/voucher-storage/vouchers', voucherId
    And headers headersAdmin
    When method DELETE
    Then status 204
    
  Scenario: Pay for the invoice without voucher
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'

    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    And request invoicePayload
    When method PUT
    Then status 404
    And match $.errors[0].code == 'voucherNotFound'
