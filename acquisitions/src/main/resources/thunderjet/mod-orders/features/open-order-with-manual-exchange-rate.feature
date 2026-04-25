@parallel=false
Feature: Open order with manual exchange rate

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def orderLineIdTwo = callonce uuid5
    * def orderLineIdThree = callonce uuid6

  Scenario: prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 9999 }

  Scenario: Create order
    * def v = call createOrder { id: '#(orderId)' }

  Scenario Outline: Create order lines
    * def v = call createOrderLine { id: '#(<orderLineId>)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: '#(<amount>)', currency: "#(<currency>)", exchangeRate: '#(<exchangeRate>)' }

    Examples:
      | orderLineId      | exchangeRate | amount | currency |
      | orderLineIdOne   | 2.0          | 1      | 'EUR'    |
      | orderLineIdTwo   | 3.0          | 2      | 'RUB'    |
      | orderLineIdThree | null         | 4      | 'USD'    |

  Scenario: Open order
    * def v = call openOrder { orderId: '#(orderId)' }

  Scenario Outline: Check encumbrances transaction
    * configure headers = headersAdmin
    * def poLineId = <orderLineId>

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId+"')]")[0]
    And match transaction.amount == <amount>
    And match transaction.currency == <currency>

    Examples:
      | orderLineId      | amount | currency |
      | orderLineIdOne   | 2.0    | 'USD'    |
      | orderLineIdTwo   | 6.0    | 'USD'    |
      | orderLineIdThree | 4.0    | 'USD'    |
