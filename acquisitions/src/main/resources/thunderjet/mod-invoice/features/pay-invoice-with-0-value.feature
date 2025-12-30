# For FAT-21190, https://foliotest.testrail.io/index.php?/cases/view/357044
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

  @C357044
  @Positive
  Scenario: Pay Invoice With 0 Value
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    # 1. Create Finance
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId1)", name: "Fund Alpha" }
    * def v = call createFund { id: "#(fundId2)", name: "Fund Beta" }
    * def v = call createBudget { id: "#(budgetId1)", allocated: 100, fundId: "#(fundId1)", status: "Active" }
    * def v = call createBudget { id: "#(budgetId2)", allocated: 100, fundId: "#(fundId2)", status: "Active" }

    # 2. Create Invoice
    * configure headers = headersUser
    * def v = call createInvoice { id: "#(invoiceId)" }

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