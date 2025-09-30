Feature: test for retrival service-point for requests when item, SP and location are updated

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = headersUser

    * def servicePointId = call uuid1
    * def groupId = call uuid1

    # Create Instance, Location, Holding
    * def instanceId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceId: #(instanceId) }
    * def locationId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def holdingId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { sourceId: #(holdingSourceId), extHoldingSourceName: #(holdingSourceName), extLocationId: #(locationId), extHoldingsRecordId: #(holdingId)  }

    * def extMaterialTypeId = call uuid1
    * def materialTypeIdResponse = callonce read('classpath:vega/mod-circulation/features/util/initData.feature@@PostMaterialType') { extMaterialTypeId: #(extMaterialTypeId) }

    # create user and group for all scenarios
    * def extUserId = call uuid1
    * def extUserGroupId = call uuid1
    * def extUserBarcode = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: '#(extUserGroupId)' }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(extUserBarcode), extGroupId: #(extUserGroupId), , firstName: 'USER-1' }

  Scenario: Normal flow with item SP and location synced correctly in request
    * print 'Normal flow with item SP and location synced correctly in request'

    * def extServicePointId = call uuid1
    * def extLocationId = call uuid1
    * def extItemId = call uuid1
    * def extItemBarcode = random_string()

    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }

    # post an item
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post a request
    * def extRequestId = call uuid1
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name

  Scenario: Service point name is updated in request when service point name is updated
    * print 'Service point name is updated in request when service point name is updated'
    * def extServicePointId = call uuid2
    * def extLocationId = call uuid2
    * def extItemId = call uuid2
    * def extItemBarcode = random_string()

    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId) }

    # post an item
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post a request
    * def extRequestId = call uuid2
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name

    * def extServicePointName = 'SP-Updated-name-de4e4'
    * def servicePointUpdatedResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@UpdateServicePoint') { extServicePointId: #(extServicePointId), extServicePointName: #(extServicePointName)}
    * def requestResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@GetRequest') { requestId: #(extRequestId) }
    * match requestResponse1.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse1.response.item.retrievalServicePointName == 'service point name ' + extServicePointName

  Scenario: Location name is updated in request when Location name is updated
    * print 'Location name is updated in request when Location name is updated'
    * def extServicePointId = call uuid2

    * def extLocationId = call uuid2
    * def extInstitutionId = call uuid2
    * def extCampusId = call uuid2
    * def extLibraryId = call uuid2

    * def extItemId = call uuid2
    * def extItemBarcode = random_string()

    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId), extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }

    # post an item
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post a request
    * def extRequestId = call uuid2
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name

    * def extLocationName = 'Loc-Updated-name-dfd76fd6'
    * def locationUpdatedResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@UpdateLocation') { extLocationId: #(extLocationId), servicePointId: #(extServicePointId), extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId), extLocationName: #(extLocationName) }
    * def requestResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@GetRequest') { requestId: #(extRequestId) }
    * match requestResponse1.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse1.response.item.itemEffectiveLocationName == 'location name ' + extLocationName

  Scenario: Test whether item location update reflected in request
    * print 'test item location update reflected in request'
    * def extServicePointId = call uuid2

    * def extLocationId = call uuid2
    * def extInstitutionId = call uuid2
    * def extCampusId = call uuid2
    * def extLibraryId = call uuid2

    * def extItemId = call uuid2
    * def extItemBarcode = random_string()

    * def servicePointResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId) }
    * def locationResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId), extServicePointId: #(extServicePointId), extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }

    # post an item
    * def itemRequestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItemWithTempLocation') { extItemId: #(extItemId), extItemBarcode: #(extItemBarcode), extLocationId: #(extLocationId), extMaterialTypeId: #(extMaterialTypeId) }

    # post a request
    * def extRequestId = call uuid2
    * def extRequestType = 'Page'
    * def requestResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(extItemId), requesterId: #(extUserId), extRequestType: #(extRequestType), extInstanceId: #(instanceId), extHoldingsRecordId: #(holdingId), extServicePoint: #(extServicePointId) }
    * match requestResponse.response.item.itemEffectiveLocationId == extLocationId
    * match requestResponse.response.item.itemEffectiveLocationName == locationResponse.response.name
    * match requestResponse.response.item.retrievalServicePointId == extServicePointId
    * match requestResponse.response.item.retrievalServicePointName == servicePointResponse.response.name

    * def extLocationName = 'Loc-Updated-name-sds3434'
    * def extLocationId1 = call uuid1
    * def extServicePointId1 = call uuid3
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