# For MODORDSTOR-524
Feature: Title Record Text Is Updated After Changing Instance Connection

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
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Title Record Text Is Updated After Changing Instance Connection With Move
    # 1. Generate Unique Identifiers For This Test Scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def instanceIdOld = call uuid
    * def instanceIdNew = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def suffix = call random_string
    * def oldTitle = 'Old Instance Title ' + suffix
    * def newTitle = 'New Instance Title ' + suffix

    # 2. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', name: 'Test Fund' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 3. Create Two Instances With Distinct Titles (Old And New)
    * def v = call createInstance { id: '#(instanceIdOld)', title: '#(oldTitle)', instanceTypeId: '#(globalInstanceTypeId)' }
    * def v = call createInstance { id: '#(instanceIdNew)', title: '#(newTitle)', instanceTypeId: '#(globalInstanceTypeId)' }

    # 4. Create Order And Physical Order Line Connected To The Old Instance, Then Open It
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLineWithInstance { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', instanceId: '#(instanceIdOld)', titleOrPackage: '#(oldTitle)' }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Baseline - The Title Record For The PO Line Holds The Old Title And Old Instance
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 1 && response.titles[0].instanceId == instanceIdOld && response.titles[0].title == oldTitle
    When method GET
    Then status 200

    # 6. Change Instance Connection To The New Instance Using "Move" Holdings Operation
    * def v = call changeOrderLineInstanceConnection { poLineId: '#(poLineId)', instanceId: '#(instanceIdNew)', holdingsOperation: 'Move', deleteAbandonedHoldings: false }

    # 7. Verify PO Line Instance Link Was Repointed To The New Instance
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId == instanceIdNew
    When method GET
    Then status 200

    # 8. MODORDSTOR-524 - The Title Record Text Must Now Reflect The New Instance, Not Just The Link
    * def isTitleTextUpdated =
    """
    function(response) {
      return response.totalRecords == 1 &&
             response.titles[0].instanceId == instanceIdNew &&
             response.titles[0].title == newTitle;
    }
    """
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    And retry until isTitleTextUpdated(response)
    When method GET
    Then status 200
