Feature: Check approve and pay invoice with odd number of pennies in total

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
    * def invoiceId = callonce uuid7
    * def invoiceLineId1 = callonce uuid8
    * def invoiceLineId2 = callonce uuid9

    # initialize invoice line subtotals
    * def subTotal1 = 10.03
    * def subTotal2 = 10.01


  Scenario: Create invoice without adjustment
    * set invoicePayload.id = invoiceId
    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And headers headersUser
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 0.0
    And match $.total == 0.0

  Scenario Outline: Add invoice line <invoiceLineId> to created invoice with <subTotal> and <quantity>
     # ============= create invoice lines ===================
    * set invoiceLinePayload.id = <invoiceLineId>
    * set invoiceLinePayload.invoiceId = invoiceId
    * set invoiceLinePayload.quantity = <quantity>
    * set invoiceLinePayload.subTotal = <subTotal>
    * set invoiceLinePayload.fundDistributions =
    """
    [
      {
        "fundId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696",
        "distributionType": "percentage",
        "value": 50.0
      },
      {
        "fundId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698",
        "distributionType": "percentage",
        "value": 50.0
      }
    ]
    """
    Given path 'invoice/invoice-lines'
    And headers headersUser
    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == <subTotal>
    And match $.total == <subTotal>
    Examples:
      |invoiceLineId | subTotal   | quantity|
      |invoiceLineId1| subTotal1  |   1     |
      |invoiceLineId2| subTotal2  |   1     |


    # ============= approve invoice ===================
  Scenario: Approve created invoice
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

  Scenario: Check that pending payments created with correct amount of money
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    * def amount1 = $.transactions[0].amount
    * def amount2 = $.transactions[1].amount
    * def total = amount1 + amount2
    And assert total == subTotal1

  Scenario: Check that pending payments created with correct amount of money
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    * def amount1 = $.transactions[0].amount
    * def amount2 = $.transactions[1].amount
    * def total = amount1 + amount2
    And assert total == subTotal2

  Scenario: Verify get invoice by id - invoice totals are calculated invoice and move to Approved status
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    And match $.status == "Approved"
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == subTotal1 + subTotal2
    And match $.total == subTotal1 + subTotal2


  Scenario: Pay for the invoice
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
    Then status 204

  Scenario: Verify payed invoice
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    And match $.status == 'Paid'

  Scenario: Check that payments created with correct amount of money
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Payment'
    When method GET
    Then status 200
    * def amount1 = $.transactions[0].amount
    * def amount2 = $.transactions[1].amount
    * def total = amount1 + amount2
    And assert total == subTotal1


  Scenario: Check that payments created with correct amount of money
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Payment'
    When method GET
    Then status 200
    * def amount1 = $.transactions[0].amount
    * def amount2 = $.transactions[1].amount
    * def total = amount1 + amount2
    And assert total == subTotal2
