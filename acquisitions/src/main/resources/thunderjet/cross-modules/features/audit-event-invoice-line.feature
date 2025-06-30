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
    * def v = call verifyInvoiceLineAuditEvents eventData

  Scenario: Updating Invoice Line should produce "Edit" event
    * def invoiceLineIds = [{'invoiceLineId': "#(invoiceLineId)"}]
    * def v = call updateInvoiceLine invoiceLineIds

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceLineId | "Edit"    | 2          |
    * def v = call verifyInvoiceLineAuditEvents eventData

  Scenario: Update invoice line 50 times
    * def invoiceLineIds = []
    * def populateInvoiceLineIds =
      """
      function() {
        for (let i = 0; i < 50; i++) {
          invoiceLineIds.push({'invoiceLineId': invoiceLineId});
        }
      }
      """
    * eval populateInvoiceLineIds()
    * def v = call updateInvoiceLine invoiceLineIds

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceLineId | "Edit"    | 52         |
    * def v = call verifyInvoiceLineAuditEvents eventData