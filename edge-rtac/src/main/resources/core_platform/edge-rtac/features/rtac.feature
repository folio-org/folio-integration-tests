Feature: rtac tests
  Background:
    * url baseUrl
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * def itemStatusName = 'Available'
    * def instanceId = call random_uuid
    * def servicePointId = call random_uuid
    * def locationId = call random_uuid
    * def holdingId = call random_uuid
    * def itemStatusName = 'Available'

    # create material type
    * def materialTypeName = call random_string
    * def materialTypeId = call random_uuid
    * callonce read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId), extMaterialTypeName: #(materialTypeName) }

  Scenario: For a non-periodical/non-serial, return holdings and item information including availability for an instance UUID
    * def extInstanceId = call random_uuid
    * def extServicePointId = call random_uuid
    * def extLocationId = call random_uuid

    # post instance, service point and location
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }

    # post holding
    * def extHoldingId = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId), extLocationId: #(extLocationId), extInstanceId: #(extInstanceId) }
    * def expectedHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post items
    * def createFirstItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId) }
    * def expectedFirstItemId = createFirstItemResponse.id
    * def expectedFirstItemCopyNumber = createFirstItemResponse.copyNumber
    * def extItemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId), extStatusName: #(extItemStatusName)}
    * def expectedSecondItemId = createSecondItemResponse.id
    * def expectedSecondItemCopyNumber = createSecondItemResponse.copyNumber

    Given url edgeUrl
    And path 'rtac/' + extInstanceId
    And param apikey = apikey
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And assert response.holdings.length == 2
    # api response is getting shuffled for each run, matching response by converting into an array.
    And match [expectedFirstItemId,expectedSecondItemId] contains call expectedData response.holdings,'holdings'
    And match [expectedHoldingsCopyNumber,expectedFirstItemCopyNumber,expectedSecondItemCopyNumber] contains call expectedData response.holdings,'holdings'
    And match ['Available','Checked out'] contains call expectedData response.holdings,'status'

  Scenario: For a non-periodical/non-serial, return holdings and item information including availability for each instance UUID included in request
    * def extInstanceId1 = call random_uuid
    * def extServicePointId1 = call random_uuid
    * def extLocationId1 = call random_uuid

    # post first service point, location and instance
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId1) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId1) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1), extServicePointId: #(extServicePointId1) }

    # post first holding
    * def extHoldingId1 = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId1), extLocationId: #(extLocationId1), extInstanceId: #(extInstanceId1) }
    * def expectedFirstHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post item for the first holding
    * def createFirstItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId1) }
    * def expectedFirstItemId = createFirstItemResponse.id
    * def expectedFirstItemCopyNumber = createFirstItemResponse.copyNumber

    * def extInstanceId2 = call random_uuid
    * def extServicePointId2 = call random_uuid
    * def extLocationId2 = call random_uuid

    # post second service point, location and instance
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId2) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId2) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId2), extServicePointId: #(extServicePointId2) }

    # post second holding
    * def extHoldingId2 = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId2), extLocationId: #(extLocationId2), extInstanceId: #(extInstanceId2) }
    * def expectedSecondHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post item for the second holding
    * def extItemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId2), extStatusName: #(extItemStatusName)}
    * def expectedSecondItemId = createSecondItemResponse.id
    * def expectedSecondItemCopyNumber = createSecondItemResponse.copyNumber

    Given url edgeUrl
    And path 'rtac'
    And param instanceIds = extInstanceId1 + ',' + extInstanceId2
    And param apikey = apikey
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And assert response.holdings.length == 2
    And match [extInstanceId1,extInstanceId2] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstItemId,expectedSecondItemId] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstItemCopyNumber,expectedSecondItemCopyNumber] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstHoldingsCopyNumber, expectedSecondHoldingsCopyNumber] contains call expectedData response.holdings,'holdings'
    And match ['Available','Checked out'] contains call expectedData response.holdings,'status'

  Scenario: For periodical/serial, return holdings and item information including availability for each instance UUID included in request WHEN &fullPeriodicals=true
    * def extInstanceId1 = call random_uuid
    * def extServicePointId1 = call random_uuid
    * def extLocationId1 = call random_uuid

    # post first service point, location and instance
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId1) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId1) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1), extServicePointId: #(extServicePointId1) }

    # post first holding
    * def extHoldingId1 = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId1), extLocationId: #(extLocationId1), extInstanceId: #(extInstanceId1) }
    * def expectedFirstHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post item for the first holding
    * def createFirstItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId1) }
    * def expectedFirstItemId = createFirstItemResponse.id
    * def expectedFirstItemCopyNumber = createFirstItemResponse.copyNumber

    * def extInstanceId2 = call random_uuid
    * def extServicePointId2 = call random_uuid
    * def extLocationId2 = call random_uuid

    # post second service point, location and instance
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId2) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId2) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId2), extServicePointId: #(extServicePointId2) }

    # post second holding
    * def extHoldingId2 = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId2), extLocationId: #(extLocationId2), extInstanceId: #(extInstanceId2) }
    * def expectedSecondHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post item for the second holding
    * def extItemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId2), extStatusName: #(extItemStatusName)}
    * def expectedSecondItemId = createSecondItemResponse.id
    * def expectedSecondItemCopyNumber = createSecondItemResponse.copyNumber

    Given url edgeUrl
    And path 'rtac'
    And param instanceIds = extInstanceId1 + ',' + extInstanceId2
    And param fullPeriodicals = true
    And param apikey = apikey
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And assert response.holdings.length == 2
    And match [extInstanceId1,extInstanceId2] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstItemId,expectedSecondItemId] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstItemCopyNumber,expectedSecondItemCopyNumber] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstHoldingsCopyNumber,expectedSecondHoldingsCopyNumber] contains call expectedData response.holdings,'holdings'
    And match ['Available','Checked out'] contains call expectedData response.holdings,'status'

  Scenario: For periodical/serial, return only holdings information including availability for each instance UUID included in request WHEN &fullPeriodicals=false OR no parameter is omitted
    # create materialType
    * def materialTypeName = call random_string
    * def materialTypeId = call random_uuid
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId), extMaterialTypeName: #(materialTypeName) }

    * def extInstanceId1 = call random_uuid
    * def extServicePointId1 = call random_uuid
    * def extLocationId1 = call random_uuid

    # post first service point, location and instance
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId1) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId1) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1), extServicePointId: #(extServicePointId1) }

    # post first holding
    * def extHoldingId1 = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId1), extLocationId: #(extLocationId1), extInstanceId: #(extInstanceId1) }
    * def expectedFirstHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post item for the first holding
    * def createFirstItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId1) }
    * def expectedFirstItemId = createFirstItemResponse.id

    * def extInstanceId2 = call random_uuid
    * def extServicePointId2 = call random_uuid
    * def extLocationId2 = call random_uuid

    # post second service point, location and instance
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostInstance') { extInstanceId: #(extInstanceId2) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId2) }
    * call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId2), extServicePointId: #(extServicePointId2) }

    # post second holding
    * def extHoldingId2 = call random_uuid
    * def createHoldingsResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostHoldings') { extHoldingsRecordId: #(extHoldingId2), extLocationId: #(extLocationId2), extInstanceId: #(extInstanceId2) }
    * def expectedSecondHoldingsCopyNumber = createHoldingsResponse.copyNumber

    # post item for the second holding
    * def createSecondItemResponse = call read('classpath:core_platform/edge-rtac/features/util/initData.feature@PostItem') { extHoldingsRecordId: #(extHoldingId2) }
    * def expectedSecondItemId = createSecondItemResponse.id

    Given url edgeUrl
    And path 'rtac'
    And param instanceIds = extInstanceId1 + ',' + extInstanceId2
    And param fullPeriodicals = false
    And param apikey = apikey
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And assert response.holdings.length == 2
    And match [extHoldingId1,extHoldingId2] contains call expectedData response.holdings,'holdings'
    And match [expectedFirstHoldingsCopyNumber,expectedSecondHoldingsCopyNumber] contains call expectedData response.holdings,'holdings'
    And match [extInstanceId1,extInstanceId2] contains call expectedData response.holdings,'holdings'

  Scenario: If instance UUID is invalid then return an error response
    # invalid instance UUID
    * def extInstanceId = '45dc40c1-46d9-4e41-b55c-c51e6f3e39b4'

    Given url edgeUrl
    And path 'rtac'
    And param instanceIds = extInstanceId
    And param apikey = apikey
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match response.errors[0].message == 'Instance 45dc40c1-46d9-4e41-b55c-c51e6f3e39b4 can not be retrieved'
