@parallel=false
Feature: Audit events for Invoice

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
    * def invoiceId = callonce uuid

  Scenario: Creating Invoice should produce "Create" event
    * table invoicesData
      | id        | fiscalYearId       |
      | invoiceId | globalFiscalYearId |
    * def v = call createInvoice invoicesData

    * configure headers = headersAdmin
    * table eventData
      | resourcePath | eventEntityId | eventType | eventCount | entityName |
      | "invoice"    | invoiceId     | "Create"  | 1          | "invoice"  |
    * def v = call verifyResourceAuditEvents eventData

  Scenario: Updating Invoice should produce "Edit" event
    * def invoiceIds = [{'resourcePath': 'invoice/invoices', 'resourceId': "#(invoiceId)"}]
    * def v = call updateResource invoiceIds

    * configure headers = headersAdmin
    * table eventData
      | resourcePath | eventEntityId | eventType | eventCount | entityName |
      | "invoice"    | invoiceId     | "Edit"    | 2          | "invoice"  |
    * def v = call verifyResourceAuditEvents eventData

  Scenario: Update invoice 50 times
    * def invoiceIds = []
    * def populateInvoiceIds =
      """
      function() {
        for (let i = 0; i < 50; i++) {
          invoiceIds.push({'resourcePath': 'invoice/invoices', 'resourceId': invoiceId});
        }
      }
      """
    * eval populateInvoiceIds()
    * def v = call updateResource invoiceIds

    * configure headers = headersAdmin
    * table eventData
      | resourcePath | eventEntityId | eventType | eventCount | entityName |
      | "invoice"    | invoiceId     | "Edit"    | 52         | "invoice"  |
    * def v = call verifyResourceAuditEvents eventData