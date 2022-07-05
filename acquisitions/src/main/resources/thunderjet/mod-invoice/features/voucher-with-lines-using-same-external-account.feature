Feature: Check voucher from invoice with lines using the same external account

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_invoices'}
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

    # initialize common invoice data
    * def fund1Id = callonce uuid1
    * def code1Id = callonce uuid2
    * def budget1Id = callonce uuid3
    * def fund2Id = callonce uuid4
    * def code2Id = callonce uuid5
    * def budget2Id = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLine1Id = callonce uuid8
    * def invoiceLine2Id = callonce uuid9

  Scenario: Create budgets, invoice with 2 lines, approve it, check voucher lines
    * configure headers = headersAdmin

    * call createFund { 'id': '#(fund1Id)', 'code': '#(code1Id)', 'ledgerId': '#(globalLedgerId)', 'externalAccountNo': '123456' }
    * call createBudget { 'id': '#(budget1Id)', 'fundId': '#(fund1Id)', 'allocated': 10000 }
    * call createFund { 'id': '#(fund2Id)', 'code': '#(code2Id)', 'ledgerId': '#(globalLedgerId)', 'externalAccountNo': '123456' }
    * call createBudget { 'id': '#(budget2Id)', 'fundId': '#(fund2Id)', 'allocated': 10000 }

    * set invoicePayload.id = invoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLine1Id)',
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
        {
          "distributionType": "percentage",
          "fundId": "#(fund1Id)",
          "value": "100"
        }
      ],
      "subTotal": "25",
      "description": "line 1",
      "quantity": "1"
    }
    """
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "id": '#(invoiceLine2Id)',
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
        {
          "distributionType": "percentage",
          "fundId": "#(fund2Id)",
          "value": "100"
        }
      ],
      "subTotal": "25",
      "description": "line 2",
      "quantity": "1"
    }
    """
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= get invoice to approve ===================
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

    # ============= Verify voucher lines ===================
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
    And match $.voucherLines == '#[1]'
    And match $.voucherLines[0].fundDistributions == '#[2]'
    And match $.voucherLines[0].externalAccountNumber == '123456'
    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId1 + "')]")
    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId2 + "')]")

    And match fundDistributions1[0].fundId == fund1Id
    And match fundDistributions2[0].fundId == fund2Id

