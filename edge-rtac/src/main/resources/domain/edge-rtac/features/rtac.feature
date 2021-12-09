Feature: rtac tests
  # In Folio , instance have modeOfIssuance as 'Serial' and attached items are having materialtype 'newspaper' or 'journal' or 'magazine' are considered as Periodical Data
  # Line:-74,84,110,122. In 'diku' tenant modeOfIssuance 'Serial' is already defined , So hardcoding modeOfIssuanceId (modeOfIssuanceId = '068b5344-e2a6-40df-9186-1829e13cd344') to make instance as periodical
  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def itemStatusName = 'Available'
    # diku tenant is being used to run these tests, so it is mandatory to remove material type at the end of test runs otherwise it will throw 'item.materialType.id already exist' for next run.
    # Note- materialtype can not be deleted until an item is attached to it.
    # Line:- 37,71,107,145 . Items deletion
    * def materialTypeId = call random_uuid
    * callonce read('classpath:domain/edge-rtac/features/util/initData.feature@PostMaterialType')
    # creating non-serial modeOfIssuance
    * callonce read('classpath:domain/edge-rtac/features/util/initData.feature@PostModeOfIssuance')

  Scenario: For a non-periodical/non-serial, return holdings and item information including availability for an instance UUID
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedFirstItemId = createFirstItemResponse.itemId
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedSecondItemId = createSecondItemResponse.itemId

    Given url edgeUrl
    And path 'rtac/' + instanceId
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.holdings.holding.length == 2
    # api response is getting shuffled for each run, matching response by converting into an array.
    And match [expectedFirstItemId,expectedSecondItemId] contains call expectedData response.holdings,'holdings'
    And match ['Available','Checked out'] contains call expectedData response.holdings,'status'
    # deleteItem
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@DeleteItems')

  Scenario: For a non-periodical/non-serial, return holdings and item information including availability for each instance UUID included in request
#   1st instance
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def firstInstanceId = createInstanceResponse.instanceEntityRequest.id
    * def instanceId = firstInstanceId
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedFirstItemId = createFirstItemResponse.itemId
#   2nd instance
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def secondInstanceId = createInstanceResponse.instanceEntityRequest.id
    * def instanceId = secondInstanceId
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedSecondItemId = createSecondItemResponse.itemId

    Given url edgeUrl
    And path 'rtac?instanceIds=' + firstInstanceId + ',' + secondInstanceId
    And param apikey = apikey
    When method GET
    Then status 200
    And print response
    And match response.instances.holdings.length == 2
    And match [firstInstanceId,secondInstanceId] contains call expectedData response.instances.holdings,'instances'
    And match [expectedFirstItemId,expectedSecondItemId] contains call expectedData response.instances.holdings,'holdings'
    And match ['Available','Checked out'] contains call expectedData response.instances.holdings,'status'
    # deleteItem
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@DeleteItems')

  Scenario: For periodical/serial, return holdings and item information including availability for each instance UUID included in request WHEN &fullPeriodicals=true
#   1st instance
    * def modeOfIssuanceId = '068b5344-e2a6-40df-9186-1829e13cd344'
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def firstInstanceId = createInstanceResponse.instanceEntityRequest.id
    * def instanceId = firstInstanceId
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedFirstItemId = createFirstItemResponse.itemId
#   2nd instance
    * def modeOfIssuanceId = '068b5344-e2a6-40df-9186-1829e13cd344'
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def secondInstanceId = createInstanceResponse.instanceEntityRequest.id
    * def instanceId = secondInstanceId
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def itemStatusName = 'Checked out'
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedSecondItemId = createSecondItemResponse.itemId

    Given url edgeUrl
    And path 'rtac?instanceIds=' + firstInstanceId + ',' + secondInstanceId
    And param fullPeriodicals = true
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.instances.holdings.length == 2
    And match [firstInstanceId,secondInstanceId] contains call expectedData response.instances.holdings,'instances'
    And match [expectedFirstItemId,expectedSecondItemId] contains call expectedData response.instances.holdings,'holdings'
    And match ['Available','Checked out'] contains call expectedData response.instances.holdings,'status'
    # deleteItem
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@DeleteItems')

    Scenario: For periodical/serial, return only holdings information including availability for each instance UUID included in request WHEN &fullPeriodicals=false OR no parameter is omitted
#   1st instance
    * def modeOfIssuanceId = '068b5344-e2a6-40df-9186-1829e13cd344'
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def firstInstanceId = createInstanceResponse.instanceEntityRequest.id
    * def instanceId = firstInstanceId
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * def firstHoldings = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def firstHoldingsId = firstHoldings.response.id
    * def holdingId = firstHoldingsId
    * def createFirstItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedFirstItemId = createFirstItemResponse.itemId
#   2nd instance
    * def modeOfIssuanceId = '068b5344-e2a6-40df-9186-1829e13cd344'
    * def createInstanceResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostInstance')
    * def secondInstanceId = createInstanceResponse.instanceEntityRequest.id
    * def instanceId = secondInstanceId
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@PostLocation')
    * def secondHoldings = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostHoldings')
    * def secondHoldingsId = secondHoldings.response.id
    * def holdingId = secondHoldingsId
    * def createSecondItemResponse = call read('classpath:domain/edge-rtac/features/util/initData.feature@PostItem')
    * def expectedSecondItemId = createSecondItemResponse.itemId

    Given url edgeUrl
    And path 'rtac?instanceIds=' + firstInstanceId + ',' + secondInstanceId
    And param fullPeriodicals = false
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.instances.holdings.length == 2
    And match [firstHoldingsId,secondHoldingsId] contains call expectedData response.instances.holdings,'holdings'
    And match [firstInstanceId,secondInstanceId] contains call expectedData response.instances.holdings,'instances'
    # deleteItem
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@DeleteItems')
    # deleteMaterialType
    * call read('classpath:domain/edge-rtac/features/util/initData.feature@DeleteMaterialType')

  Scenario: If instance UUID is invalid then return an error response
    # invalid instance UUID
    * def instanceId = '45dc40c1-46d9-4e41-b55c-c51e6f3e39b4'

    Given url edgeUrl
    And path 'rtac?instanceIds=' + instanceId
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.instances.errors.error.message == 'Instance 45dc40c1-46d9-4e41-b55c-c51e6f3e39b4 can not be retrieved'
