Feature: Requests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = headersUser


  Scenario: TEST KAPIL: Normal flow with item SP and location synced correctly in request
    * print 'Normal flow with item SP and location synced correctly in request'
    * def extInstanceTypeId = call uuid1
    * def extInstanceId = call uuid1
    * def extServicePointId = call uuid1
    * def extLocationId = call uuid1
    * def extHoldingSourceId = call uuid1
    * def extHoldingSourceName = random_string()
    * def extHoldingId = call uuid1
    * def extMaterialTypeId = call uuid1
    * def extItemId = call uuid1
    * def extItemBarcode = random_string()

    * def extUserId = call uuid1
    * print 'Kapil-extUserId-1', extUserId
    * def extUserGroupId = call uuid1
    * def extUserBarcode = call uuid1

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId), extInstanceId: #(extInstanceId) }
    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { sourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId)  }

    * print 'Kapil-servicePointResponse', servicePointResponse
    * print 'Kapil-locationResponse', locationResponse


    # post an item
    * def materialTypeIdResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId) }
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(extUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(extUserGroupId), , firstName: 'USER-1' }

    # post a request
    * def extRequestId = call uuid1
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name
    * print 'Kapil-requestResponse', requestResponse

  Scenario: TEST KAPIL: Service point name is updated in request when service point name is updated
    * print 'Service point name is updated in request when service point name is updated'
    * def extInstanceTypeId = call uuid2
    * def extInstanceId = call uuid2
    * def extServicePointId = call uuid2
    * def extLocationId = call uuid2
    * def extHoldingSourceId = call uuid2
    * def extHoldingSourceName = random_string()
    * def extHoldingId = call uuid2
    * def extMaterialTypeId = call uuid2
    * def extItemId = call uuid2
    * def extItemBarcode = random_string()

    * def extUserId = call uuid2
    * print 'Kapil-extUserId-2', extUserId
    * def extUserGroupId = call uuid2
    * def extUserBarcode = call uuid2

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId), extInstanceId: #(extInstanceId) }
    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { sourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId)  }

    * print 'Kapil-servicePointResponse', servicePointResponse
    * print 'Kapil-locationResponse', locationResponse


    # post an item
    * def materialTypeIdResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId) }
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(extUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(extUserGroupId), firstName: 'USER-2' }

    # post a request
    * def extRequestId = call uuid2
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name
    * print 'Kapil-requestResponse', requestResponse

    * def extServicePointName = 'SP-Updated-name-de4e4'
    * def servicePointUpdatedResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@UpdateServicePoint') { extServicePointId: #(extServicePointId), extServicePointName: #(extServicePointName)}
    * def requestResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@GetRequest') { requestId: #(extRequestId) }
    * match requestResponse1.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse1.response.item.retrievalServicePointName == 'service point name ' + extServicePointName


  Scenario: TEST KAPIL: Location name is updated in request when Location name is updated
    * print 'Location name is updated in request when Location name is updated'
    * def extInstanceTypeId = call uuid2
    * def extInstanceId = call uuid2
    * def extServicePointId = call uuid2

    * def extLocationId = call uuid2
    * def extInstitutionId = call uuid2
    * def extCampusId = call uuid2
    * def extLibraryId = call uuid2


    * def extHoldingSourceId = call uuid2
    * def extHoldingSourceName = random_string()
    * def extHoldingId = call uuid2
    * def extMaterialTypeId = call uuid2
    * def extItemId = call uuid2
    * def extItemBarcode = random_string()

    * def extUserId = call uuid2
    * print 'Kapil-extUserId-2', extUserId
    * def extUserGroupId = call uuid2
    * def extUserBarcode = call uuid2

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId), extInstanceId: #(extInstanceId) }
    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId), extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { sourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId)  }

    * print 'Kapil-servicePointResponse', servicePointResponse
    * print 'Kapil-locationResponse', locationResponse


    # post an item
    * def materialTypeIdResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId) }
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(extUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(extUserGroupId), firstName: 'USER-2' }

    # post a request
    * def extRequestId = call uuid2
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name
    * print 'Kapil-requestResponse', requestResponse

    * def extLocationName = 'Loc-Updated-name-dfd76fd6'
    * def locationUpdatedResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@UpdateLocation') { extLocationId: #(extLocationId), servicePointId: #(extServicePointId), extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId), extLocationName: #(extLocationName) }
    * def requestResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@GetRequest') { requestId: #(extRequestId) }
    * match requestResponse1.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse1.response.item.itemEffectiveLocationName == 'location name ' + extLocationName


  Scenario: TEST KAPIL: test item location update reflected in request
    * print 'test item location update reflected in request'
    * def extInstanceTypeId = call uuid2
    * def extInstanceId = call uuid2
    * def extServicePointId = call uuid2

    * def extLocationId = call uuid2
    * def extInstitutionId = call uuid2
    * def extCampusId = call uuid2
    * def extLibraryId = call uuid2


    * def extHoldingSourceId = call uuid2
    * def extHoldingSourceName = random_string()
    * def extHoldingId = call uuid2
    * def extMaterialTypeId = call uuid2
    * def extItemId = call uuid2
    * def extItemBarcode = random_string()

    * def extUserId = call uuid2
    * print 'Kapil-extUserId-2', extUserId
    * def extUserGroupId = call uuid2
    * def extUserBarcode = call uuid2

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId), extInstanceId: #(extInstanceId) }
    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId), extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { sourceId: #(extHoldingSourceId), extHoldingSourceName: #(extHoldingSourceName), extLocationId: #(extLocationId), extHoldingsRecordId: #(extHoldingId)  }

    * print 'Kapil-servicePointResponse', servicePointResponse
    * print 'Kapil-locationResponse', locationResponse


    # post an item
    * def materialTypeIdResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId) }
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(extUserGroupId)' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(extUserGroupId), firstName: 'USER-2' }

    # post a request
    * def extRequestId = call uuid2
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(extInstanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name
    * print 'Kapil-requestResponse', requestResponse

    * def extLocationName = 'Loc-Updated-name-sds3434'
    * def extLocationId1 = call uuid1
    * def extServicePointId1 = call uuid3
    * print 'Kapil-extServicePointId1', extServicePointId1
    * print 'Kapil-extLocationId1', extLocationId1
    * def extInstitutionId1 = call uuid1
    * def extCampusId1 = call uuid1
    * def extLibraryId1 = call uuid1
    * def hrid = itemRequestResponse.response.hrid
    * def version = '2'
    * def servicePointResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1), extServicePointId: #(extServicePointId1), extInstitutionId: #(extInstitutionId1), extCampusId: #(extCampusId1), extLibraryId: #(extLibraryId1), extLocationName: #(extLocationName) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@UpdateItem') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId1), extMaterialTypeId: #(extMaterialTypeId), extHrid: #(hrid),  extVersion: #(version) }
    * def requestResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@GetRequest') { requestId: #(extRequestId) }
    * match requestResponse1.response.item.itemEffectiveLocationId == extLocationId1
    * match requestResponse1.response.item.itemEffectiveLocationName == 'location name ' + extLocationName
    * match requestResponse1.response.item.retrievalServicePointId == extServicePointId1
    * match requestResponse1.response.item.retrievalServicePointName == servicePointResponse1.response.name