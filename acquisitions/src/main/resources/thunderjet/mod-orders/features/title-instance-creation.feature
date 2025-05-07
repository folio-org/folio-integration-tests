# for https://folio-org.atlassian.net/browse/MODORDERS-1081
Feature: Test instance creation with new title

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

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2
    * def fundId = callonce uuid3
    * def titleId = callonce uuid4

    * callonce createOrder { id: #(orderId) }
    * callonce createOrderLine { id: #(poLineId), orderId: #(orderId), isPackage: true }


  Scenario: New title creates a new instance
    * def newTitle = { title:  "New Title 1" }
    * set newTitle.id = titleId;
    * set newTitle.poLineId = poLineId;

    # Add new title
    Given path '/orders/titles'
    And request newTitle
    When method POST
    Then status 201
    And match response.id == titleId
    And match response.title == "New Title 1"
    And match response.poLineId == poLineId
    And match response.instanceId != "#notpresent"
    * def instId = response.instanceId

    # Check instance creation
    * configure headers = headersAdmin
    Given path '/instance-storage/instances', instId
    When method GET
    Then status 200
    And match response.id == instId
    And match response.title == "New Title 1"

    # Check title by poLineId contains same instance
    * configure headers = headersUser
    Given path '/orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.titles[0].id == titleId
    And match response.titles[0].title == "New Title 1"
    And match response.titles[0].poLineId == poLineId
    And match response.titles[0].instanceId == instId