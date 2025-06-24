Feature: Create Order With Open Workflow Status

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json, text/plain", "x-okapi-tenant": "#(testTenant)" }

    * callonce variables

  @Positive
  Scenario: Create Order With Open Workflow Status (set in Mosaic Order)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create an Order Template
    * def orderTemplate = read('classpath:samples/mod-mosaic/physical-order-template.json')
    * set orderTemplate.workflowStatus = "Pending"
    Given path "/orders/order-templates"
    And request orderTemplate
    When method POST
    Then status 201

    # 3. Create Mosaic Order
    * configure headers = headersUser
    Given path "/mosaic/orders"
    And request
      """
      {
        "orderTemplateId": "#(orderTemplateId)",
        "orderData": {
          "title": "TestOverride",
          "workflowStatus": "Open"
        }
      }
      """
    When method POST
    Then status 201
    * def poLineNumber = $
    * def delimiter = poLineNumber.lastIndexOf("-")
    * def poNumber = poLineNumber.substr(0, delimiter)

    # 4. Check Order
    * configure headers = headersAdmin
    * def v = call checkOrder { poNumber: "#(poNumber)", orderTemplateId: "#(orderTemplateId)", workflowStatus: "Open" }

    # 5. Check Order Line
    * def assertOrderPoLine = { poLineNumber: "#(poLineNumber)", titleOrPackage: "TestOverride", listUnitPrice: 49.99, quantityPhysical: 1, paymentStatus: "Awaiting Payment", receiptStatus: "Awaiting Receipt" }
    * def v = call checkOrderLine assertOrderPoLine