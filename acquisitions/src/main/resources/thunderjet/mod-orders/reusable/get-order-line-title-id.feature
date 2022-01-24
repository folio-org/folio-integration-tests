Feature: Get order line title id
  # parameters: poLineId
  # returns: titleId

  Background:
    * url baseUrl

  Scenario: Get order line title id
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id
