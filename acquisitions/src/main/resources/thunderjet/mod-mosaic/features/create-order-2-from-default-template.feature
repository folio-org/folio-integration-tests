@parallel=false
Feature: Create Order From Default Template

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
  Scenario: Create Order From Default Template
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def mosaicConfigurationId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Order Template
    * def orderTemplate = read("classpath:samples/mod-mosaic/physical-order-template.json")
    Given path "/orders/order-templates"
    And request orderTemplate
    When method POST
    Then status 201

    # 3. Create Mosaic Order Configuration (default Order Template)
    Given path "/mosaic/configuration"
    And request { "id": "#(mosaicConfigurationId)", "defaultTemplateId": "#(orderTemplateId)" }
    When method PUT
    Then status 204

    Given path "/mosaic/configuration"
    When method GET
    Then status 200
    And match $.defaultTemplateId == orderTemplateId

    # 4. Create Mosaic Order
    * configure headers = headersUser
    Given path "/mosaic/orders"
    And request
      """
      {
        "orderData": {
          "title": "TestOverride"
        }
      }
      """
    When method POST
    Then status 201
    * def poLineNumber = $
    * def delimiter = poLineNumber.lastIndexOf("-")
    * def poNumber = poLineNumber.substr(0, delimiter)

    # 5. Check Order
    * configure headers = headersAdmin
    * def v = call checkOrder { poNumber: "#(poNumber)", orderTemplateId: "#(orderTemplateId)" }

    # 6. Check Order Line
    * def assertOrderPoLine = { poLineNumber: "#(poLineNumber)", titleOrPackage: "TestOverride", listUnitPrice: 49.99, quantityPhysical: 1 }
    * def v = call checkOrderLine assertOrderPoLine

  @Negative
  Scenario: Create Order From Default Template (missing Mosaic Configuration)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def mosaicConfigurationId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Order Template
    * def orderTemplate = read("classpath:samples/mod-mosaic/physical-order-template.json")
    Given path "/orders/order-templates"
    And request orderTemplate
    When method POST
    Then status 201

    # 3. Set Mosaic Order Configuration to non-existent template (simulate missing configuration)
    * def nonExistentTemplateId = call uuid
    Given path "/mosaic/configuration"
    And request { "id": "#(mosaicConfigurationId)", "defaultTemplateId": "#(nonExistentTemplateId)" }
    When method PUT
    Then status 204

    Given path "/mosaic/configuration"
    When method GET
    Then status 200
    And match $.defaultTemplateId == nonExistentTemplateId

    # 4. Create Mosaic Order
    * configure headers = headersUser
    Given path "/mosaic/orders"
    And request
      """
      {
        "orderData": {
          "title": "TestOverride"
        }
      }
      """
    When method POST
    Then status 404
    And match $.errors == "#[1]"
    And match each $.errors[*].code == "notFoundError"
    And match each $.errors[*].message == "Resource of type 'OrderTemplate' is not found"
