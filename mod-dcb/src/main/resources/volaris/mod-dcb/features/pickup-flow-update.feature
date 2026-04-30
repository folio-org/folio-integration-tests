Feature: Pickup Flow Update

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce variables
    * def startDate = callonce getCurrentUtcDate
    * configure retry = { count: 5, interval: 1000 }
    * def txnId = 'c1307939'
    * def barcodeInitial = 'c1307939-bc-0'
    * def barcodeUpdated = 'c1307939-bc-1'
    * def matTypeId2 = 'c1307939-0001-4000-8000-000000000001'
    * def matTypeName2 = 'mat-c1307939-2'

  @C1307939
  Scenario: Create DCB PICKUP transaction, update item fields and verify requests and transaction statuses

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew

    * def shadowInstCode = 'shadow-inst-' + txnId
    * def shadowCampCode = 'shadow-camp-' + txnId
    * def shadowLibCode = 'shadow-lib-' + txnId
    * def shadowLocCode = 'shadow-loc-' + txnId
    * def createInst = call read('classpath:volaris/mod-dcb/reusable/create-institution.feature') { name: 'Shadow Institution C1307939', code: '#(shadowInstCode)', isShadow: true }
    And match createInst.response.isShadow == true
    * def shadowInstitutionId = createInst.response.id
    * def createCamp = call read('classpath:volaris/mod-dcb/reusable/create-campus.feature') { name: 'Shadow Campus C1307939', code: '#(shadowCampCode)', institutionId: '#(shadowInstitutionId)', isShadow: true }
    And match createCamp.response.isShadow == true
    * def shadowCampusId = createCamp.response.id
    * def createLib = call read('classpath:volaris/mod-dcb/reusable/create-library.feature') { name: 'Shadow Library C1307939', code: '#(shadowLibCode)', campusId: '#(shadowCampusId)', isShadow: true }
    And match createLib.response.isShadow == true
    * def shadowLibraryId = createLib.response.id
    * def createLoc = call read('classpath:volaris/mod-dcb/reusable/create-location.feature') { name: 'Shadow Location C1307939', code: '#(shadowLocCode)', institutionId: '#(shadowInstitutionId)', campusId: '#(shadowCampusId)', libraryId: '#(shadowLibraryId)', servicePointId: '#(servicePointId)', isShadow: true }
    And match createLoc.response.isShadow == true
    * def shadowLocationName = createLoc.response.name

    Given path 'material-types'
    And request { id: '#(matTypeId2)', name: '#(matTypeName2)' }
    When method POST
    Then status 201

    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.title = 'DCB Item Title ' + txnId
    * createReq.item.barcode = barcodeInitial
    * createReq.item.materialType = materialTypeName
    * createReq.item.lendingLibraryCode = shadowLibCode
    * createReq.item.locationCode = shadowLocCode
    * createReq.patron.id = patronId3
    * createReq.patron.barcode = patronBarcode3
    * createReq.pickup.servicePointId = servicePointId
    * createReq.pickup.servicePointName = servicePointName
    * createReq.role = 'PICKUP'

    * def orgPathTxn = '/transactions/' + txnId
    * def newPathTxn = proxyCall == true ? proxyPath + orgPathTxn : orgPathTxn

    Given path newPathTxn
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == barcodeInitial
    And match $.patron.id == patronId3

    Given path 'request-storage', 'requests'
    And param query = '(item.barcode= ' + barcodeInitial + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    And match $.requests[0].item.itemEffectiveLocationName == shadowLocationName
    * def originalRequestId = $.requests[0].id

    * def updateReq = { item: { barcode: '#(barcodeUpdated)', materialType: '#(matTypeName2)', lendingLibraryCode: 'non-existing-lib' } }
    Given path '/transactions', txnId
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 204

    Given path 'request-storage', 'requests'
    And param query = '(item.barcode= ' + barcodeUpdated + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    And match $.requests[0].item.barcode == barcodeUpdated
    And match $.requests[0].item.itemEffectiveLocationName == 'DCB'
    * def updatedRequestId = $.requests[0].id
    And match updatedRequestId != originalRequestId

    Given path 'request-storage', 'requests', originalRequestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'
    And match $.item.barcode == barcodeInitial

    * def orgPathStatus = '/transactions/status'
    * def newPathStatus = proxyCall == true ? proxyPath + orgPathStatus : orgPathStatus
    * def pollConfig = { expectedRecords: 2, path: '#(newPathStatus)', apikey: '#(key)', baseUrl: '#(baseUrlNew)', startDate: '#(startDate)' }

    Given def pollResult = call read("classpath:volaris/mod-dcb/reusable/poll-transaction-statuses.feature@PollTransactionStatuses") { config: '#(pollConfig)' }
    Then def txnStatus = pollResult.response
    And match txnStatus.totalRecords == 2
    And match txnStatus.transactions[*].status contains only ['CREATED', 'CANCELLED']
    And match each txnStatus.transactions[*].id == txnId
    * def createdTxns = karate.jsonPath(txnStatus, "$.transactions[?(@.id == '" + txnId + "' && @.status == 'CREATED')]")
    And match createdTxns == '#[1]'
    And match createdTxns[0].item.barcode == barcodeUpdated
    And match createdTxns[0].item.materialType == matTypeName2
    And match createdTxns[0].item.lendingLibraryCode == 'non-existing-lib'
