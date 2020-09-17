Feature: Check remaining amount upon invoice approval

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_invoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

  Scenario: Approve invoice with <invoiceAmount> amount and budget with <allocated> amount to get <httpCode> code

    * def budgetId = call uuid
    * def fundId = call uuid

    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # ============= Create funds =============
    * configure headers = headersAdmin
    Given path 'finance-storage/funds'
    And request
    """
    {

      "id": "#(fundId)",
      "code": "#(fundId)",
      "description": "Fund for orders API Tests",
      "externalAccountNo": "1111111111111111111111111",
      "fundStatus": "Active",
      "ledgerId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
      "name": "Fund for orders API Tests"
    }
    """
    When method POST
    Then status 201

    # ============= Create budgets ===================
    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId":"ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
      "budgetStatus": "Active",
      "allowableExpenditure": 100,
      "allowableEncumbrance": 100,
      "allocated": 260
    }
    """
    When method POST
    Then status 201

    # ============= Create invoices ===================
    * configure headers = headersUser

    Given path 'invoice/invoices'
    And request
    """
    {
        "id": "#(invoiceId)",
        "chkSubscriptionOverlap": true,
        "currency": "BYN",
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

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    And request
    """
    {
        "id": "#(invoiceLineId)",
        "invoiceId": "#(invoiceId)",
        "invoiceLineStatus": "Open",
        "fundDistributions": [
            {
                "distributionType": "amount",
                "fundId": "#(fundId)",
                "value": 100
            }
        ],
        "subTotal": 100,
        "description": "test",
        "quantity": "1"
    }
    """
    When method POST
    Then status 201


    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"
    * set invoicePayload.exchangeRate = 2.5

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

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

    # =================== update approved invoice with new exchange rate exceed budget remaining amount ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.exchangeRate = 2.7

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 422
    * match response.errors[0].code == 'fundCannotBePaid'

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

    # =================== update approved invoice with new exchange rate not exceed budget remaining amount ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.exchangeRate = 2.6

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

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


    # =================== pay invoice with new exchange rate not exceed budget remaining amount ===================
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
