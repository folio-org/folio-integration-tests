# Regression for MODGOBI-XXX
# mapFundDistribution in mod-gobi's Mapper used to register the FUND_CODE /
# EXPENSE_CLASS futures inside a .thenAccept that fired only after FUND_ID
# resolved, so the outer allOf snapshot did not await them. When the FOLIO
# lookups were slow (as reported by Five Colleges on CSP-7), the PO Line was
# POSTed to mod-orders with expenseClassId = null even though the mapping,
# fund and budget were correctly configured.
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
  Scenario: Expense class mapping populates fundDistribution.expenseClassId on the resulting PO Line
    # 1. Attach the "Prn" expense class to USHIST's FY2026 budget as Active
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

    # 2. Upload the custom UnlistedPrintMonograph mapping which maps
    #    EXPENSE_CLASS from LocalData5 via lookupExpenseClassId (by code).
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # 3. Post a GOBI order whose LocalData5 carries the expense class *code*
    #    the tenant knows ("Prn"), matching Five Colleges' setup where the
    #    EXPENSE_CLASS mapping resolves against the expense class code.
    * def sample_po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph-with-expense-class.xml')

    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-bypass-cache': 'true' }
    And request sample_po
    And retry until responseStatus == 201
    When method POST
    * def poLineNumber = /Response/PoLineNumber

    # 4. Look up the created composite order to grab its id for cleanup.
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    * def orderId = response.purchaseOrders[0].id

    # 5. Fetch the PO Line and assert that both the fund and the expense class
    #    were populated. This is the bit that used to be racy — expenseClassId
    #    is what regressed in production.
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].fundDistribution[0].code == 'USHIST'
    And match $.poLines[0].fundDistribution[0].expenseClassId == globalPrnExpenseClassId

    # 6. Delete the custom mapping so subsequent scenarios see defaults.
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # 7. Cleanup order data.
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

    # 8. Detach the expense class from the budget so the shared USHIST budget
    #    stays clean for other feature files.
    Given path 'finance-storage/budget-expense-classes', budgetExpenseClassId
    And headers headersAdmin
    When method DELETE
    Then status 204