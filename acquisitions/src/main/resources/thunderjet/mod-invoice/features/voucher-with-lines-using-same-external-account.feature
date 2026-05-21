Feature: Check voucher from invoice with lines using the same external account

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


  Scenario: Create budgets, invoice with 2 lines, approve it, check voucher lines
    * def fund1Id = call uuid
    * def code1Id = call uuid
    * def budget1Id = call uuid
    * def fund2Id = call uuid
    * def code2Id = call uuid
    * def budget2Id = call uuid
    * def invoiceId = call uuid
    * def invoiceLine1Id = call uuid
    * def invoiceLine2Id = call uuid

    # 1. Create funds and budgets
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fund1Id)', 'code': '#(code1Id)', 'ledgerId': '#(globalLedgerId)', 'externalAccountNo': '123456' }
    * def v = call createBudget { 'id': '#(budget1Id)', 'fundId': '#(fund1Id)', 'allocated': 10000 }
    * def v = call createFund { 'id': '#(fund2Id)', 'code': '#(code2Id)', 'ledgerId': '#(globalLedgerId)', 'externalAccountNo': '123456' }
    * def v = call createBudget { 'id': '#(budget2Id)', 'fundId': '#(fund2Id)', 'allocated': 10000 }

    # 2. Create invoice
    * configure headers = headersUser
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 3. Create invoice lines
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine1Id)', invoiceId: '#(invoiceId)', fundId: '#(fund1Id)', total: 25, description: 'line 1' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine2Id)', invoiceId: '#(invoiceId)', fundId: '#(fund2Id)', total: 25, description: 'line 2' }

    # 4. Approve invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 5. Verify voucher lines
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
    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLine1Id + "')]")
    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLine2Id + "')]")

    And match fundDistributions1[0].fundId == fund1Id
    And match fundDistributions2[0].fundId == fund2Id
