@ignore
Feature: checkEndpoint
  # parameters: endpoint, offset, limit, jsonKey, type (optional)

  Background:
    * url edgeUrl
    * configure headers = { "Accept": "application/json" }
    * karate.log("checkEndpoint:: Endpoint =", endpoint, "Label =", label, "offset =", offset, "limit =", limit, "jsonKey =", jsonKey, "type =", type)

  Scenario: checkEndpoint
    And path endpoint
    And param type = type
    And param apiKey = apiKey
    And param offset = offset
    And param limit = limit
    Then retry until responseStatus == 200
    When method GET
    * def jsonValue = response[jsonKey]
    And match jsonValue == "#present"
    And match jsonValue == "#notnull"
    And assert jsonValue.length >= 0