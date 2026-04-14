Feature: Check remaining amount upon invoice approval

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


  Scenario: Approve invoice with <invoiceAmount> amount and budget with <allocated> amount to get <httpCode> code

    * def budgetId = call uuid
    * def fundId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # ============= Create fund and budget =============
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 260 }

    # ============= Create invoices ===================
    * configure headers = headersUser
    Given path 'invoice/invoices'
    And request
    """
    {
        "id": "#(invoiceId)",
        "chkSubscriptionOverlap": true,
        "currency": "BYN",
        "exchangeRate": 2.5,
        "source": "User",
        "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
        "status": "Open",
        "invoiceDate": "2020-05-21",
        "vendorInvoiceNo": "test",
        "accountingCode": "G64758-74828",
        "paymentMethod": "Physical Check",
        "vendorId": "c6dace5d-4574-411e-8ba1-036102fcdc9b"
    }
    """
    When method POST
    Then status 201

    # ============= Create invoice line ===================
    * table fundDistributions
    | distributionType | fundId | value |
    | 'amount'         | fundId | 100   |
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fundDistributions)', total: 100 }

    # ============= approve invoice ===================
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    * configure headers = headersAdmin
    Given path 'finance/transactions'
    * param query = 'sourceInvoiceId==' + invoiceId
    * headers headersAdmin
    When method GET
    Then status 200
    And match $.transactions[0].amount == 250

    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 10
    * match $.awaitingPayment == 250
    * match $.expenditures == 0

    # =================== update approved invoice with new exchange rate exceed budget remaining amount ===================
    * configure headers = headersUser
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.exchangeRate = 2.7

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 422
    * match response.errors[0].code == 'budgetRestrictedExpendituresError'

    * configure headers = headersAdmin
    Given path 'finance/transactions'
    * param query = 'sourceInvoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.transactions[0].amount == 250

    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 10
    * match $.awaitingPayment == 250
    * match $.expenditures == 0
    * match $.credits == 0

    # =================== update approved invoice with new exchange rate not exceed budget remaining amount ===================
    * configure headers = headersUser
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.exchangeRate = 2.6

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    * configure headers = headersAdmin
    Given path 'finance/transactions'
    * param query = 'sourceInvoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.transactions[0].amount == 260

    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 0
    * match $.awaitingPayment == 260
    * match $.expenditures == 0
    * match $.credits == 0


    # =================== pay invoice with new exchange rate not exceed budget remaining amount ===================
    * configure headers = headersUser
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'
    * set invoicePayload.exchangeRate = 2.4

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    * configure headers = headersAdmin
    Given path 'finance/transactions'
    * param query = 'transactionType==Payment and sourceInvoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.transactions[0].amount == 240

    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 20
    * match $.awaitingPayment == 0
    * match $.expenditures == 240
    * match $.credits == 0
