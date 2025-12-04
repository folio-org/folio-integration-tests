Feature: Borrowing Flow With Flexible Locations Scenarios

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce variables
    * def dcbAgency = { name: 'DCB Borrowing Agency', code: 'AGB' }
    * def dcbLocation = { name: 'DCB Borrowing Location', code: 'LB0', agency: '#(dcbAgency)' }
    * def locationSetup = callonce read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@PostRefreshShadowLocation') { location: '#(dcbLocation)' }
    * def dcbLocationId = locationSetup.dcbLocationId


  Scenario: Create DCB Transaction with location code: LB0
    * def dcbTransactionId = call uuid1
    * def dcbTransaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * dcbTransaction.item.barcode = "dcb_flexloc_borrowing_" + random_string()
    * dcbTransaction.item.locationCode = dcbLocation.code
    * dcbTransaction.item.lendingLibraryCode = dcbAgency.code
    * dcbTransaction.patron.id = patronId31
    * dcbTransaction.patron.barcode = patronBarcode31
    * dcbTransaction.patron.group = patronGroupName
    * dcbTransaction.pickup.servicePointId = servicePointId21
    * dcbTransaction.pickup.servicePointName = servicePointName21
    * dcbTransaction.pickup.libraryCode = '6uclv'
    * dcbTransaction.role = 'BORROWER'

    Given path '/transactions/' + dcbTransactionId
    And request dcbTransaction
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == '#present'
    And match $.item.lendingLibraryCode == dcbAgency.code
    And match $.item.locationCode == dcbLocation.code
    And match $.item.barcode == dcbTransaction.item.barcode

    * def virtualItemId = response.item.id
    Given path '/circulation-item/' + virtualItemId
    When method GET
    Then status 200
    And match $.id == virtualItemId
    And match $.barcode == dcbTransaction.item.barcode
    And match $.effectiveLocationId == dcbLocationId

  Scenario: Create DCB Transaction with lending library code: AGB
    * def dcbTransactionId = call uuid1
    * def dcbTransaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * dcbTransaction.item.id = uuid()
    * dcbTransaction.item.barcode = "dcb_flexloc_borrowing_" + random_string()
    * dcbTransaction.item.lendingLibraryCode = dcbAgency.code
    * dcbTransaction.patron.id = patronId31
    * dcbTransaction.patron.barcode = patronBarcode31
    * dcbTransaction.patron.group = patronGroupName
    * dcbTransaction.pickup.servicePointId = servicePointId21
    * dcbTransaction.pickup.servicePointName = servicePointName21
    * dcbTransaction.pickup.libraryCode = '6uclv'
    * dcbTransaction.role = 'BORROWER'

    Given path '/transactions/' + dcbTransactionId
    * request dcbTransaction
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == '#present'
    And match $.item.lendingLibraryCode == dcbAgency.code
    And match $.item.barcode == dcbTransaction.item.barcode

    * def virtualItemId = response.item.id
    Given path '/circulation-item/' + virtualItemId
    When method GET
    Then status 200
    And match $.id == virtualItemId
    And match $.barcode == dcbTransaction.item.barcode
    And match $.effectiveLocationId == dcbLocationId

  Scenario: Create DCB Transaction with lending library code: UNKNOWN
    * def dcbTransactionId = call uuid1
    * def dcbTransaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * dcbTransaction.item.id = uuid()
    * dcbTransaction.item.barcode = "dcb_flexloc_borrowing_" + random_string()
    * dcbTransaction.item.lendingLibraryCode = 'UNKNOWN'
    * dcbTransaction.patron.id = patronId31
    * dcbTransaction.patron.barcode = patronBarcode31
    * dcbTransaction.patron.group = patronGroupName
    * dcbTransaction.pickup.servicePointId = servicePointId21
    * dcbTransaction.pickup.servicePointName = servicePointName21
    * dcbTransaction.pickup.libraryCode = '6uclv'
    * dcbTransaction.role = 'BORROWER'

    * def args = { name: 'DCB', code: '000', isShadow: false }
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLocationByNameAndCode') args
    * def defaultLocationId = response.locations[0].id

    Given path '/transactions/' + dcbTransactionId
    And request dcbTransaction
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == '#present'
    And match $.item.lendingLibraryCode == 'UNKNOWN'
    And match $.item.barcode == dcbTransaction.item.barcode

    * def virtualItemId = response.item.id
    Given path '/circulation-item/' + virtualItemId
    When method GET
    Then status 200
    And match $.id == virtualItemId
    And match $.barcode == dcbTransaction.item.barcode
    And match $.effectiveLocationId == defaultLocationId
