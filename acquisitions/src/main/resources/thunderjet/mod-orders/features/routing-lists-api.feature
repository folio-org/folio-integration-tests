# for https://folio-org.atlassian.net/browse/MODORDERS-1006
Feature: Test routing list API

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2
    * def fundId = callonce uuid3

    * def rListId = callonce uuid4
    * def rListUserId = callonce uuid5

    * def rListSample = read('classpath:samples/mod-orders/routingLists/a1d13648-347b-4ac9-8c2f-5bc47248b87e.json')
    * set rListSample.id = rListId;
    * set rListSample.poLineId = poLineId;

    * def createOrder = read('../reusable/create-order.feature')
    * def createOrderLine = read('../reusable/create-order-line.feature')

    * callonce createOrder { id: #(orderId) }
    * callonce createOrderLine { id: #(poLineId), orderId: #(orderId) }


  @Positive
  Scenario: Add new routing list
    Given path '/orders/routing-lists'
    And request rListSample
    When method POST
    Then status 200


  @Positive
  Scenario: Get new routing list by id
    Given path '/orders/routing-lists/', rListId
    When method GET
    Then status 200
    And match $.id == '#(rListId)'
    And match $.name == 'Biography room'
    And match $.poLineId == '#(poLineId)'


  @Positive
  Scenario: Edit new routing list
    * set rListSample.name = 'List 1 edited';
    Given path '/orders/routing-lists/', rListId
    And request rListSample
    When method PUT
    Then status 204


  @Positive
  Scenario: Get edited routing list by id
    Given path '/orders/routing-lists/', rListId
    When method GET
    Then status 200
    And match $.id == '#(rListId)'
    And match $.name == 'List 1 edited'


  @Positive
  Scenario: Get edited routing list by query
    # Query for original routing list
    Given path '/orders/routing-lists/'
    And param query = 'name=="Biography room"'
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
    And match $.totalRecords == 1


  @Positive
  Scenario: Remove routing list
    Given path '/orders/routing-lists/', rListId
    When method DELETE
    Then status 204


  @Positive
  Scenario: Get all routing lists
    Given path '/orders/routing-lists'
    When method GET
    Then status 200
    And match $.routingLists == []
    And match $.totalRecords == 0


  @Negative
  Scenario: Get nonexistent routing list by id
    Given path '/orders/routing-lists/', rListId
    When method GET
    Then status 404


  @Negative
  Scenario: Delete nonexistent routing list by id
    Given path '/orders/routing-lists/', rListId
    When method DELETE
    Then status 404


  @Negative
  Scenario: Add new routing list with POL limit reached
    # Add initial list
    Given path '/orders/routing-lists'
    And request rListSample
    When method POST
    Then status 200

    # POL has reached routing list limit, new one fails validation
    * set rListSample.id = callonce uuid6;
    * set rListSample.name = 'List new name';
    Given path '/orders/routing-lists'
    And request rListSample
    When method POST
    Then status 422
    And match response.errors[0].code == 'routingListLimitReachedForPoLine'

    # Remove first list
    Given path '/orders/routing-lists/', rListId
    When method DELETE
    Then status 204


  @Negative
  Scenario: Add new routing list with POL limit reached
    # Create POL with invalid order format
    * def orderId2 = callonce uuid7
    * def poLineId2 = callonce uuid8
    * call createOrder { id: #(orderId2) }

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-electronic-line.json')
    * set orderLine.id = poLineId2
    * set orderLine.purchaseOrderId = orderId2
    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    # Order has invalid format, Routing list fails validation
    * set rListSample.name = 'List new name 2';
    * set rListSample.poLineId = poLineId2;
    Given path '/orders/routing-lists'
    And request rListSample
    When method POST
    Then status 422
    And match response.errors[0].code == 'invalidRoutingListForPoLineFormat'

