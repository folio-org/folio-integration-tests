@parallel=false
Feature: Delete opened order and lines

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_orders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def orderId = callonce uuid1
    * def orderLineId = callonce uuid2
#    * def orderId = '9fcfab9c-36e1-4dbd-ac80-6d46578bcb33'
#    * def orderLineId = '1ad26332-74e9-425c-9c66-d4a772a74e4d'


  Scenario: Create opened order with 2 lines
    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": "#(orderId)",
      "orderType": "One-Time",
      "vendor": "#(globalVendorId)",
      "workflowStatus": "Open",
      "compositePoLines": [
        {
          "acquisitionMethod": "Purchase",
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
              "fundId": "#(globalFundId)",
              "distributionType": "percentage",
              "value": 100.0
            }
          ]
        },
        {
          "id": "#(orderLineId)",
          "acquisitionMethod": "Purchase",
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
              "fundId": "#(globalFundId)",
              "distributionType": "percentage",
              "value": 80.0
            },
            {
              "code": "TST-FND-2",
              "fundId": "#(globalFundId2)",
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


  Scenario: Delete order line after order is opened

    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions == '#[3]'

    Given path 'finance/budgets'
    And param query = 'fundId==' + globalFundId + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * def availableBefore1 = response.budgets[0].available
    * def unavailableBefore1 = response.budgets[0].unavailable
    * def encumbered1 = response.budgets[0].encumbered

    Given path 'finance/budgets'
    And param query = 'fundId==' + globalFundId2 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * def availableBefore2 = response.budgets[0].available
    * def unavailableBefore2 = response.budgets[0].unavailable
    * def encumbered2 = response.budgets[0].encumbered

    Given  path 'orders/order-lines/', orderLineId
    When method DELETE
    Then status 204

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
    And param query = 'fundId==' + globalFundId + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore1 + 240
    * match response.budgets[0].unavailable == unavailableBefore1 - 240
    * match response.budgets[0].encumbered == encumbered1 - 240

    Given path 'finance/budgets'
    And param query = 'fundId==' + globalFundId2 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore2 + 60
    * match response.budgets[0].unavailable == unavailableBefore2 - 60
    * match response.budgets[0].encumbered == encumbered2 - 60


    Given  path 'orders/composite-orders/', orderId
    When method DELETE
    Then status 204

    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions == '#[0]'

    Given path 'finance/budgets'
    And param query = 'fundId==' + globalFundId + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore1 + 240 + 100
    * match response.budgets[0].unavailable == unavailableBefore1 - 240 - 100
    * match response.budgets[0].encumbered == encumbered1 - 240 - 100

    Given path 'finance/budgets'
    And param query = 'fundId==' + globalFundId2 + ' and fiscalYearId==' + globalFiscalYearId
    When method GET
    Then status 200
    * match response.budgets[0].available == availableBefore2 + 60
    * match response.budgets[0].unavailable == unavailableBefore2 - 60
    * match response.budgets[0].encumbered == encumbered2 - 60



