Feature: Create Order From Minimal Template

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
    * configure headers = headersUser
    Given path "/mosaic/orders"
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
    Then status 201
    * def poLineNumber = $
    * def delimiter = poLineNumber.lastIndexOf("-")
    * def poNumber = poLineNumber.substr(0, delimiter)

    # 4. Check Order
    * configure headers = headersAdmin
    * def v = call checkOrder { poNumber: "#(poNumber)", orderTemplateId: "#(orderTemplateId)" }

    # 5. Check Order Line
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
    * configure headers = headersUser
    Given path "/mosaic/orders"
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
    Then status 404
    And match $.errors == "#[1]"
    And match each $.errors[*].code == "notFoundError"
    And match each $.errors[*].message == "Resource of type 'OrderTemplate' is not found"

  @Positive
  Scenario: Create Order From Minimal Template (has intersecting fields, values are overriden)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Order Template
    Given path "/orders/order-templates"
    And request
      """
      {
        "id": "#(orderTemplateId)",
        "templateName": "#(templateName)",
        "locations": [
          {
            "locationId": "#(globalLocationsId)",
            "quantityPhysical": 1,
            "quantityElectronic": 0
          }
        ],
        "fundDistribution": [
          {
            "fundId": "#(fundId)",
            "code": "FUND-CODE",
            "value": 100.0,
            "distributionType": "percentage"
          }
        ]
      }
      """
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
          "acquisitionMethod": "#(globalApprovalPlanAcqMethodId)",
          "vendor": "#(globalVendorId)",
          "listUnitPrice": 499.99,
          "currency": "USD",
          "quantityPhysical": 2,
          "quantityElectronic": 0,
          "locations": [
            {
              "locationId": "#(globalLocationsId)",
              "quantityPhysical": 2,
              "quantityElectronic": 0
            }
          ],
          "physical": {
            "materialType": "#(globalMaterialTypeIdPhys)",
            "materialSupplier": "#(globalVendorId)",
            "createInventory": "Instance, Holding, Item",
            "volumes": []
          },
          "format": "Physical Resource",
          "checkinItems": false,
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
    * def v = call checkOrder { poNumber: "#(poNumber)", orderTemplateId: "#(orderTemplateId)" }

    # 5. Check Order Line
    * def assertOrderPoLine = { poLineNumber: "#(poLineNumber)", titleOrPackage: "TestOverride", listUnitPrice: 499.99, quantityPhysical: 2 }
    * def v = call checkOrderLine assertOrderPoLine

  @Negative
  Scenario: Create Order From Minimal Template (validation error on override)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Order Template
    Given path "/orders/order-templates"
    And request
      """
      {
        "id": "#(orderTemplateId)",
        "templateName": "#(templateName)",
        "locations": [
          {
            "locationId": "#(globalLocationsId)",
            "quantityPhysical": 1,
            "quantityElectronic": 0
          }
        ],
        "fundDistribution": [
          {
            "fundId": "#(fundId)",
            "code": "FUND-CODE",
            "value": 100.0,
            "distributionType": "percentage"
          }
        ]
      }
      """
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
          "acquisitionMethod": "#(globalApprovalPlanAcqMethodId)",
          "vendor": "#(globalVendorId)",
          "listUnitPrice": 499.99,
          "currency": "USD",
          "quantityPhysical": 2,
          "quantityElectronic": 0,
          "physical": {
            "materialType": "#(globalMaterialTypeIdPhys)",
            "materialSupplier": "#(globalVendorId)",
            "createInventory": "Instance, Holding, Item",
            "volumes": []
          },
          "format": "Physical Resource",
          "checkinItems": false,
          "title": "TestOverride"
        }
      }
      """
    When method POST
    Then status 422
    And match $.errors == "#[1]"
    And match each $.errors[*].code == "validationError"
    And match each $.errors[*].message contains "PO Line physical quantity and Locations physical quantity do not match"

  @Positive
  Scenario: Create Order From Minimal Template (no intersecting fields, values are combined)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderTemplateId = call uuid
    * def templateName = "Template" + orderTemplateId

    # 1. Create Funds and Budgets
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)", "ledgerId": "#(globalLedgerWithRestrictionsId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 1000, "fundId": "#(fundId)", "status": "Active" }

    # 2. Create Order Template
    Given path "/orders/order-templates"
    And request
      """
      {
        "id": "#(orderTemplateId)",
        "templateName": "#(templateName)",
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
        "fundDistribution": [
          {
            "fundId": "#(fundId)",
            "code": "FUND-CODE",
            "value": 100.0,
            "distributionType": "percentage"
          }
        ]
      }
      """
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
          "acquisitionMethod": "#(globalApprovalPlanAcqMethodId)",
          "vendor": "#(globalVendorId)",
          "listUnitPrice": 4999.99,
          "currency": "USD",
          "quantityPhysical": 1,
          "quantityElectronic": 0,
          "format": "Physical Resource",
          "checkinItems": false,
          "title": "TestCombined",
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
    * def v = call checkOrder { poNumber: "#(poNumber)", orderTemplateId: "#(orderTemplateId)" }

    # 5. Check Order Line
    * def assertOrderPoLine = { poLineNumber: "#(poLineNumber)", titleOrPackage: "TestCombined", listUnitPrice: 4999.99, quantityPhysical: 1 }
    * def v = call checkOrderLine assertOrderPoLine