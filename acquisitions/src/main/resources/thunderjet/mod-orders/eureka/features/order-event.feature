@parallel=false
#https://issues.folio.org/browse/MODAUD-144
Feature: mod audit order events

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin
    * callonce variables
    * def orderId = callonce uuid

    * configure retry = { count: 10, interval: 5000 }

  Scenario: Create Order event
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * callonce createOrder { id: #(orderId) }

  Scenario: Check event saved in audit
    Given path 'audit-data/acquisition/order/', orderId
    And retry until response.totalItems == 1
    When method GET
    Then status 200

    And match response.orderAuditEvents[0].orderId == orderId
    And match response.orderAuditEvents[0].action == "Create"

  Scenario: PUT order event
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check 2 events saved in audit
    Given path 'audit-data/acquisition/order/' + orderId
    And retry until response.totalItems == 2
    When method GET
    Then status 200

    And match response.orderAuditEvents[0].orderId == orderId
    And match response.totalItems == 2
