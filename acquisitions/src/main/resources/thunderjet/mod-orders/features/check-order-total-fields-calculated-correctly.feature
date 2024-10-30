Feature: Check that order total fields are calculated correctly

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * callonce loginRegularUser testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * configure headers = headersAdmin

    * callonce variables

    ### Before All ###
    * def previousFiscalYear = callonce uuid1
    * def currentFiscalYear = callonce uuid2
    * def codePrefix = callonce random_string
    * def toYear = callonce getCurrentYear
    * def fromYear = parseInt(toYear) - 1
    * table fiscalYearDetails
      | id                 | code                  | periodStart                   | periodEnd                     | series |
      | previousFiscalYear | codePrefix + fromYear | fromYear + '-01-01T00:00:00Z' | fromYear + '-12-30T23:59:59Z' | 1      |
      | currentFiscalYear  | codePrefix + toYear   | toYear + '-01-01T00:00:00Z'   | toYear + '-12-30T23:59:59Z'   | 2      |
    * def v = callonce createFiscalYear fiscalYearDetails

    * def ledgerId = callonce uuid3
    * table ledgerDetails
      | id       | fiscalYearId       | restrictEncumbrance | restrictExpenditures |
      | ledgerId | previousFiscalYear | false               | false                |
    * def v = callonce createLedger ledgerDetails

    * def fundId = callonce uuid4
    * table fundDetails
      | id     | code     | ledgerId |
      | fundId | "FUND-1" | ledgerId |
    * def v = callonce createFund fundDetails

    * table budgetDetails
      | fundId | fiscalYearId       | allocated |
      | fundId | previousFiscalYear | 9999999   |
      | fundId | currentFiscalYear  | 9999999   |
    * def v = callonce createBudget budgetDetails


    ### Before Each ###
    * def orderId = call uuid
    * def v = call createOrder { id: "#(orderId)" }

    * def poLineId = call uuid
    * table orderLineData
      | id       | orderId | fundId | listUnitPrice |
      | poLineId | orderId | fundId | 100           |
    * def v = call createOrderLine orderLineData

    * def v = call openOrder { id: "#(orderId)" }

    * def invoiceId = call uuid
    * table invoicesData
      | id        | fiscalYearId      |
      | invoiceId | currentFiscalYear |
    * def v = call createInvoice invoicesData


  Scenario: Check order total fields with invoice lines having positive and negative sub-total values
    # 1. Create Invoice Lines
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | 50    |
      | invoiceLineId2 | invoiceId | poLineId | fundId | -150  |
    * def v = call createInvoiceLine invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 50
    And match response.totalCredited == 150


  Scenario: Check order total fields with invoice lines having only positive sub-total values
    # 1. Create Invoice Line
    * def invoiceLineId1 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | 100   |
    * def v = call createInvoiceLine invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 100
    And match response.totalCredited == 0


  Scenario: Check order total fields with invoice lines having only negative sub-total values
    # 1. Create Invoice Line
    * def invoiceLineId1 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | -100  |
    * def v = call createInvoiceLine invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 0
    And match response.totalCredited == 100


  Scenario: Check order total fields with invoices having different fiscal year
    # 1. Create Invoice
    * def invoiceId2 = call uuid
    * table invoicesData
      | id         | fiscalYearId       |
      | invoiceId2 | previousFiscalYear |
    * def v = call createInvoice invoicesData

    # 2. Create Invoice Lines
    * def invoiceLineId1 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId  | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId2 | poLineId | fundId | -100  |
    * def v = call createInvoiceLine invoiceLinesData

    # 3. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 0
    And match response.totalCredited == 0


  Scenario: Check order total fields with no invoice lines
    # 1. Check that total fields are calculated correctly without invoices
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 0
    And match response.totalCredited == 0

