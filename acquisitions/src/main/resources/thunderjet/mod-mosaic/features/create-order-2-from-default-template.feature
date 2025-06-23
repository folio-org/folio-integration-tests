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
          "listUnitPrice": 49.99,
          "currency": "USD",
          "quantityPhysical": 1,
          "quantityElectronic": 0
        },
        "physical": {
          "materialType": "#(globalMaterialTypeIdPhys)",
          "materialSupplier": "#(globalVendorId)",
          "createInventory": "Instance, Holding, Item",
          "volumes": []
        },
        "isPackage": false,
        "locations": [
          {
            "locationId": "#(globalLocationsId)",
            "quantityPhysical": 1,
            "quantityElectronic": 0
          }
        ],
        "orderType": "One-Time",
        "instanceId": null,
        "categoryIds": [],
        "orderFormat": "Physical Resource",
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

    # 3. Set Default Order Template (Mosaic Order Configuration)
    * configure headers = headersUser
    Given path "/mosaic/configuration"
    And request { "id": "#(mosaicConfigurationId)", "defaultTemplateId": "#(orderTemplateId)" }
    When method POST
    Then status 201

    # 4. Set Default Order Template (Mosaic Order Configuration)
    * configure headers = headersUser
    Given path "/mosaic/configuration"
    When method GET
    Then status 200
    And match $.defaultTemplateId == orderTemplateId

    # 5. Create an Order
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

    # 6. Check Order
    * configure headers = headersAdmin
    Given path "orders/composite-orders"
    And param query = "poNumber==" + poNumber
    When method GET
    Then status 200
    And match $.purchaseOrders == "#[1]"
    And match each $.purchaseOrders[*].template == orderTemplateId
    And match each $.purchaseOrders[*].workflowStatus == "Pending"

    # 7. Check Order Line
    Given path "orders/order-lines"
    And param query = "poLineNumber==" + poLineNumber
    When method GET
    Then status 200
    And match $.poLines == "#[1]"
    And match each $.poLines[*].titleOrPackage == "TestOverride"
    And match each $.poLines[*].cost.listUnitPrice == 49.99
    And match each $.poLines[*].cost.currency == "USD"
    And match each $.poLines[*].cost.quantityPhysical == 1
    And match each $.poLines[*].cost.quantityElectronic == 0
    And match each $.poLines[*].paymentStatus == 'Pending'
    And match each $.poLines[*].receiptStatus == 'Pending'
    And match each $.poLines[*].checkinItems == false
