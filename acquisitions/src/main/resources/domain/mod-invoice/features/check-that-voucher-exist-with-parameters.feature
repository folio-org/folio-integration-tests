# created for MODINVOSTO-56
Feature: Check voucher from invoice with lines

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_invoices124'}
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
    * def invoiceLine1Id = callonce uuid1
    * def invoiceLine2Id = callonce uuid2
    * def invoiceLine3Id = callonce uuid3
    * def fund1Id = callonce uuid4
    * def fund2Id = callonce uuid5
    * def fund3Id = callonce uuid6
    * def fund4Id = callonce uuid7
    * def budget1Id = callonce uuid8
    * def budget2Id = callonce uuid9
    * def budget3Id = callonce uuid10
    * def budget4Id = callonce uuid11
    * def invoiceId = callonce uuid12

  Scenario Outline: prepare finances for fund with fundId, code, externalAccountNo and budget with budgetId
    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def externalAccountNo = <externalAccountNo>
    * def code = <code>

    * call createFundWithParams { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)', 'code': '#(code)', 'externalAccountNo': '#(externalAccountNo)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 9999 }

    Examples:
      | fundId  | budgetId  | code     | externalAccountNo |
      | fund1Id | budget1Id | 'FD001' | '123456'          |
      | fund2Id | budget2Id | 'FD002' | '234567'          |
      | fund3Id | budget3Id | 'FD003' | '123456'          |
      | fund4Id | budget4Id | 'FD004' | '345678'          |

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
    And match response.currency == 'EUR'

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
          "fundId": "#(fund1Id)",
          "distributionType": "percentage",
          "value": 50
        },
        {
          "code":  "FD002",
          "fundId": "#(fund2Id)",
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
          "code":  "FD002",
          "distributionType": "percentage",
          "fundId": "#(fund2Id)",
          "value": "50"
        },
        {
          "code":  "FD003",
          "distributionType": "percentage",
          "fundId": "#(fund3Id)",
          "value": "50"
        }
      ],
      "subTotal": "10",
      "description": "InvoiceLine-2",
      "quantity": "1",
      "total": "10"
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
          "code":  "FD002",
          "distributionType": "percentage",
          "fundId": "#(fund2Id)",
          "value": "25"
        },
        {
          "code":  "FD004",
          "distributionType": "percentage",
          "fundId": "#(fund4Id)",
          "value": "75"
        }
      ],
      "subTotal": "20",
      "description": "InvoiceLine-3",
      "quantity": "1",
      "total": "20",
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
    And match voucher.amount == 44

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    And match $.voucherLines == '#[3]'

    * def voucherLine1 = karate.jsonPath(response, "$.voucherLines[?(@.externalAccountNumber=='123456')]")[0]
    And match voucherLine1.fundDistributions == '#[2]'
    And match voucherLine1.fundDistributions[*].fundId contains only ["#(fund1Id)", "#(fund3Id)"]
    And match voucherLine1.sourceIds contains only ["#(invoiceLine1Id)", "#(invoiceLine2Id)"]
    And match voucherLine1.amount == 11.00

    * def voucherLine2 = karate.jsonPath(response, "$.voucherLines[?(@.externalAccountNumber=='234567')]")[0]
    And match voucherLine2.fundDistributions == '#[3]'
    And match voucherLine2.fundDistributions[*].fundId contains only ["#(fund2Id)", "#(fund2Id)", "#(fund2Id)"]
    And match voucherLine2.sourceIds contains only ["#(invoiceLine1Id)", "#(invoiceLine2Id)", "#(invoiceLine3Id)"]
    And match voucherLine2.amount == 16.50

    * def voucherLine3 = karate.jsonPath(response, "$.voucherLines[?(@.externalAccountNumber=='345678')]")[0]
    And match voucherLine3.fundDistributions == '#[1]'
    And match voucherLine3.sourceIds[0] == invoiceLine3Id
    And match voucherLine3.fundDistributions[0].code == 'FD004'
    And match voucherLine3.amount == 16.50
