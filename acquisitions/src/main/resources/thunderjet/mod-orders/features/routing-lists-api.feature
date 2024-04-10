@parallel=false
# for https://folio-org.atlassian.net/browse/MODORDERS-1006
Feature: Test routing list API

  Background:
    * url baseUrl
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4

    * def rListId1 = callonce uuid5
    * def rListId2 = callonce uuid6
    * def rListUserId = callonce uuid7

    * def createOrder = read('../reusable/create-order.feature')
    * def createOrderLine = read('../reusable/create-order-line.feature')

    * configure headers = headersUser

    * callonce closeOrder { orderId: "#(orderId)" }
    * callonce createFund { 'id': '#(fundId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}
    * callonce createOrder { id: "#(orderId)" }
    * callonce createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)" }


  Scenario: Add new routing list
    Given path '/orders/routing-lists'
    And request
    """
    {
      id: '#(orderId)',
      name: 'List 1',
      userIds: [ '#(rListUserId)' ],
      poLineId: '#(poLineId)'
    }
    """
    When method POST
    Then status 201


  Scenario: Get new routing list by id
    Given path '/orders/routing-lists/', '#(rListId)'
    When method GET
    Then status 200
    And match $.id == '#(rListId)'
    And match $.name == 'List 1'
    And match $.userIds[0] == '#(rListUserId)'
    And match $.poLineId == '#(poLineId)'


  Scenario: Edit new routing list
    Given path '/orders/routing-lists/', '#(rListId)'
    And request
    """
    {
      id: '#(orderId)',
      name: 'List 1 edited',
      userIds: [],
      poLineId: '#(poLineId)'
    }
    """
    When method PUT
    Then status 204


  Scenario: Get edited routing list by id
    Given path '/orders/routing-lists/', '#(rListId)'
    When method GET
    Then status 200
    And match $.id == '#(rListId)'
    And match $.name == 'List 1 edited'
    And match $.userIds == []
    And match $.poLineId == '#(poLineId)'


  Scenario: Get edited routing list by query
    # Query for original routing list
    Given path '/orders/routing-lists/'
    And param query = 'name=="List 1"'
    When method GET
    Then status 200
    And match $.routingLists == []
    And match $.totalRecords == 0

    # Query for edited routing list
    Given path '/orders/routing-lists/'
    And param query = 'name=="List 1 edited"'
    When method GET
    Then status 200
    And match $.routingLists[0].id == '#(rListId)'
    And match $.routingLists[0].name == 'List 1 edited'
    And match $.routingLists[0].userIds == []
    And match $.routingLists[0].poLineId == '#(poLineId)'
    And match $.totalRecords == 1


  Scenario: Remove routing list
    Given path '/orders/routing-lists/', '#(rListId)'
    When method DELETE
    Then status 204


  Scenario: Get all routing lists
    Given path '/orders/routing-lists'
    When method GET
    Then status 200
    And match $.routingLists == []
    And match $.totalRecords == 0
