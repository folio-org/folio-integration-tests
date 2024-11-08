Feature: Audit events for Invoice Line

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 5000 }

    ### Before All ###
    * callonce variables
    * def fundId = globalFundId
    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2
    * def invoiceId = callonce uuid3
    * def invoiceLineId = callonce uuid4

    * callonce createOrder { id: "#(orderId)" }
    * table orderLineData
      | id       | orderId | fundId |
      | poLineId | orderId | fundId |
    * callonce createOrderLine orderLineData
    * callonce openOrder { id: "#(orderId)" }

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
      | invoiceLineId | eventType | eventCount |
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
      | invoiceLineId | eventType | eventCount |
      | invoiceLineId | "Edit"    | 2          |
    * def v = call read('@VerifyAuditEvents') eventData

  @ignore @VerifyAuditEvents
  Scenario: Verify Audit Events
    Given path 'audit-data/acquisition/invoice-line/' + invoiceLineId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.invoiceLineAuditEvents[*].action contains eventType
    And match response.invoiceLineAuditEvents[*].invoiceLineId contains invoiceLineId
