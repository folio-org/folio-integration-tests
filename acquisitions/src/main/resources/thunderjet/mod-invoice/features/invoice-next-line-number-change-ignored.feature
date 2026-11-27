# For MODINVOICE-647, https://foliotest.testrail.io/index.php?/cases/view/1621485
Feature: Invoice Next Line Number Change Ignored

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


  @C1621485
  @Positive
  Scenario: Changing The Next Invoice Line Number Of An Invoice Through The API Is Ignored
    # 1. Generate Unique Identifiers For This Test Scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    # 2. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 3. Create An Open Invoice With Invoice Line 1
    * configure headers = headersUser
    * def v = call createInvoice { id: '#(invoiceId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: 10 }

    # 4. Check The Next Invoice Line Number Of The Invoice
    * call getInvoice { invoiceId: '#(invoiceId)' }
    And match invoice.nextInvoiceLineNumber == 2

    # 5. Update The Invoice With Next Invoice Line Number 1
    # Silently ignored since MODINVOICE-647; MODORDERS-1445 may turn this into a validation error
    * set invoice.nextInvoiceLineNumber = 1
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    # 6. Check That The Next Invoice Line Number Is Unchanged
    * call getInvoice { invoiceId: '#(invoiceId)' }
    And match invoice.nextInvoiceLineNumber == 2

    # 7. Add A New Invoice Line And Check Its Number
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: 10 }
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.invoiceLineNumber == '2'
