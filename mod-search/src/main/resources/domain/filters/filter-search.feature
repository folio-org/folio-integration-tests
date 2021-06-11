Feature: Tests for filter terms

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario: Can search by languages filter
    Given path '/search/instances'
    And param query = 'languages=="eng"'
    When method GET
    Then status 200
    Then match response.totalRecords == 2

  Scenario: Can search by item status filter
    Given path '/search/instances'
    And param query = 'items.status.name=="Available"'
    And param expandAll = true
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].items[0].id == '7212ba6a-8dcf-45a1-be9a-ffaa847c4423'