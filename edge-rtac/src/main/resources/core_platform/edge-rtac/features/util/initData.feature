Feature: init data for edge-rtac

  Background:
    * url baseUrl
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @PostInstance
  Scenario: create instance
    * def intInstanceTypeId = call random_uuid
    * def contributorNameTypeId = call random_uuid
    * def instanceTypeEntityRequest = read('samples/instance/instance-type-entity-request.json')
    * instanceTypeEntityRequest.id = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name + ' ' + random_string()
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code + ' ' + random_string()
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source + ' ' + random_string()
    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/instance/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.name = contributorNameTypeEntityRequest.name + ' ' + random_string()
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceEntityRequest = read('samples/instance/instance-entity-request.json')
    * instanceEntityRequest.instanceTypeId = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceEntityRequest.id = karate.get('extInstanceId', instanceId)
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('samples/servicepoint/service-point-entity-request.json')
    * servicePointEntityRequest.id = karate.get('extServicePointId', servicePointId)
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PostLocation
  Scenario: create location
    * def intInstitutionId = call random_uuid
    * def intCampusId = call random_uuid
    * def intLibraryId = call random_uuid

    * def locationUnitInstitutionEntityRequest = read('samples/location/location-unit-institution-entity-request.json')
    * locationUnitInstitutionEntityRequest.id = karate.get('extInstitutionId', intInstitutionId)
    * locationUnitInstitutionEntityRequest.name = locationUnitInstitutionEntityRequest.name + ' ' + random_string()
    Given path 'location-units', 'institutions'
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('samples/location/location-unit-campus-entity-request.json')
    * locationUnitCampusEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationUnitCampusEntityRequest.id = karate.get('extCampusId', intCampusId)
    * locationUnitCampusEntityRequest.name = locationUnitCampusEntityRequest.name + ' ' + random_string()
    * locationUnitCampusEntityRequest.code = locationUnitCampusEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'campuses'
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('samples/location/location-unit-library-entity-request.json')
    * locationUnitLibraryEntityRequest.id = karate.get('extLibraryId', intLibraryId)
    * locationUnitLibraryEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationUnitLibraryEntityRequest.name = locationUnitLibraryEntityRequest.name + ' ' + random_string()
    * locationUnitLibraryEntityRequest.code = locationUnitLibraryEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'libraries'
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationEntityRequest = read('samples/location/location-entity-request.json')
    * locationEntityRequest.id = karate.get('extLocationId', locationId)
    * locationEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationEntityRequest.libraryId = karate.get('extLibraryId', intLibraryId)
    * locationEntityRequest.primaryServicePoint = karate.get('extServicePointId', servicePointId)
    * locationEntityRequest.servicePointIds = [karate.get('extServicePointId', servicePointId)]
    * locationEntityRequest.name = locationEntityRequest.name + ' ' + random_string()
    * locationEntityRequest.code = locationEntityRequest.code + ' ' + random_string()
    Given path 'locations'
    And request locationEntityRequest
    When method POST
    Then status 201

  @PostHoldings
  Scenario: create holdings
    * def intHoldingSourceId = call random_uuid
    * def intHoldingSourceName = call random_string
    * def sourceIdEntityRequest = read('samples/source-record-entity-request.json')
    * sourceIdEntityRequest.id = karate.get('extHoldingSourceId', intHoldingSourceId)
    * sourceIdEntityRequest.name = karate.get('extHoldingSourceName', intHoldingSourceName)
    * print sourceIdEntityRequest

    Given path 'holdings-sources'
    And request sourceIdEntityRequest
    When method POST
    Then status 201

    * def holdingsEntityRequest = read('samples/holdings/holdings-entity-request.json')
    * holdingsEntityRequest.id = karate.get('extHoldingsRecordId', holdingId)
    * holdingsEntityRequest.instanceId = karate.get('extInstanceId', instanceId)
    * holdingsEntityRequest.sourceId = karate.get('extHoldingSourceId', intHoldingSourceId)
    * holdingsEntityRequest.permanentLocationId = karate.get('extLocationId', locationId)
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostMaterialType
  Scenario: create material type
    * def intMaterialTypeId = call random_uuid
    * def materialTypeName = call random_string
    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * materialTypeEntityRequest.name = karate.get('extMaterialTypeName', materialTypeName)
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

  @DeleteMaterialType
  Scenario: delete material type
  Given url baseUrl
    And  path 'material-types/' + materialTypeId
    When method DELETE
    Then status 204

  @DeleteItems
  Scenario: delete items
    * def intItemId = call random_uuid
    Given url baseUrl
      And  path 'inventory/items/' + karate.get('extItemId', intItemId)
      When method DELETE
      Then status 204

  @PostItem
  Scenario: create item
    * def permanentLoanTypeId = call random_uuid
    * def intItemId = call random_uuid

    * def permanentLoanTypeEntityRequest = read('samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item/item-entity-request.json')
    * itemEntityRequest.id = karate.get('extItemId', intItemId)
    * itemEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest.status.name = karate.get('extStatusName', itemStatusName)
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

  @PostOrder
  Scenario: create order

    * def vendor = karate.get('vendor', 'c6dace5d-4574-411e-8ba1-036102fcdc9b')
    * def orderType = karate.get('orderType', 'One-Time')
    * def ongoing = karate.get('ongoing', null)
    * def reEncumber = karate.get('reEncumber', false)
    * def acqUnitIds = karate.get('acqUnitIds', [])
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: #(id),
      vendor: #(vendor),
      orderType: #(orderType),
      ongoing: #(ongoing),
      reEncumber: #(reEncumber),
      acqUnitIds: #(acqUnitIds)
    }
    """
    When method POST
    Then status 201

  @PostOrderLine
  Scenario: create order line
    * def id = karate.get('id', null)
    * def listUnitPrice = karate.get('listUnitPrice', 1.0)
    * def isPackage = karate.get('isPackage', false)
    * def poLine = read('samples/orders/order-line-entity-request.json')
    * def titleOrPackage = karate.get('titleOrPackage', 'test')
    * def paymentStatus = karate.get('paymentStatus', null)
    * def receiptStatus = karate.get('receiptStatus', null)
    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696'
    * set poLine.fundDistribution[0].code = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696'
    * set poLine.cost.listUnitPrice = listUnitPrice
    * set poLine.cost.poLineEstimatedPrice = listUnitPrice
    * set poLine.isPackage = isPackage
    * set poLine.titleOrPackage = titleOrPackage
    * set poLine.paymentStatus = paymentStatus
    * set poLine.receiptStatus = receiptStatus

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  @OpenOrder
  Scenario: Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove order.compositePoLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  @GetOrderLineTitleId
  Scenario: Get order line title id
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

  @PostPiece
  Scenario: Create piece
    * def id = karate.get('id')
    * def poLineId = karate.get('poLineId')
    * def titleId = karate.get('titleId')
    * def holdingId = karate.get('holdingId', globalHoldingId1)
    * def format = karate.get('format', "Physical")
    * def createPieceRequest = read('samples/orders/pieces-entity-request.json')

    * set createPieceRequest.id = id
    * set createPieceRequest.poLineId = poLineId
    * set createPieceRequest.titleId = titleId
    * set createPieceRequest.holdingId = holdingId
    * set createPieceRequest.format = format

    Given path 'orders/pieces'
    And request createPieceRequest
    When method POST
    Then status 201