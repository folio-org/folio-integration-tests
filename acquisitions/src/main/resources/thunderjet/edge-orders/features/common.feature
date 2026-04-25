@parallel=false
Feature: Edge Orders COMMON

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json, text/plain", "x-okapi-tenant": "#(testTenant)" }

    * callonce variables

    * def generateApiKey =
      """
      function(tenant, user) {
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var randomS = '';
        for (var i = 0; i < 16; i++) {
          randomS += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        var payload = {"s":randomS,"t":tenant,"u":user};
        var payloadString = JSON.stringify(payload);
        var bytes = new java.lang.String(payloadString).getBytes('UTF-8');
        var Base64 = Java.type('java.util.Base64');
        var encoded = Base64.getEncoder().encodeToString(bytes);
        return encoded;
      }
      """
    * def apiKey = generateApiKey(testTenant, testEdgeUser)
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: Get endpoints
    * table endpoints
      | endpoint                                   | label                   | offset | limit | type     | jsonKey                |
      | "/orders/order-templates"                  | "no offset & limit"     | ""     | ""    | "COMMON" | "orderTemplates"       |
      | "/orders/order-templates"                  | "with offset only"      | 0      | ""    | "COMMON" | "orderTemplates"       |
      | "/orders/order-templates"                  | "with limit only"       | ""     | 10    | "COMMON" | "orderTemplates"       |
      | "/orders/order-templates"                  | "with offset and limit" | 0      | 10    | "COMMON" | "orderTemplates"       |
      | "/finance/funds"                           | "no offset & limit"     | ""     | ""    | "COMMON" | "funds"                |
      | "/finance/funds"                           | "with offset only"      | 0      | ""    | "COMMON" | "funds"                |
      | "/finance/funds"                           | "with limit only"       | ""     | 10    | "COMMON" | "funds"                |
      | "/finance/funds"                           | "with offset and limit" | 0      | 10    | "COMMON" | "funds"                |
      | "/finance/expense-classes"                 | "no offset & limit"     | ""     | ""    | "COMMON" | "expenseClasses"       |
      | "/finance/expense-classes"                 | "with offset only"      | 0      | ""    | "COMMON" | "expenseClasses"       |
      | "/finance/expense-classes"                 | "with limit only"       | ""     | 10    | "COMMON" | "expenseClasses"       |
      | "/finance/expense-classes"                 | "with offset and limit" | 0      | 10    | "COMMON" | "expenseClasses"       |
      | "/orders/acquisitions-units"               | "no offset & limit"     | ""     | ""    | "COMMON" | "acquisitionsUnits"    |
      | "/orders/acquisitions-units"               | "with offset only"      | 0      | ""    | "COMMON" | "acquisitionsUnits"    |
      | "/orders/acquisitions-units"               | "with limit only"       | ""     | 10    | "COMMON" | "acquisitionsUnits"    |
      | "/orders/acquisitions-units"               | "with offset and limit" | 0      | 10    | "COMMON" | "acquisitionsUnits"    |
      | "/orders/acquisition-methods"              | "no offset & limit"     | ""     | ""    | "COMMON" | "acquisitionMethods"   |
      | "/orders/acquisition-methods"              | "with offset only"      | 0      | ""    | "COMMON" | "acquisitionMethods"   |
      | "/orders/acquisition-methods"              | "with limit only"       | ""     | 10    | "COMMON" | "acquisitionMethods"   |
      | "/orders/acquisition-methods"              | "with offset and limit" | 0      | 10    | "COMMON" | "acquisitionMethods"   |
      | "/organizations"                           | "no offset & limit"     | ""     | ""    | "COMMON" | "organizations"        |
      | "/organizations"                           | "with offset only"      | 0      | ""    | "COMMON" | "organizations"        |
      | "/organizations"                           | "with limit only"       | ""     | 10    | "COMMON" | "organizations"        |
      | "/organizations"                           | "with offset and limit" | 0      | 10    | "COMMON" | "organizations"        |
      | "/orders/addresses/billing-and-shipping"   | "no offset & limit"     | ""     | ""    | "COMMON" | "configs"              |
      | "/orders/addresses/billing-and-shipping"   | "with offset only"      | 0      | ""    | "COMMON" | "configs"              |
      | "/orders/addresses/billing-and-shipping"   | "with limit only"       | ""     | 10    | "COMMON" | "configs"              |
      | "/orders/addresses/billing-and-shipping"   | "with offset and limit" | 0      | 10    | "COMMON" | "configs"              |
      | "/orders/custom-fields"                    | "no offset & limit"     | ""     | ""    | "COMMON" | "customFields"         |
      | "/orders/custom-fields"                    | "with offset only"      | 0      | ""    | "COMMON" | "customFields"         |
      | "/orders/custom-fields"                    | "with limit only"       | ""     | 10    | "COMMON" | "customFields"         |
      | "/orders/custom-fields"                    | "with offset and limit" | 0      | 10    | "COMMON" | "customFields"         |
    * def v = call checkEndpoint endpoints

  @Positive
  Scenario: Get fund codes expense classes (default Fiscal Year series)
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    And path "/finance/fund-codes-expense-classes"
    And param type = "COMMON"
    And param apiKey = apiKey
    Then retry until responseStatus == 200
    When method GET
    And match response.fundCodeVsExpClassesTypes == "#present"
    And match response.fundCodeVsExpClassesTypes == "#notnull"
    And assert response.fundCodeVsExpClassesTypes.length > 0

  @Positive
  Scenario: Get fund codes expense classes (Fiscal Year series FY2026)
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    And path "/finance/fund-codes-expense-classes"
    And param type = "COMMON"
    And param apiKey = apiKey
    And param fiscalYearCode = "FY2027"
    Then retry until responseStatus == 200
    When method GET
    And match response.fundCodeVsExpClassesTypes == "#present"
    And match response.fundCodeVsExpClassesTypes == "#notnull"
    And assert response.fundCodeVsExpClassesTypes.length == 0

  @Negative
  Scenario: Get order templates (missing endpoint)
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    And path "/orders/templates"
    And param type = "COMMON"
    And param apiKey = apiKey
    And param offset = 0
    And param limit = 10
    Then retry until responseStatus == 404
    When method GET
    And match response contains "<html><body><h1>Resource not found</h1></body></html>"