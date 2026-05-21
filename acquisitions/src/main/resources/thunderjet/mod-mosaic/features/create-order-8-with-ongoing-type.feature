Feature: Create Order With Ongoing Type

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
  Scenario: Create Order With Ongoing Type
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(globalLedgerWithRestrictionsId)" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 1000, fundId: "#(fundId)", status: "Active" }

    # 2. Create an Order Template With Ongoing Type
    * def orderTemplate = read("classpath:samples/mod-mosaic/electronic-order-template.json")
    * set orderTemplate.orderType = "Ongoing"
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
          "workflowStatus": "Open",
          "title": "Advanced Database Systems",
          "listUnitPriceElectronic": 88.88,
          "currency": "USD",
          "quantityElectronic": 1
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
    * def assertOrderPoLine = { poLineNumber: "#(poLineNumber)", titleOrPackage: "Advanced Database Systems", listUnitPriceElectronic: 88.88, quantityElectronic: 1, paymentStatus: "Ongoing", receiptStatus: "Ongoing" }
    * def v = call checkOrderLine assertOrderPoLine
