@parallel=false
Feature: Claiming Active/Claiming interval checks

  Background:
    * print karate.info.scenarioName

    * url baseUrl
#    * callonce dev {tenant: 'testorders1'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Create finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }


  Scenario: Create an order
    * print "Create an order"
    * def v = call createOrder { id: #(orderId) }

  Scenario: Create an order line
    * print "Create an order line"

    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.cost.listUnitPrice = 10
    * set poLine.claimingActive = true
    * set poLine.claimingInterval = 1

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  Scenario: Validate claim in title
    * print "Validate claim in title"
    * print "Validate that metadata is populated"

    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def title = $.titles[0]
    * def titleId = title.id
    And match title.claimingActive == true
    And match title.claimingInterval == 1
    And match title.metadata.createdDate != null
    And match title.metadata.createdByUserId != null

  Scenario: Update claim for poLine
    * print "Update claim for poLine"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.claimingInterval = 2

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

  Scenario: Validate claim in title after poLine updated and update title
    * print "Validate claim in title after poLine updated and update title"

    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def title = $.titles[0]
    * def titleId = title.id
    And match title.claimingActive == true
    And match title.claimingInterval == 1

    # update claimingInterval in title
    * set title.claimingInterval = 3
    Given path 'orders/titles', titleId
    And request title
    When method PUT
    Then status 204

  Scenario: Validate claim in poLine after title updated
    * print "Validate claim in poLine after title updated"

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    And match poLine.claimingInterval == 2
