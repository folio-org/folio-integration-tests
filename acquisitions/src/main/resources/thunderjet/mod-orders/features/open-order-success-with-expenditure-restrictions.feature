# Created for MODORDERS-1049
# Related to MODORDERS-528 and open-order-failure-side-effects.feature
# Updated to reverse expected result for MODFISTO-472
Feature: Open order success with expenditure restrictions

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


  Scenario: Open order success with expenditure restrictions
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleOrPackage = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(globalFiscalYearId)", restrictEncumbrance: false, restrictExpenditures: true }
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 5 }

    # 2. Create an order and line going over budget
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10, titleOrPackage: titleOrPackage }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Check a piece was created during the open order operation
    * print 'Check pieces'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
