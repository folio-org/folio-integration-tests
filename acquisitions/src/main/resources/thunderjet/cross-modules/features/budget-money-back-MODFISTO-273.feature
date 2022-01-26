Feature: Budget money back

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_cross_modules'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundId = callonce uuid1
    * def fundId2 = callonce uuid2
    * def fundId3 = callonce uuid3
    * def budgetId = callonce uuid4
    * def budgetId2 = callonce uuid5
    * def budgetId3 = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceId2 = callonce uuid8
    * def invoiceId3 = callonce uuid9
    * def invoiceLineId = callonce uuid10
    * def invoiceLineId2 = callonce uuid11
    * def invoiceLineId3 = callonce uuid12

  Scenario: Cancel credit
    * print "Cancel credit"

    # ============= Create funds =============
    * configure headers = headersAdmin
    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId)",
      "code": "#(fundId)",
      "externalAccountNo": "#(fundId)",
      "fundStatus": "Active",
      "ledgerId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
      "name": "TestFund"
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
      "allocated": 200
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
        "currency": "USD",
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
                "distributionType": "percentage",
                "fundId": "#(fundId)",
                "value": 100
            }
        ],
        "subTotal": -100,
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

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 300
    * match $.awaitingPayment == -100
    * match $.unavailable == -100

    # ============= pay invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Paid"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============== get budget ====================
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 300
    * match $.awaitingPayment == 0.0
    * match $.cashBalance == 300
    * match $.expenditures == -100
    * match $.unavailable == -100

    # ============== cancel invoice ==================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Cancelled"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============== get budget ====================
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.available == 200
    * match $.awaitingPayment == 0.0
    * match $.cashBalance == 200
    * match $.expenditures == 0.0
    * match $.unavailable == 0.0

    Given path "/finance/transactions"
    * param query = 'transactionType==Credit and toFundId==' + fundId
    When method GET
    Then status 200
    * def transaction = $.transactions[0]
    * match transaction.transactionType == "Credit"
    * match transaction.amount == 0.0
    * match transaction.voidedAmount == 100


  Scenario: Cancel payment
    * print "Cancel payment"

    # ============= Create funds =============
    * configure headers = headersAdmin
    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId2)",
      "code": "#(fundId2)",
      "externalAccountNo": "#(fundId2)",
      "fundStatus": "Active",
      "ledgerId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
      "name": "TestFund"
    }
    """
    When method POST
    Then status 201

    # ============= Create budgets ===================
    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId2)",
      "budgetStatus": "Active",
      "fundId": "#(fundId2)",
      "name": "#(budgetId2)",
      "fiscalYearId":"ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
      "allocated": 200
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
        "id": "#(invoiceId2)",
        "chkSubscriptionOverlap": true,
        "currency": "USD",
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
        "id": "#(invoiceLineId2)",
        "invoiceId": "#(invoiceId2)",
        "invoiceLineStatus": "Open",
        "fundDistributions": [
            {
                "distributionType": "percentage",
                "fundId": "#(fundId2)",
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
    Given path 'invoice/invoices', invoiceId2
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId2
    And request invoicePayload
    When method PUT
    Then status 204

    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.available == 100
    * match $.awaitingPayment == 100
    * match $.unavailable == 100
    * match $.expenditures == 0.0

    # ============= pay invoice ===================
    Given path 'invoice/invoices', invoiceId2
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Paid"

    Given path 'invoice/invoices', invoiceId2
    And request invoicePayload
    When method PUT
    Then status 204

    # ============== get budget ====================
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.available == 100
    * match $.awaitingPayment == 0.0
    * match $.cashBalance == 100
    * match $.expenditures == 100
    * match $.unavailable == 100

    # ============== cancel invoice ==================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Cancelled"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============== get budget ====================
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.available == 200
    * match $.awaitingPayment == 0.0
    * match $.cashBalance == 200
    * match $.expenditures == 0.0
    * match $.unavailable == 0.0

    Given path "/finance/transactions"
    * param query = 'transactionType==Payment and toFundId==' + fundId2
    When method GET
    Then status 200
    * def transaction = $.transactions[0]
    * match transaction.transactionType == "Payment"
    * match transaction.amount == 0.0
    * match transaction.voidedAmount == 100

  Scenario: Cancel pending payment
    * print "Cancel pending payment"

    # ============= Create funds =============
    * configure headers = headersAdmin
    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId3)",
      "code": "#(fundId3)",
      "externalAccountNo": "#(fundId3)",
      "fundStatus": "Active",
      "ledgerId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695",
      "name": "TestFund3"
    }
    """
    When method POST
    Then status 201

    # ============= Create budgets ===================
    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId3)",
      "budgetStatus": "Active",
      "fundId": "#(fundId3)",
      "name": "#(budgetId3)",
      "fiscalYearId":"ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
      "allocated": 200
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
        "id": "#(invoiceId3)",
        "chkSubscriptionOverlap": true,
        "currency": "USD",
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
        "id": "#(invoiceLineId3)",
        "invoiceId": "#(invoiceId3)",
        "invoiceLineStatus": "Open",
        "fundDistributions": [
            {
                "distributionType": "percentage",
                "fundId": "#(fundId3)",
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
    Given path 'invoice/invoices', invoiceId3
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId3
    And request invoicePayload
    When method PUT
    Then status 204

    Given path 'finance/budgets', budgetId3
    When method GET
    Then status 200
    And match $.available == 100
    * match $.awaitingPayment == 100
    * match $.unavailable == 100
    * match $.expenditures == 0.0

    # ============== cancel invoice ==================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Cancelled"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============== get budget ====================
    Given path 'finance/budgets', budgetId3
    When method GET
    Then status 200
    And match $.available == 200
    * match $.awaitingPayment == 0.0
    * match $.cashBalance == 200
    * match $.expenditures == 0.0
    * match $.unavailable == 0.0

    Given path "/finance/transactions"
    * param query = 'transactionType==Pending payment and toFundId==' + fundId3
    When method GET
    Then status 200
    * def transaction = $.transactions[0]
    * match transaction.transactionType == "Pending payment"
    * match transaction.amount == 0.0
    * match transaction.voidedAmount == 100
