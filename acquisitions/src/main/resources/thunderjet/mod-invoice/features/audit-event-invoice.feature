Feature: Audit events for Invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 5000 }

    ### Before All ###
    * callonce variables
    * def invoiceId = callonce uuid

  Scenario: Creating Invoice should produce "Create" event
    * table invoicesData
      | id        | fiscalYearId       |
      | invoiceId | globalFiscalYearId |
    * def v = call createInvoice invoicesData

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceId | "Create"  | 1          |
    * def v = call read('@VerifyAuditEvents') eventData

  Scenario: Updating Invoice should produce "Edit" event
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = response

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    * table eventData
      | eventEntityId | eventType | eventCount |
      | invoiceId | "Edit"    | 2          |
    * def v = call read('@VerifyAuditEvents') eventData

  @ignore @VerifyAuditEvents
  Scenario: Verify Audit Events
    Given path '/audit-data/acquisition/invoice', eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.invoiceAuditEvents[*].action contains eventType
    And match response.invoiceAuditEvents[*].invoiceId contains eventEntityId
