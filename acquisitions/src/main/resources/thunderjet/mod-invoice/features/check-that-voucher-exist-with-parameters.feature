# Created for MODINVOSTO-56
@parallel=false
Feature: Check voucher from invoice with lines

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
    * configure headers = headersAdmin

    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def externalAccountNo = <externalAccountNo>
    * def code = <code>

    * def v = call createFundWithParams { id: '#(fundId)', ledgerId: '#(globalLedgerId)', code: '#(code)', externalAccountNo: '#(externalAccountNo)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 9999 }

    Examples:
      | fundId  | budgetId  | code     | externalAccountNo |
      | fund1Id | budget1Id | 'FD001' | '123456'          |
      | fund2Id | budget2Id | 'FD002' | '234567'          |
      | fund3Id | budget3Id | 'FD003' | '123456'          |
      | fund4Id | budget4Id | 'FD004' | '345678'          |

  Scenario: Create invoice
    * def v = call createInvoice { id: '#(invoiceId)', currency: 'EUR', exchangeRate: 1.1 }

  Scenario: Check invoice
    Given path '/invoice/invoices/' + invoiceId
    When method GET
    Then status 200
    And match response.id == invoiceId
    And match response.currency == 'EUR'

  Scenario:  Create 3 Invoice lines
    # ============= create invoice line 1 ===================
    * table fundDistributions1
    | code    | fundId  | distributionType | value |
    | 'FD001' | fund1Id | 'percentage'     | 50    |
    | 'FD002' | fund2Id | 'percentage'     | 50    |

    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine1Id)', invoiceId: '#(invoiceId)', total: 10, fundDistributions: '#(fundDistributions1)', description: 'InvoiceLine-1' }

    # ============= create invoice line 2 ===================
    * table fundDistributions2
      | code    | fundId  | distributionType | value |
      | 'FD002' | fund2Id | 'percentage'     | 50    |
      | 'FD003' | fund3Id | 'percentage'     | 50    |

    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine2Id)', invoiceId: '#(invoiceId)', total: 10, fundDistributions: '#(fundDistributions2)', description: 'InvoiceLine-2' }

    # ============= create invoice lines 3 ===================
    * table fundDistributions3
      | code    | fundId  | distributionType | value |
      | 'FD002' | fund2Id | 'percentage'     | 25    |
      | 'FD004' | fund4Id | 'percentage'     | 75    |

    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine3Id)', invoiceId: '#(invoiceId)', total: 20, fundDistributions: '#(fundDistributions3)', description: 'InvoiceLine-3' }

  Scenario: Approve invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

  Scenario: Verify voucher lines
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
