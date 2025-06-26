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
    * def apiKey = "eyJzIjoiZmxpcGFZTTdLcG9wbWhGbEYiLCJ0IjoidGVzdGVkZ2VvcmRlcnMiLCJ1IjoidGVzdC11c2VyIn0="

  @Positive
  Scenario: Get endpoints
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    * table endpoints
      | requestUrl                          | offset | limit | object                 |
      | "/orders/order-templates"           | 0      | 10    | "orderTemplates"       |
      | "/finance/funds"                    | 0      | 10    | "funds"                |
      | "/finance/expense-classes"          | 0      | 10    | "expenseClasses"       |
      | "/acquisitions-units"               | 0      | 10    | "acquisitionsUnits"    |
      | "/acquisition-methods"              | 0      | 10    | "acquisitionMethods"   |
      | "/organizations"                    | 0      | 10    | "organizations"        |
      | "/addresses/billing-and-shipping"   | 0      | 10    | "configs"              |
      | "/orders/custom-fields"             | 0      | 10    | "customFields"         |
      | "/locations-for-order"              | 0      | 10    | "locations"            |
      | "/material-types-for-order"         | 0      | 10    | "mtypes"               |
      | "/identifier-types-for-order"       | 0      | 10    | "identifierTypes"      |
      | "/contributor-name-types-for-order" | 0      | 10    | "contributorNameTypes" |
      | "/users-for-order"                  | 0      | 10    | "users"                |
    * def requestBody = createFinanceData(incorrectBudgetStatus[0])
    And path endpoints[0]
    And param type = "COMMON"
    And param apiKey = apiKey
    And param offset = endpoints[1]
    And param limit = endpoints[2]
    And headers { 'Accept': 'application/json' }
    When method GET
    Then status 200
    * def key = endpoints[3]
    And match $[key] != []

  @Positive
  Scenario: Get fund codes expense classes
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    And path "/finance/fund-codes-expense-classes"
    And param type = "COMMON"
    And param apiKey = apiKey
    And headers { 'Accept': 'application/json' }
    When method GET
    Then status 200
    And match $.fundCodeVsExpClassesTypes != []