Feature: Query validation
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'

  Scenario: Post query with invalid fql query should return 400 error
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$xy\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].value == "Condition {\"$xy\":[\"missing\",\"lost\"]} contains an invalid operator"

  Scenario: Post query with invalid column name should return 400 error
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"invalid_field\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].key == "invalid_field"
    And match $.parameters[0].value == "Field invalid_field is not present in definition of entity type composite_item_details"

  Scenario: Post query without required parameters should throw '400 Bad Gateway' Response
    Given path 'query'
    When method POST
    Then status 400

  Scenario: Get query with invalid queryId should return '404 Not Found' Response
    * def invalidId = call uuid1
    Given path 'query', invalidId
    When method GET
    Then status 404
