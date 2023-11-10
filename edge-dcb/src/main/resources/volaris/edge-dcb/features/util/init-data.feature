Feature: init data for edge-rtac

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * callonce variables


  @PostItem
  Scenario: create item
    * def itemEntityRequest = read('classpath:volaris/edge-dcb/features/samples/item/item-entity-request.json')
    Given path 'inventory', 'items'
    And headers headers
    And request itemEntityRequest
    When method POST
    Then status 201
    And def response = response
    And karate.set('itemId', response.id)
    And karate.set('itemBarcode', response.barcode)