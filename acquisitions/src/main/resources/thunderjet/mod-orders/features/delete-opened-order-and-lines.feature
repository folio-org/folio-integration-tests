Feature: Delete opened order and lines

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Delete order line after order is opened

    * def fundId1 = call uuid
    * def budgetId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId1)' }
    * def v = call createBudget { id: '#(budgetId1)', allocated: 1000, fundId: '#(fundId1)', status: 'Active' }
    * def v = call createFund { id: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId2)', allocated: 1000, fundId: '#(fundId2)', status: 'Active' }

    # 2. Create opened order with 2 lines
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": "#(orderId)",
      "orderType": "One-Time",
      "vendor": "#(globalVendorId)",
      "workflowStatus": "Open",
      "poLines": [
        {
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "orderFormat": "Other",
          "source": "EDI",
          "cost": {
            "listUnitPrice": 100,
            "currency": "USD",
            "quantityPhysical": 1
          },
          "physical": {
            "createInventory": "None"
          },
          "titleOrPackage": "Title1",
          "isPackage": false,
          "fundDistribution": [
            {
              "code": "TST-FND",
              "fundId": "#(fundId1)",
              "distributionType": "percentage",
              "value": 100.0
            }
          ]
        },
        {
          "id": "#(orderLineId)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "orderFormat": "Other",
          "source": "EDI",
          "cost": {
            "listUnitPrice": 300,
            "currency": "USD",
            "quantityPhysical": 1
          },
          "physical": {
            "createInventory": "None"
          },
          "titleOrPackage": "Title2",
          "isPackage": false,
          "fundDistribution": [
            {
              "code": "TST-FND",
              "fundId": "#(fundId1)",
              "distributionType": "percentage",
              "value": 80.0
            },
            {
              "code": "TST-FND-2",
              "fundId": "#(fundId2)",
              "distributionType": "percentage",
              "value": 20.0
            }
          ]
        }
      ]
    }
    """
    When method POST
    Then status 201

    # 3. Check finances after creating order
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions == '#[3]'

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId1 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * def availableBefore1 = response.budgets[0].available
    * def unavailableBefore1 = response.budgets[0].unavailable
    * def encumbered1 = response.budgets[0].encumbered

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId2 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * def availableBefore2 = response.budgets[0].available
    * def unavailableBefore2 = response.budgets[0].unavailable
    * def encumbered2 = response.budgets[0].encumbered

    # 4. Delete order line
    * configure headers = headersUser
    Given  path 'orders/order-lines/', orderLineId
    When method DELETE
    Then status 204

    # 5. Check finances after deleting order line
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions == '#[1]'

    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + orderLineId
    When method GET
    Then status 200
    And match response.transactions == '#[0]'

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId1 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore1 + 240
    * match response.budgets[0].unavailable == unavailableBefore1 - 240
    * match response.budgets[0].encumbered == encumbered1 - 240

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId2 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore2 + 60
    * match response.budgets[0].unavailable == unavailableBefore2 - 60
    * match response.budgets[0].encumbered == encumbered2 - 60

    # 6. Delete order
    * configure headers = headersUser
    Given  path 'orders/composite-orders/', orderId
    When method DELETE
    Then status 204

    # 7. Check finances after deleting order
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions == '#[0]'

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId1 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore1 + 240 + 100
    * match response.budgets[0].unavailable == unavailableBefore1 - 240 - 100
    * match response.budgets[0].encumbered == encumbered1 - 240 - 100

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId2 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore2 + 60
    * match response.budgets[0].unavailable == unavailableBefore2 - 60
    * match response.budgets[0].encumbered == encumbered2 - 60



