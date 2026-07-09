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

    # Ensure Custom Mapping Is Removed Even If The Scenario Fails Mid-Way
    * configure afterScenario =
    """
    function() {
      karate.call('classpath:thunderjet/mod-gobi/reusable/delete-custom-mapping.feature', { orderType: 'UnlistedPrintMonograph' });
    }
    """

  @Positive
  Scenario: Expense Class Mapping Populates FundDistribution ExpenseClassId On The Resulting PO Line
    # 1. Generate Unique Identifiers For This Test Scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def budgetExpenseClassId = call uuid
    # GOBI's FundCode element is capped at 30 chars, so a full UUID doesn't fit
    * def fundCode = 'EXPCLS' + fundId.substring(0, 8)

    # 2. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }
    * configure headers = {}

    # 3. Attach The "Prn" Expense Class To The New Budget As Active
    Given path 'finance-storage/budget-expense-classes'
    And headers headersAdmin
    And request
    """
    {
      "id": "#(budgetExpenseClassId)",
      "budgetId": "#(budgetId)",
      "expenseClassId": "#(globalPrnExpenseClassId)",
      "status": "Active"
    }
    """
    When method POST
    Then status 201

    # 4. Upload The Custom UnlistedPrintMonograph Mapping Which Maps
    #    EXPENSE_CLASS From LocalData5 Via LookupExpenseClassId (By Code)
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # 5. Post A GOBI Order Whose FundCode Points To The New Fund And Whose
    #    LocalData5 Carries The Expense Class Code ("Prn")
    * def sample_po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph-with-expense-class.xml')
    * set sample_po/PurchaseOrder/Order/UnlistedPrintMonograph/OrderDetail/FundCode = fundCode

    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-bypass-cache': 'true' }
    And request sample_po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # 6. Look Up The Created Composite Order To Grab Its Id For Cleanup
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    * def orderId = response.purchaseOrders[0].id

    # 7. Fetch The PO Line And Assert That Both The Fund And The Expense Class Were Populated
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].fundDistribution[0].code == fundCode
    And match $.poLines[0].fundDistribution[0].expenseClassId == globalPrnExpenseClassId

    # 8. Cleanup Order Data (Custom Mapping Cleanup Is Handled By afterScenario)
    * def v = call cleanupOrderData { orderId: "#(orderId)" }
