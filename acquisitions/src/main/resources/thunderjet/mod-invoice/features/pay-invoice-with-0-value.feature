# For FAT-21190, FAT-21198, MODINVOICE-411, https://foliotest.testrail.io/index.php?/cases/view/357042, https://foliotest.testrail.io/index.php?/cases/view/357044
Feature: Pay Invoice With 0 Value

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * configure headers = headersUser

    * callonce variables

    # Common setup: funds, budgets, and an empty invoice (run per scenario)
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def invoiceId = call uuid

    # 1. Create Finance
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId1)", name: "Fund Alpha" }
    * def v = call createFund { id: "#(fundId2)", name: "Fund Beta" }
    * def v = call createBudget { id: "#(budgetId1)", allocated: 100, fundId: "#(fundId1)", status: "Active" }
    * def v = call createBudget { id: "#(budgetId2)", allocated: 100, fundId: "#(fundId2)", status: "Active" }

    # 2. Create Invoice
    * configure headers = headersUser
    * def v = call createInvoice { id: "#(invoiceId)" }

  @C357044
  @Positive
  Scenario: Pay Invoice with total value = 0 (one of the fund distribution has negative amount), invoice lines were newly created, not from POL
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    # 3. Create Invoice Lines
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId1)", invoiceId: "#(invoiceId)", fundId: "#(fundId1)", total: 100 }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId2)", invoiceId: "#(invoiceId)", fundId: "#(fundId2)", total: -100 }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 4. Check Invoice
    Given path 'invoice/invoices/', invoiceId
    When method GET
    Then status 200
    And match $.total == 0
    And match $.subTotal == 0
    And match $.status == "Open"

    # 5. Approve Invoice
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    # 6. Check "Pending payment" Transactions
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType=="Pending payment"'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 100

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType=="Pending payment"'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == -100

    # 7. Pay Invoice
    * configure headers = headersUser
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 8. Check "Payment" Transactions
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 100

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == "#[]"

    # 9. Check "Credit" Transactions
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions == "#[]"

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 100

  @C357042
  @Positive
  Scenario: Pay Invoice with total value = 0 (two of the fund distributions have negative amount)
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid

    # 3. Create Invoice Lines
    # Invoice line #1: amount x = 30, related to fund Alpha (negative after edit)
    # Invoice line #2: amount y = 70, related to fund Alpha (negative after edit)
    # Invoice line #3: amount (x + y) = 100, related to fund Beta
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId1)", invoiceId: "#(invoiceId)", fundId: "#(fundId1)", total: -30 }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId2)", invoiceId: "#(invoiceId)", fundId: "#(fundId1)", total: -70 }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId3)", invoiceId: "#(invoiceId)", fundId: "#(fundId2)", total: 100 }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 4. Check Invoice
    Given path 'invoice/invoices/', invoiceId
    When method GET
    Then status 200
    And match $.total == 0
    And match $.subTotal == 0
    And match $.status == "Open"

    # 5. Approve Invoice
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    # 6. Check "Pending payment" Transactions
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType=="Pending payment"'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == -30

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType=="Pending payment"'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == -70

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId3 + ' and transactionType=="Pending payment"'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 100

    # 7. Pay Invoice
    * configure headers = headersUser
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 8. Check "Payment" Transactions
    # Alpha lines (negative) should NOT have Payment transactions
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == "#[]"

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == "#[]"

    # Beta line (positive) should have a Payment transaction with amount (x + y)
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId3 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 100

    # 9. Check "Credit" Transactions
    # Alpha lines (negative) should have Credit transactions with absolute amounts
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 30

    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions == "#[1]"
    And match each $.transactions[*].amount == 70

    # Beta line (positive) should NOT have a Credit transaction
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId3 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions == "#[]"

