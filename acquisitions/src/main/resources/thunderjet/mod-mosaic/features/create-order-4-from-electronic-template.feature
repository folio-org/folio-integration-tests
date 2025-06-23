Feature: Create Order From Electronic Template

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
  Scenario: Create Order From Electronic Template
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create an Order Template
    * def templateName = "Template" + orderTemplateId
    Given path "/orders/order-templates"
    And request
      """
      {
        "id": "#(orderTemplateId)",
        "acquisitionMethod": "#(globalApprovalPlanAcqMethodId)",
        "vendor": "#(globalVendorId)",
        "cost": {
          "listUnitPriceElectronic": 49.99,
          "currency": "USD",
          "quantityPhysical": 0,
          "quantityElectronic": 1,
        },
        "eresource": {
          "materialType": "#(globalMaterialTypeIdElec)",
          "accessProvider": "#(globalVendorId)",
          "createInventory": "Instance, Holding"
        },
        "isPackage": false,
        "locations": [
          {
            "locationId": "#(globalLocationsId)",
            "quantityPhysical": 0,
            "quantityElectronic": 1
          }
        ],
        "orderType": "One-Time",
        "instanceId": null,
        "categoryIds": [],
        "orderFormat": "Electronic Resource",
        "checkinItems": false,
        "templateName": "#(templateName)",
        "titleOrPackage": "Test",
        "fundDistribution": [
          {
            "fundId": "#(fundId)",
            "code": "FUND-CODE",
            "distributionType": "percentage",
            "value": 100.0
          }
        ]
      }
      """
    When method POST
    Then status 201

    # 3. Create an Order
    * configure headers = headersUser
    Given path "/mosaic/orders"
    And request
      """
      {
        "orderTemplateId": "#(orderTemplateId)",
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

    # 4. Check Order
    * configure headers = headersAdmin
    Given path "orders/composite-orders"
    And param query = "poNumber==" + poNumber
    When method GET
    Then status 200
    And match $.purchaseOrders == "#[1]"
    And match each $.purchaseOrders[*].template == orderTemplateId
    And match each $.purchaseOrders[*].workflowStatus == "Pending"

    # 5. Check Order Line
    Given path "orders/order-lines"
    And param query = "poLineNumber==" + poLineNumber
    When method GET
    Then status 200
    And match $.poLines == "#[1]"
    And match each $.poLines[*].titleOrPackage == "TestOverride"
    And match each $.poLines[*].cost.listUnitPriceElectronic == 49.99
    And match each $.poLines[*].cost.currency == "USD"
    And match each $.poLines[*].cost.quantityPhysical == 0
    And match each $.poLines[*].cost.quantityElectronic == 1
    And match each $.poLines[*].paymentStatus == 'Pending'
    And match each $.poLines[*].receiptStatus == 'Pending'
    And match each $.poLines[*].checkinItems == false
