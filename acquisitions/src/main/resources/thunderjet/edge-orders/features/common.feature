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
    * def apiKey = generateApiKey('testedgeorders', 'test-user')
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: Get endpoints
    * table endpoints
      | endpoint                                   | label                   | offset | limit | jsonKey                |
      | "/orders/order-templates"                  | "no offset & limit"     | ""     | ""    | "orderTemplates"       |
      | "/orders/order-templates"                  | "with offset only"      | 0      | ""    | "orderTemplates"       |
      | "/orders/order-templates"                  | "with limit only"       | ""     | 10    | "orderTemplates"       |
      | "/orders/order-templates"                  | "with offset and limit" | 0      | 10    | "orderTemplates"       |
      | "/finance/funds"                           | "no offset & limit"     | ""     | ""    | "funds"                |
      | "/finance/funds"                           | "with offset only"      | 0      | ""    | "funds"                |
      | "/finance/funds"                           | "with limit only"       | ""     | 10    | "funds"                |
      | "/finance/funds"                           | "with offset and limit" | 0      | 10    | "funds"                |
      | "/finance/expense-classes"                 | "no offset & limit"     | ""     | ""    | "expenseClasses"       |
      | "/finance/expense-classes"                 | "with offset only"      | 0      | ""    | "expenseClasses"       |
      | "/finance/expense-classes"                 | "with limit only"       | ""     | 10    | "expenseClasses"       |
      | "/finance/expense-classes"                 | "with offset and limit" | 0      | 10    | "expenseClasses"       |
      | "/orders/acquisitions-units"               | "no offset & limit"     | ""     | ""    | "acquisitionsUnits"    |
      | "/orders/acquisitions-units"               | "with offset only"      | 0      | ""    | "acquisitionsUnits"    |
      | "/orders/acquisitions-units"               | "with limit only"       | ""     | 10    | "acquisitionsUnits"    |
      | "/orders/acquisitions-units"               | "with offset and limit" | 0      | 10    | "acquisitionsUnits"    |
      | "/orders/acquisition-methods"              | "no offset & limit"     | ""     | ""    | "acquisitionMethods"   |
      | "/orders/acquisition-methods"              | "with offset only"      | 0      | ""    | "acquisitionMethods"   |
      | "/orders/acquisition-methods"              | "with limit only"       | ""     | 10    | "acquisitionMethods"   |
      | "/orders/acquisition-methods"              | "with offset and limit" | 0      | 10    | "acquisitionMethods"   |
      | "/organizations"                           | "no offset & limit"     | ""     | ""    | "organizations"        |
      | "/organizations"                           | "with offset only"      | 0      | ""    | "organizations"        |
      | "/organizations"                           | "with limit only"       | ""     | 10    | "organizations"        |
      | "/organizations"                           | "with offset and limit" | 0      | 10    | "organizations"        |
      | "/orders/addresses/billing-and-shipping"   | "no offset & limit"     | ""     | ""    | "items"                |
      | "/orders/addresses/billing-and-shipping"   | "with offset only"      | 0      | ""    | "items"                |
      | "/orders/addresses/billing-and-shipping"   | "with limit only"       | ""     | 10    | "items"                |
      | "/orders/addresses/billing-and-shipping"   | "with offset and limit" | 0      | 10    | "items"                |
      | "/orders/custom-fields"                    | "no offset & limit"     | ""     | ""    | "customFields"         |
      | "/orders/custom-fields"                    | "with offset only"      | 0      | ""    | "customFields"         |
      | "/orders/custom-fields"                    | "with limit only"       | ""     | 10    | "customFields"         |
      | "/orders/custom-fields"                    | "with offset and limit" | 0      | 10    | "customFields"         |
      | "/locations-for-order"                     | "no offset & limit"     | ""     | ""    | "locations"            |
      | "/locations-for-order"                     | "with offset only"      | 0      | ""    | "locations"            |
      | "/locations-for-order"                     | "with limit only"       | ""     | 10    | "locations"            |
      | "/locations-for-order"                     | "with offset and limit" | 0      | 10    | "locations"            |
      | "/material-types-for-order"                | "no offset & limit"     | ""     | ""    | "mtypes"               |
      | "/material-types-for-order"                | "with offset only"      | 0      | ""    | "mtypes"               |
      | "/material-types-for-order"                | "with limit only"       | ""     | 10    | "mtypes"               |
      | "/material-types-for-order"                | "with offset and limit" | 0      | 10    | "mtypes"               |
      | "/identifier-types-for-order"              | "no offset & limit"     | ""     | ""    | "identifierTypes"      |
      | "/identifier-types-for-order"              | "with offset only"      | 0      | ""    | "identifierTypes"      |
      | "/identifier-types-for-order"              | "with limit only"       | ""     | 10    | "identifierTypes"      |
      | "/identifier-types-for-order"              | "with offset and limit" | 0      | 10    | "identifierTypes"      |
      | "/contributor-name-types-for-order"        | "no offset & limit"     | ""     | ""    | "contributorNameTypes" |
      | "/contributor-name-types-for-order"        | "with offset only"      | 0      | ""    | "contributorNameTypes" |
      | "/contributor-name-types-for-order"        | "with limit only"       | ""     | 10    | "contributorNameTypes" |
      | "/contributor-name-types-for-order"        | "with offset and limit" | 0      | 10    | "contributorNameTypes" |
      | "/users-for-order"                         | "no offset & limit"     | ""     | ""    | "users"                |
      | "/users-for-order"                         | "with offset only"      | 0      | ""    | "users"                |
      | "/users-for-order"                         | "with limit only"       | ""     | 10    | "users"                |
      | "/users-for-order"                         | "with offset and limit" | 0      | 10    | "users"                |
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
    And param fiscalYearCode = "FY2026"
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