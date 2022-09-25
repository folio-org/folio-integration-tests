Feature: Check invoice full flow where sub total is negative

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
    * def invoiceLineId1 = callonce uuid8
    * def invoiceLineId2 = callonce uuid9
    * def invoiceLineId3 = callonce uuid10
    * def invoiceLineId4 = callonce uuid11

#   * def invoiceId = "34ead894-57a0-4276-8802-87fc7851f975"
#   * def invoiceLineId1 = "34ead894-57a0-4276-8801-87fc7851f581"
#   * def invoiceLineId2 = "34ead894-57a0-4276-8801-87fc7851f582"
#   * def invoiceLineId3 = "34ead894-57a0-4276-8801-87fc7851f583"
#   * def invoiceLineId4 = "34ead894-57a0-4276-8801-87fc7851f584"

  Scenario: Create invoice without adjustment
    * set invoicePayload.id = invoiceId
    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 0.0
    And match $.total == 0.0

  Scenario Outline: Add invoice line <invoiceLineId> to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = <invoiceLineId>
    * set invoiceLinePayload.invoiceId = invoiceId
    * set invoiceLinePayload.quantity = <quantity>
    * set invoiceLinePayload.subTotal = <subTotal>
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId

    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == <subTotal>
    And match $.total == <subTotal>
  Examples:
    |invoiceLineId |subTotal| quantity|
    |invoiceLineId1| 12.04  |   1     |
    |invoiceLineId2| 12.04  |   1     |
    |invoiceLineId3| -10.02 |   1     |
    |invoiceLineId4| -10.02 |   1     |

    # ============= approve invoice ===================
  Scenario: Approve created invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204


  Scenario: Verify get invoice by id - invoice totals are calculated invoice and move to Approved status
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == "Approved"
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 4.04
    And match $.total == 4.04

  Scenario: Verify get invoice by query - invoice totals are calculated
    Given path 'invoice/invoices'
    And param query = 'id==' + invoiceId
    When method GET
    Then status 200
    And match $.invoices[0].status == "Approved"
    And match $.invoices[0].adjustmentsTotal == 0.0
    And match $.invoices[0].subTotal == 4.04
    And match $.invoices[0].total == 4.04

      # ============= Verify voucher lines ===================
  Scenario: Verify voucher lines after invoice approve
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]
    And match voucher.status == "Awaiting payment"

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def voucherLine = $.voucherLines[0]
    And match $.voucherLines == '#[1]'
    And match voucherLine.fundDistributions == '#[4]'
    And match voucherLine.voucherId == voucher.id
    And match ([voucherLine.fundDistributions[0,1,2,3].fundId]) contains any ['#(globalFundId)']
    And match (voucherLine.sourceIds) contains any [ '#(invoiceLineId1, invoiceLineId2, invoiceLineId3, invoiceLineId4)']

  Scenario: Pay for the invoice without voucher
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

  Scenario: Verify payed invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == 'Paid'

  Scenario: Check that payments transactions were created only for positive amounts
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceId==' + invoiceId + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == '#[2]'

  Scenario: Check that credit transactions were created only for negative amounts
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceId==' + invoiceId + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == '#[2]'
