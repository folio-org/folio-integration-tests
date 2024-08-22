Feature: rtac from order piece tests
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * def createFund = karate.read('util/order/create-fund.feature')
    * def createBudget = karate.read('util/order/create-budget.feature')

    * callonce read('util/order/configuration.feature')
    * callonce read('util/order/finances.feature')
    * callonce read('util/order/organizations.feature')
    * callonce read('util/order/orders.feature')

  Scenario: Get rtac holding from order piece

    # create material type
    * def materialTypeName = call random_string
    * def materialTypeId = call random_uuid
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId), extMaterialTypeName: #(materialTypeName) }

    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid

    # post instance, service point and location
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(servicePointId) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(locationId), extServicePointId: #(servicePointId) }

    # post holding
    * def holdingSourceId = call random_uuid
    * def holdingSourceName = 'FOLIO'
    * def holdingId = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingSourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extHoldingsRecordId: #(holdingId), extLocationId: #(locationId), extInstanceId: #(instanceId) }

    # create fund and budget
    * def fundId = callonce random_uuid
    * def budgetId = callonce random_uuid
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

    # create order
    * def orderId = callonce random_uuid
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostOrder') { extOrderId: #(orderId) }

    # create order line
    * def poLineId = callonce random_uuid
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostOrderLine') { extPoLineId: #(poLineId), extOrderId: #(orderId), extInstanceId: #(instanceId), extFundId: #(fundId), extHoldingId: #(holdingId), extMaterialTypeId: #(materialTypeId) }

    # open order
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@OpenOrder') { extOrderId: #(orderId) }

    # create piece
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostPiece') { extLocationsId: #(locationId), extPoLineId: #(poLineId) }

    Given url edgeUrl
    And path 'rtac'
    And param instanceIds = instanceId
    And param fullPeriodicals = true
    And param apikey = apikey
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match $.holdings[0].holdings[*].status contains 'Expected'