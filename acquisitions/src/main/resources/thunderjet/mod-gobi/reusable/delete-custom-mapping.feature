@ignore
Feature: Delete GOBI custom mapping if it exists
  # parameters: orderType

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Delete Custom Mapping Tolerantly
    Given path '/gobi/orders/custom-mappings', orderType
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    * assert responseStatus == 200 || responseStatus == 404