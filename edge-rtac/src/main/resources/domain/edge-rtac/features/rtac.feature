Feature: Loans tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def itemStatusName = 'Available'
    * def periodicalStatus = true
    * def materialTypeId = call random_uuid
    * callonce read('classpath:domain/edge-rtac/features/util/initData.feature@PostMaterialType')

  Scenario: For a non-periodical/non-serial, return holdings and item information including availability for an instance UUID
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 69640328-788e-43fc-9c3c-af39e243f3b7 }
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 79640328-788e-43fc-9c3c-af39e243f3b7 }

    Given path 'rtac/' + instanceId
    When method GET
    Then status 200
    And match response.holdings..id contains [69640328-788e-43fc-9c3c-af39e243f3b7, 79640328-788e-43fc-9c3c-af39e243f3b7]
    And match response.holdings..status contains ['Available' , 'Checked out']

  Scenario: For a non-periodical/non-serial, return holdings and item information including availability for each instance UUID included in request
#   1st instance
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def firstInstanceId = createInstanceResponse.instanceEntityRequest.id
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 68640328-799e-43fc-9c3c-af39e243f3b7 }

#   2nd instance
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def secondInstanceId = createInstanceResponse.instanceEntityRequest.id
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 68640328-788e-53fc-9c3c-af39e243f3b7 }
    * def periodicalStatus = true
    * def rtacBatchrequest = read('samples/rtac-batch-request-entity.json')

    Given path 'rtac-batch'
    And request rtacBatchrequest
    When method POST
    Then status 200
    And match response.holdings..id contains [ 68640328-799e-43fc-9c3c-af39e243f3b7 , 68640328-788e-53fc-9c3c-af39e243f3b7 ]
    And match response.holdings..status contains [ Available , Checked out ]

  Scenario:For periodical/serial, return holdings and item information including availability for each instance UUID included in request WHEN &fullPeriodicals=true
#   1st instance
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def firstInstanceId = createInstanceResponse.instanceEntityRequest.id
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 68640368-799e-43fc-9c3c-af39e243f3b7 }

#   2nd instance
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def secondInstanceId = createInstanceResponse.instanceEntityRequest.id
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 68640328-788e-53fd-9c3c-af39e243f3c7 }
    * def periodicalStatus = true
    * def rtacBatchrequest = read('samples/rtac-batch-request-entity.json')

    Given path 'rtac-batch'
    And request rtacBatchrequest
    When method POST
    Then status 200
    And match response.holdings..id contains [ 68640328-788e-53fd-9c3c-af39e243f3c7 , 68640368-799e-43fc-9c3c-af39e243f3b7 ]
    And match response.holdings..status contains [ Available , Checked out ]

  Scenario:For periodical/serial, return only holdings information including availability for each instance UUID included in request WHEN &fullPeriodicals=false OR no parameter is omitted
#   1st instance
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def firstInstanceId = createInstanceResponse.instanceEntityRequest.id
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def holdingId = call random_uuid
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 68640368-799e-43ec-9c3c-af39e243f3b7 }

#   2nd instance
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def secondInstanceId = createInstanceResponse.instanceEntityRequest.id
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def holdingId = call random_uuid
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem') { itemId: 68740328-788e-53fd-9c3c-af39e243f3c7 }
    * def periodicalStatus = false
    * def rtacBatchrequest = read('samples/rtac-batch-request-entity.json')

    Given path 'rtac-batch'
    And request rtacBatchrequest
    When method POST
    Then status 200
    And match response.holdings..id contains [ 68640368-799e-43ec-9c3c-af39e243f3b7 , 68740328-788e-53fd-9c3c-af39e243f3c7 ]

  Scenario: If instance UUID is invalid then return an error response
    * def firstInstanceId = '45dc40c1-46d9-4e41-b55c-c51e6f3e39b4'
    * def secondInstanceId = '46dc40c1-46d9-4e41-b55c-c51e6f3e39b4'
    * def rtacBatchrequest = read('samples/rtac-batch-request-entity.json')

    Given path 'rtac-batch'
    And request rtacBatchrequest
    When method POST
    Then status 200
    And match response.errors..message contains [Instance 45dc40c1-46d9-4e41-b55c-c51e6f3e39b4 can not be retrieved , Instance 46dc40c1-46d9-4e41-b55c-c51e6f3e39b4 can not be retrieved ]
