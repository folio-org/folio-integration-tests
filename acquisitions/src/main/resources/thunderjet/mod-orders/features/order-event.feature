@parallel=false
#https://issues.folio.org/browse/MODAUD-144
Feature: mod audit order events

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * callonce variables
    * def orderId = callonce uuid

  Scenario: Create Order event
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * callonce createOrder { id: #(orderId) }

  Scenario: Check event saved in audit
    Given path 'audit-data/acquisition/order/', orderId
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
    When method GET
    Then status 200

    And match response.orderAuditEvents[0].orderId == orderId
    And match response.totalItems == 2
