Feature: Audit events for Invoice Line

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

    * configure retry = { count: 10, interval: 10000 }

    ### Before All ###
    * callonce variables
    * def fundId = globalFundId
    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2
    * def invoiceId = callonce uuid3
    * def invoiceLineId = callonce uuid4

    * table orderData
      | id      | fundId | createInventory |
      | orderId | fundId | 'None'          |
    * callonce createOrder orderData
    * table orderLineData
      | id       | orderId | fundId |
      | poLineId | orderId | fundId |
    * callonce createOrderLine orderLineData
    * callonce openOrder { id: "#(orderId)" }

    * configure headers = headersUser
    * table invoicesData
      | id        | fiscalYearId       |
      | invoiceId | globalFiscalYearId |
    * callonce createInvoice invoicesData

  Scenario: Creating Invoice Line should produce "Create" event
    * table invoiceLinesData
      | invoiceLineId | invoiceId | poLineId | fundId | total |
      | invoiceLineId | invoiceId | poLineId | fundId | 1     |
    * def v = call createInvoiceLine invoiceLinesData

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceLineId | "Create"  | 1          |
    * def v = call read('@VerifyAuditEvents') eventData

  Scenario: Updating Invoice Line should produce "Edit" event
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response

    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceLineId | "Edit"    | 2          |
    * def v = call read('@VerifyAuditEvents') eventData

  Scenario: Update invoice line 50 times
    * def invoiceLineIds = []
    * def populateInvoiceLineIds =
      """
      function() {
        for (let i = 0; i < 50; i++) {
          invoiceLineIds.push({'newInvoiceLineId': invoiceLineId});
        }
      }
      """
    * eval populateInvoiceLineIds()
    * def v = call read('@UpdateInvoiceLine') invoiceLineIds

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceLineId | "Edit"    | 52         |
    * def v = call read('@VerifyAuditEvents') eventData

  # FIXME: @ignore is not ignored with call(), as in orders.feature - the solution is to create a separate feature for this
  @ignore @VerifyAuditEvents
  Scenario: Verify Audit Events
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/invoice-line', eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.invoiceLineAuditEvents[*].action contains eventType
    And match response.invoiceLineAuditEvents[*].invoiceLineId contains eventEntityId

  @ignore @UpdateInvoiceLine
  Scenario: Update invoice line
    Given path 'invoice/invoice-lines', newInvoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response

    Given path 'invoice/invoice-lines', newInvoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204