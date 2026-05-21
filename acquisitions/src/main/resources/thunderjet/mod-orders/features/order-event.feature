# For MODAUD-144
Feature: mod audit order events

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

    * configure retry = { count: 10, interval: 5000 }

    * callonce variables


  Scenario: mod audit order events
    * def orderId = call uuid

    # 1. Create Order event
    * call createOrder { id: #(orderId) }

    # 2. Check event saved in audit
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/order/', orderId
    And retry until response.totalItems == 1
    When method GET
    Then status 200

    And match response.orderAuditEvents[0].orderId == orderId
    And match response.orderAuditEvents[0].action == "Create"

    # 3. PUT order event
    * configure headers = headersUser
    * def v = call updateOrder { id: '#(orderId)' }

    # 4. Check 2 events saved in audit
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/order/' + orderId
    And retry until response.totalItems == 2
    When method GET
    Then status 200

    And match response.orderAuditEvents[0].orderId == orderId
    And match response.totalItems == 2
