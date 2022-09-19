# Created for MODINVOICE-279
Feature: Check approve and pay invoice with 0$ amount

  Background:
    * url baseUrl
    #* callonce dev {tenant: 'testinvoices'}

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    # initialize common invoice data
    * def invoiceId = callonce uuid1
    * def invoiceLineId = callonce uuid2

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
    * set invoiceLinePayload.fundDistributions =
    """
    [
      {
        "fundId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696",
        "distributionType": "percentage",
        "value": 100.0
      }
    ]
    """

    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == <subTotal>
    And match $.total == <subTotal>
    Examples:
      |invoiceLineId | subTotal   | quantity|
      |invoiceLineId | 0.0        |   1     |


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

  Scenario: Verify get invoice by id - invoice move to Approved status and total = 0$
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == "Approved"
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 0.0
    And match $.total == 0.0

  Scenario: Pay for the invoice
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

  Scenario: Check that payments created with 0$ amount of money
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Payment'
    When method GET
    Then status 200
    * def total = $.transactions[0].amount
    And assert total == 0.0
