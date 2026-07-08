# For FDOPS-5267
Feature: Verify expense class lookup populates fundDistribution.expenseClassId on GOBI order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def v = call read('classpath:thunderjet/mod-orders/reusable/set-create-inventory.feature') { eresource: 'Instance, Holding, Item', physical: 'Instance, Holding, Item', other: 'None' }

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, application/xml', 'x-okapi-tenant': '#(testTenant)' }

    * callonce variables
    # USHIST fund + its FY2026 budget from global/finances.feature
    * def ushistBudgetId = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a619'

  @Positive
  Scenario: Expense Class Mapping Populates FundDistribution ExpenseClassId On The Resulting PO Line
    # 1. Attach The "Prn" Expense Class To USHIST's FY2026 Budget As Active
    * def budgetExpenseClassId = call uuid
    Given path 'finance-storage/budget-expense-classes'
    And headers headersAdmin
    And request
    """
    {
      "id": "#(budgetExpenseClassId)",
      "budgetId": "#(ushistBudgetId)",
      "expenseClassId": "#(globalPrnExpenseClassId)",
      "status": "Active"
    }
    """
    When method POST
    Then status 201

    # 2. Upload The Custom UnlistedPrintMonograph Mapping Which Maps
    #    EXPENSE_CLASS From LocalData5 Via LookupExpenseClassId (By Code)
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # 3. Post A GOBI Order Whose LocalData5 Carries The Expense Class Code ("Prn")
    * def sample_po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph-with-expense-class.xml')

    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-bypass-cache': 'true' }
    And request sample_po
    And retry until responseStatus == 201
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # 4. Look Up The Created Composite Order To Grab Its Id For Cleanup
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    * def orderId = response.purchaseOrders[0].id

    # 5. Fetch The PO Line And Assert That Both The Fund And The Expense Class Were Populated
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].fundDistribution[0].code == 'USHIST'
    And match $.poLines[0].fundDistribution[0].expenseClassId == globalPrnExpenseClassId

    # 6. Delete The Custom Mapping So Subsequent Scenarios See Defaults
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # 7. Cleanup Order Data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

    # 8. Detach The Expense Class From The Budget So The Shared USHIST Budget Stays Clean
    Given path 'finance-storage/budget-expense-classes', budgetExpenseClassId
    And headers headersAdmin
    When method DELETE
    Then status 204
