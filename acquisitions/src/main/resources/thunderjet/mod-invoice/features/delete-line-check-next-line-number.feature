# For MODINVOICE-647
Feature: Delete line and check next line number

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

    * call variables


  Scenario: Delete line and check next line number
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid

    # 1. Create finances
    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create an invoice
    * print "2. Create an invoice"
    * configure headers = headersUser
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 3. Add two invoice lines
    * print "3. Add two invoice lines"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: 10 }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: 10 }

    # 4. Delete invoice line 2
    * print "4. Delete invoice line 2"
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method DELETE
    Then status 204

    # 5. Create invoice line 3
    * print "5. Create invoice line 3"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId3)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: 10 }

    # 6. Check invoice line 3 number
    * print "6. Check invoice line 3 number"
    Given path 'invoice/invoice-lines', invoiceLineId3
    When method GET
    Then status 200
    And match $.invoiceLineNumber == '3'
