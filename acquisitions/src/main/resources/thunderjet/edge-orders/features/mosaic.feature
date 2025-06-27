@parallel=false
Feature: Edge Orders MOSAIC

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json, text/plain", "x-okapi-tenant": "#(testTenant)" }

    * callonce variables
    * def apiKey = "eyJzIjoiZmxpcGFZTTdLcG9wbWhGbEYiLCJ0IjoidGVzdGVkZ2VvcmRlcnMiLCJ1IjoidGVzdC11c2VyIn0="
    * def badApiKey = "eyJzIjoiRVVFMnFjMGlZemVDcHpkYngiLCJ0IjoidGVzdGVkZ2VvcmRlcnMiLCJ1IjoidGVzdC1iYWQtdXNlciJ9"
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: Validate Order apiKey
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    And path "mosaic/validate"
    And param type = "MOSAIC"
    And param apiKey = apiKey
    When method GET
    Then retry until responseStatus == 200
    And match $.status == "SUCCESS"

  @Negative
  Scenario: Validate Order apiKey (missing type)
    * url edgeUrl
    * configure headers = { "Accept": "application/xml" }
    And path "mosaic/validate"
    When method GET
    Then retry until responseStatus == 400
    And match /Response/Error/Code == "BAD_REQUEST"
    And match /Response/Error/Message == "Missing required parameter: type"

  @Negative
  Scenario: Validate Order apiKey (missing apikey)
    * url edgeUrl
    * configure headers = { "Accept": "application/xml" }
    And path "mosaic/validate"
    And param type = "MOSAIC"
    When method GET
    Then retry until responseStatus == 401
    And match /Response/Error/Code == "API_KEY_INVALID"
    And match /Response/Error/Message contains "Invalid API Key"

  @Negative
  Scenario: Validate Order apiKey (bad apikey)
    * url edgeUrl
    * configure headers = { "Accept": "application/xml" }
    And path "mosaic/validate"
    And param type = "MOSAIC"
    And param apiKey = badApiKey
    When method GET
    Then retry until responseStatus == 401
    And match /Response/Error/Code == "ACCESS_DENIED"
    And match /Response/Error/Message contains "Access Denied"

  @Positive
  Scenario: Create Order From Minimal Template
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Order Template
    * url baseUrl
    Given path "/orders/order-templates"
    And request
      """
      {
        "id": "#(orderTemplateId)",
        "templateName": "#(templateName)",
      }
      """
    When method POST
    Then status 201

    # 3. Create Mosaic Order
    * url edgeUrl
    * configure headers = { "Content-Type": "application/json", "Accept": "application/json" }
    Given path "/mosaic/orders"
    And param type = "MOSAIC"
    And param apiKey = apiKey
    And request
      """
      {
        "orderTemplateId": "#(orderTemplateId)",
        "orderData": {
          "acquisitionMethod": "#(globalApprovalPlanAcqMethodId)",
          "vendor": "#(globalVendorId)",
          "listUnitPrice": 49.99,
          "currency": "USD",
          "quantityPhysical": 1,
          "quantityElectronic": 0,
          "physical": {
            "materialType": "#(globalMaterialTypeIdPhys)",
            "materialSupplier": "#(globalVendorId)",
            "createInventory": "Instance, Holding, Item",
            "volumes": []
          },
          "locations": [
            {
              "locationId": "#(globalLocationsId)",
              "quantityPhysical": 1,
              "quantityElectronic": 0
            }
          ],
          "format": "Physical Resource",
          "checkinItems": false,
          "title": "Test",
          "fundDistribution": [
            {
              "fundId": "#(fundId)",
              "code": "FUND-CODE",
              "value": 100.0,
              "distributionType": "percentage"
            }
          ]
        }
      }
      """
    When method POST
    Then retry until responseStatus == 201
    * def poLineNumber = $
    * def delimiter = poLineNumber.lastIndexOf("-")
    * def poNumber = poLineNumber.substr(0, delimiter)

    # 4. Check Order
    * configure headers = headersAdmin
    * url baseUrl
    * def v = call checkOrder { poNumber: "#(poNumber)", orderTemplateId: "#(orderTemplateId)" }

    # 5. Check Order Line
    * url baseUrl
    * def assertOrderPoLine = { poLineNumber: "#(poLineNumber)", titleOrPackage: "Test", listUnitPrice: 49.99, quantityPhysical: 1 }
    * def v = call checkOrderLine assertOrderPoLine

  @Negative
  Scenario: Create Order From Minimal Template (missing Order Template)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Mosaic Order
    * url edgeUrl
    * configure headers = { "Content-Type": "application/json", "Accept": "application/json" }
    Given path "/mosaic/orders"
    And param type = "MOSAIC"
    And param apiKey = apiKey
    And request
      """
      {
        "orderTemplateId": "#(orderTemplateId)",
        "orderData": {
          "acquisitionMethod": "#(globalApprovalPlanAcqMethodId)",
          "vendor": "#(globalVendorId)",
          "listUnitPrice": 49.99,
          "currency": "USD",
          "quantityPhysical": 1,
          "quantityElectronic": 0,
          "physical": {
            "materialType": "#(globalMaterialTypeIdPhys)",
            "materialSupplier": "#(globalVendorId)",
            "createInventory": "Instance, Holding, Item",
            "volumes": []
          },
          "locations": [
            {
              "locationId": "#(globalLocationsId)",
              "quantityPhysical": 1,
              "quantityElectronic": 0
            }
          ],
          "format": "Physical Resource",
          "checkinItems": false,
          "title": "Test",
          "fundDistribution": [
            {
              "fundId": "#(fundId)",
              "code": "FUND-CODE",
              "value": 100.0,
              "distributionType": "percentage"
            }
          ]
        }
      }
      """
    When method POST
    Then retry until responseStatus == 404
    And match $.errors == "#[1]"
    And match each $.errors[*].code == "notFoundError"
    And match each $.errors[*].message == "Resource of type 'OrderTemplate' is not found"

  @Negative
  Scenario: Get orders (missing endpoint)
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    And path "mosaic/orders"
    And param type = "MOSAIC"
    And param apiKey = apiKey
    Then retry until responseStatus == 404
    When method GET
    And match response contains "<html><body><h1>Resource not found</h1></body></html>"