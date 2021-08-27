# created for MODINVOSTO-56
Feature: Check voucher from invoice with lines

  Background:
    * url baseUrl
    # uncomment below line for development
    * callonce dev {tenant: 'test_invoices1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    # prepare sample data for creating invoice
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    # initialize common invoice data
    * def invoiceLine1Id = "87f08330-6e5c-45f6-87b9-e619346e0cec"
    * def invoiceLine2Id = "52e74395-b2c7-4318-a67a-3b96deb1d8cd"
    * def invoiceLine3Id = "b9ea1eb0-47f1-4736-b81c-31f39f32d459"
#    * def invoiceId = callonce uuid5
    * def invoiceId = "b95d092d-ecca-4442-a4bf-0447068d7b27"

  Scenario Outline: prepare finances for fund with fundId, code, externalAccountNo and budget with budgetId
    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def externalAccountNo = <externalAccountNo>
    * def code = <code>

    * call createFundWithParams { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)', 'code': '#(code)', 'externalAccountNo': '#(externalAccountNo)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 9999 }

    Examples:
      | fundId                                 | budgetId                               | code     | externalAccountNo |
      | 'd55b772d-d862-5380-9eac-5a15b6516550' | 'd55b772d-d862-5380-9eac-5a15b6516555' | 'Fund A' | '123456'          |
      | 'd55b772d-d862-5380-9eac-5a15b6516551' | 'd55b772d-d862-5380-9eac-5a15b6516556' | 'Fund B' | '234567'          |
      | 'd55b772d-d862-5380-9eac-5a15b6516552' | 'd55b772d-d862-5380-9eac-5a15b6516557' | 'Fund C' | '123456'          |
      | 'd55b772d-d862-5380-9eac-5a15b6516553' | 'd55b772d-d862-5380-9eac-5a15b6516558' | 'Fund D' | '345678'          |

  Scenario: check fund
    Given path '/finance-storage/funds/' + 'd55b772d-d862-5380-9eac-5a15b6516550'
    When method GET
    Then status 200
    And match response.id == 'd55b772d-d862-5380-9eac-5a15b6516550'
    And match $.externalAccountNo == '123456'
    And match $.code == 'Fund A'

  Scenario: Create invoice

    * set invoicePayload.id = invoiceId
    * set invoicePayload.currency = "EUR"
    * set invoicePayload.exchangeRate = 1.1

     # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

  Scenario: Check invoice
    Given path '/invoice/invoices/' + invoiceId
    When method GET
    Then status 200
    And match response.id == invoiceId

  Scenario:  Create 3 Invoice lines

    # ============= create invoice lines 1 ===================
    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLine1Id)',
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
       {
          "code":  "FD001",
          "fundId": "d55b772d-d862-5380-9eac-5a15b6516550",
          "distributionType": "percentage",
          "value": 50
        },
        {
          "code":  "FD002",
          "fundId": "d55b772d-d862-5380-9eac-5a15b6516551",
          "distributionType": "percentage",
          "value": 50
        }
      ],
      "subTotal": "10",
      "description": "InvoiceLine-1",
      "quantity": "1",
      "total": "10"
    }
    """
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    # ============= create invoice lines 2 ===================
    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLine2Id)',
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
        {
          "code":  "FD003",
          "distributionType": "percentage",
          "fundId": "d55b772d-d862-5380-9eac-5a15b6516551",
          "value": "50"
        },
        {
          "code":  "FD004",
          "distributionType": "percentage",
          "fundId": "d55b772d-d862-5380-9eac-5a15b6516552",
          "value": "50"
        }
      ],
      "subTotal": "10",
      "quantity": "1",
      "subTotal": "1",
      "total": "10",
      "description": "InvoiceLine-2"
    }
    """
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= create invoice lines 3 ===================
    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLine3Id)',
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
         {
          "code":  "FD005",
          "distributionType": "percentage",
          "fundId": "d55b772d-d862-5380-9eac-5a15b6516551",
          "value": "25"
        },
        {
          "code":  "FD006",
          "distributionType": "percentage",
          "fundId": "d55b772d-d862-5380-9eac-5a15b6516553",
          "value": "75"
        }
      ],
      "subTotal": "20",
      "quantity": "1",
      "subTotal": "1",
      "total": "20",
      "description": "InvoiceLine-3"
    }
    """
    When method POST
    Then status 201
    * def invoiceLineId3 = $.id

  # ============= get invoice to approve ===================
  Scenario: invoice with approve it, check voucher lines

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"

    # ============= put approved invoice ===================
    Given path 'invoice/invoices', invoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Verify voucher lines

        # ============= Verify voucher lines ===================
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]
    And match voucher.exchangeRate == 1.1
    And match voucher.systemCurrency == 'USD'
    And match voucher.invoiceCurrency == 'EUR'
    And match voucher.amount == 13.2

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    And match $.voucherLines == '#[3]'
    And match $.voucherLines[0].fundDistributions == '#[1]'
    And match $.voucherLines[0].externalAccountNumber == '345678'
    And match $.voucherLines[0].sourceIds[0] == invoiceLine3Id
    And match $.voucherLines[0].fundDistributions[0].code == 'Fund D'
    #And match $.voucherLines[0].amount == '15'
    And match $.voucherLines[0].amount == 0.82

    And match $.voucherLines[1].fundDistributions == '#[3]'
    And match $.voucherLines[1].externalAccountNumber == '234567'
    And match $.voucherLines[1].sourceIds[0] == invoiceLine3Id
    And match $.voucherLines[1].sourceIds[1] == invoiceLine1Id
    And match $.voucherLines[1].sourceIds[2] == invoiceLine2Id
    And match $.voucherLines[1].fundDistributions[0].code == 'Fund B'
    And match $.voucherLines[1].fundDistributions[1].code == 'Fund B'
    And match $.voucherLines[1].fundDistributions[2].code == 'Fund B'
    #And match $.voucherLines[0].amount == '16.50'
    And match $.voucherLines[1].amount == 6.33

    And match $.voucherLines[2].fundDistributions == '#[2]'
    And match $.voucherLines[2].externalAccountNumber == '123456'
    And match $.voucherLines[2].sourceIds[0] == invoiceLine1Id
    And match $.voucherLines[2].sourceIds[1] == invoiceLine2Id
    And match $.voucherLines[2].fundDistributions[0].code == 'Fund A'
    And match $.voucherLines[2].fundDistributions[1].code == 'Fund C'
    #And match $.voucherLines[2].amount == '11'
    And match $.voucherLines[2].amount == 6.05

#    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId1 + "')]")
#    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId2 + "')]")
#
#    And match fundDistributions1[0].fundId == fund1Id
#    And match fundDistributions2[0].fundId == fund2Id
