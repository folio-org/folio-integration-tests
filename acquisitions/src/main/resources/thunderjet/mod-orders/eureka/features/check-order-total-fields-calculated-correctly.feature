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

  @Positive
  Scenario: Check total order fields with totalExpended being zero while invoice lines are opened
    # 1. Create Invoice Lines
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | 100   |
      | invoiceLineId2 | invoiceId | poLineId | fundId | 150   |
    * def v = call createInvoiceLine invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 0
    And match response.totalCredited == 0

  @Positive
  Scenario: Check total order fields with totalExpended being zero while invoice lines are approved
    # 1. Create Invoice Lines
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | 100   |
      | invoiceLineId2 | invoiceId | poLineId | fundId | 150   |
    * def v = call createInvoiceLine invoiceLinesData
    * def v = call approveInvoice invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 0
    And match response.totalExpended == 0
    And match response.totalCredited == 0

  @Positive
  Scenario: Check order total fields with invoice lines having positive and negative sub-total values
    # 1. Create Invoice Lines
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | 50    |
      | invoiceLineId2 | invoiceId | poLineId | fundId | -150  |
    * def v = call createInvoiceLine invoiceLinesData
    * def v = call approveInvoice invoiceLinesData
    * def v = call payInvoice invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 0
    And match response.totalExpended == 50
    And match response.totalCredited == 150

  @Positive
  Scenario: Check order total fields with invoice lines having only positive sub-total values
    # 1. Create Invoice Line
    * def invoiceLineId1 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | 100   |
    * def v = call createInvoiceLine invoiceLinesData
    * def v = call approveInvoice invoiceLinesData
    * def v = call payInvoice invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 0
    And match response.totalExpended == 100
    And match response.totalCredited == 0

  @Positive
  Scenario: Check order total fields with invoice lines having only negative sub-total values
    # 1. Create Invoice Line
    * def invoiceLineId1 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId | fundId | -100  |
    * def v = call createInvoiceLine invoiceLinesData
    * def v = call approveInvoice invoiceLinesData
    * def v = call payInvoice invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 0
    And match response.totalExpended == 0
    And match response.totalCredited == 100

  @Positive
  Scenario: Check order total fields with invoice lines linked to po lines from another order
    # 1. Create other order and lines
    * def orderId2 = call uuid
    * def v = call createOrder { id: "#(orderId2)" }

    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * table orderLineData
      | id        | orderId  | fundId | listUnitPrice |
      | poLineId2 | orderId2 | fundId | 50            |
      | poLineId3 | orderId2 | fundId | 75            |
    * def v = call createOrderLine orderLineData

    * def v = call openOrder { id: "#(orderId2)" }

    # 1. Create Invoice Lines
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def invoiceLineId4 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId | poLineId  | fundId | total |
      | invoiceLineId1 | invoiceId | poLineId  | fundId | 50    |
      | invoiceLineId2 | invoiceId | poLineId  | fundId | -150  |
      | invoiceLineId3 | invoiceId | poLineId2 | fundId | 60    |
      | invoiceLineId4 | invoiceId | poLineId3 | fundId | -80   |
    * def v = call createInvoiceLine invoiceLinesData
    * def v = call approveInvoice invoiceLinesData
    * def v = call payInvoice invoiceLinesData

    # 2. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 0
    And match response.totalExpended == 50
    And match response.totalCredited == 150

  @Positive
  Scenario: Check order total fields with invoices having different fiscal year
    # 1. Create Invoice with previous fiscal year
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
    * def v = call approveInvoice invoiceLinesData
    * def v = call payInvoice invoiceLinesData

    # 3. Check that total fields are calculated correctly
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 0
    And match response.totalCredited == 0

  @Positive
  Scenario: Check order total fields with no invoice lines
    # 1. Check that total fields are calculated correctly without invoices
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.totalEncumbered == 100
    And match response.totalExpended == 0
    And match response.totalCredited == 0

  @Positive
  Scenario: Check order total fields with no fund distributions in POL
    # 1. Create Order, Order Line without fund distributions and Open Order
    * def orderId2 = call uuid
    * def v = call createOrder { id: "#(orderId2)" }

    * def poLineId2 = call uuid
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * remove poLine.fundDistribution
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * def v = call openOrder { id: "#(orderId2)" }

    # 2. Create Invoice with previous fiscal year and Invoice Lines for previous and current fiscal years
    * def invoiceId2 = call uuid
    * table invoicesData
      | id         | fiscalYearId       |
      | invoiceId2 | previousFiscalYear |
    * def v = call createInvoice invoicesData

    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def invoiceLineId4 = call uuid
    * table invoiceLinesData
      | invoiceLineId  | invoiceId  | poLineId  | fundId | total |
      | invoiceLineId1 | invoiceId  | poLineId2 | fundId | 140   |
      | invoiceLineId2 | invoiceId  | poLineId2 | fundId | -420  |
      | invoiceLineId3 | invoiceId2 | poLineId2 | fundId | 300   |
      | invoiceLineId4 | invoiceId2 | poLineId2 | fundId | -160  |
    * def v = call createInvoiceLine invoiceLinesData
    * def v = call approveInvoice invoiceLinesData
    * def v = call payInvoice invoiceLinesData

    # 3. Check that total fields are calculated correctly with only current fiscal year and no encumbrances
    Given path 'orders/composite-orders', orderId2
    When method GET
    Then status 200
    And match response.totalEncumbered == 0
    And match response.totalExpended == 140
    And match response.totalCredited == 420

