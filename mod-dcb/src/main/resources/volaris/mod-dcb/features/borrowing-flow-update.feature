Feature: Borrowing Flow Scenarios

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

  @C1307937
  Scenario: Create DCB transaction using two shadow locations, update it and verify requests and transaction statuses

    # use base URL (edge or local)
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew

    # --- create first shadow location tree (institution/campus/library/location) ---
    * def shadowInstCode1 = 'shadow-inst-1'
    * def shadowCampCode1 = 'shadow-camp-1'
    * def shadowLibCode1 = 'shadow-libloc-1'
    * def shadowLocCode1 = 'shadow-libloc-1'
    * def createInst1 = call read('classpath:volaris/mod-dcb/reusable/create-institution.feature') { name: 'Shadow Institution 1', code: '#(shadowInstCode1)', isShadow: true }
    * def shadowInstitutionId1 = createInst1.response.id
    * def createCamp1 = call read('classpath:volaris/mod-dcb/reusable/create-campus.feature') { name: 'Shadow Campus 1', code: '#(shadowCampCode1)', institutionId: '#(shadowInstitutionId1)', isShadow: true }
    * def shadowCampusId1 = createCamp1.response.id
    * def createLib1 = call read('classpath:volaris/mod-dcb/reusable/create-library.feature') { name: 'Shadow Library 1', code: '#(shadowLibCode1)', campusId: '#(shadowCampusId1)', isShadow: true }
    * def shadowLibraryId1 = createLib1.response.id
    * def createLoc1 = call read('classpath:volaris/mod-dcb/reusable/create-location.feature') { name: 'Shadow Location 1', code: '#(shadowLocCode1)', institutionId: '#(shadowInstitutionId1)', campusId: '#(shadowCampusId1)', libraryId: '#(shadowLibraryId1)', servicePointId: '#(servicePointId)', isShadow: true }
    * def shadowLocationName1 = createLoc1.response.name

    # --- create second shadow location tree ---
    * def shadowInstCode2 = 'shadow-inst-2'
    * def shadowCampCode2 = 'shadow-camp-2'
    * def shadowLibCode2 = 'shadow-libloc-2'
    * def shadowLocCode2 = 'shadow-libloc-2'
    * def createInst2 = call read('classpath:volaris/mod-dcb/reusable/create-institution.feature') { name: 'Shadow Institution 2', code: '#(shadowInstCode2)', isShadow: true }
    * def shadowInstitutionId2 = createInst2.response.id
    * def createCamp2 = call read('classpath:volaris/mod-dcb/reusable/create-campus.feature') { name: 'Shadow Campus 2', code: '#(shadowCampCode2)', institutionId: '#(shadowInstitutionId2)', isShadow: true }
    * def shadowCampusId2 = createCamp2.response.id
    * def createLib2 = call read('classpath:volaris/mod-dcb/reusable/create-library.feature') { name: 'Shadow Library 2', code: '#(shadowLibCode2)', campusId: '#(shadowCampusId2)', isShadow: true }
    * def shadowLibraryId2 = createLib2.response.id
    * def createLoc2 = call read('classpath:volaris/mod-dcb/reusable/create-location.feature') { name: 'Shadow Location 2', code: '#(shadowLocCode2)', institutionId: '#(shadowInstitutionId2)', campusId: '#(shadowCampusId2)', libraryId: '#(shadowLibraryId2)', servicePointId: '#(servicePointId)', isShadow: true }
    * def shadowLocationName2 = createLoc2.response.name

    # --- create second material type (use intMaterialTypeId2 / intMaterialTypeName2 from variables.feature) ---
    * def materialTypeEntityRequest2 = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest2.id = intMaterialTypeId2
    * materialTypeEntityRequest2.name = intMaterialTypeName2
    Given path 'material-types'
    And request materialTypeEntityRequest2
    When method POST
    Then status 201

    # choose an existing non-DCB user created by pre-requisites (use patronId31 / patronBarcode31)
    * def txnId = '123456'

    # prepare and create DCB transaction (initially pointing to shadow location set #1)
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.title = 'ShadowItem-' + txnId
    * createReq.item.barcode = 'shadow-bc-1-' + txnId
    * createReq.item.materialType = materialTypeName
    * createReq.item.lendingLibraryCode = shadowLibCode1
    * createReq.item.locationCode = shadowLocCode1
    * createReq.patron.id = patronId31
    * createReq.patron.barcode = patronBarcode31
    * createReq.pickup.servicePointName = 'sp-nonexistent-' + txnId
    * createReq.pickup.libraryCode = 'art-lib'
    * createReq.role = 'BORROWER'

    * def orgPathTxn = '/transactions/' + txnId
    * def newPathTxn = proxyCall == true ? proxyPath+orgPathTxn : orgPathTxn

    Given path newPathTxn
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == createReq.item.barcode
    And match $.patron.id == patronId31

    # find the request created alongside the transaction
    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + createReq.item.barcode + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    And match $.requests[0].item.itemEffectiveLocationName == shadowLocationName1
    * def originalRequestId = $.requests[0].id

    # update the transaction: change barcode, materialType to materialType #2 and lendingLibraryCode -> shadow library #2
    * def newBarcode = createReq.item.barcode + '-u'
    * def updateReq = { item: { barcode: '#(newBarcode)', materialType: '#(intMaterialTypeName2)', lendingLibraryCode: '#(shadowLibCode2)' } }
    Given path '/transactions', txnId
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 204

    # search for request created with updated barcode
    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + newBarcode + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    And match $.requests[0].item.itemEffectiveLocationName == shadowLocationName2
    And match $.requests[0].item.barcode == newBarcode
    * def updatedRequestId = $.requests[0].id
    And match updatedRequestId != originalRequestId

    # verify the original request is closed and still contains old barcode
    Given path 'request-storage', 'requests', originalRequestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'
    And match $.item.barcode == createReq.item.barcode

    # poll transaction statuses and verify both CANCELLED (old) and CREATED (new) entries exist for the txn
    * def orgPathStatus = '/transactions/status'
    * def newPathStatus = proxyCall == true ? proxyPath+orgPathStatus : orgPathStatus
    * def pollConfig2 = { expectedRecords: 2, path: '#(newPathStatus)', apikey: '#(key)', baseUrl: '#(baseUrlNew)', startDate: '#(startDate)' }

    Given def pollResult2 = call read("classpath:volaris/mod-dcb/reusable/poll-transaction-statuses.feature@PollTransactionStatuses") { config: '#(pollConfig2)' }
    Then def response2 = pollResult2.response
    And match response2.transactions contains { id: '#(txnId)', status: 'CREATED' }
    And match response2.transactions contains { id: '#(txnId)', status: 'CANCELLED' }

