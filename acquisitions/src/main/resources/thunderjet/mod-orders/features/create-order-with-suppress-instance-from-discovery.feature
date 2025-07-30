# For MODORDERS-1321
Feature: Create order with suppress instance from discovery

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }

    * callonce variables

  @Positive
  Scenario: Create order with suppress instance from discovery
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000 }

    # 2. Create Order
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }

    # 3. Create order lines
    * table lines
      | suppressInstanceFromDiscovery |
      | null                          |
      | false                         |
      | true                          |
    * def v = call createOrderLine lines

    # 4. Open the order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Check the order lines
    Given path "orders/composite-orders", orderId
    When method GET
    Then status 200
    * def poLines = $.poLines
    * match poLines[0].suppressInstanceFromDiscovery == false
    * match poLines[1].suppressInstanceFromDiscovery == false
    * match poLines[2].suppressInstanceFromDiscovery == true
