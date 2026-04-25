# For MODORDERS-855
Feature: Reopen order with 50 lines

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

    * configure readTimeout = 90000


  Scenario: Reopen order with 50 lines
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    # 2. Create an order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create 50 order lines
    * def lineParameters = []
    * def createParameterArray =
      """
      function() {
        for (let i=0; i<50; i++) {
          lineParameters.push({ id: uuid(), orderId: orderId, fundId: fundId });
        }
      }
      """
    * eval createParameterArray()
    * def v = call createOrderLine lineParameters

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Close the order
    * def v = call closeOrder { orderId: '#(orderId)' }

    # 6. Check the encumbrances were all released
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 50

    # 7. Reopen the order
    * configure headers = headersUser
    * def v = call openOrder { orderId: '#(orderId)' }

    # 8. Check the encumbrances were all unreleased
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 0
