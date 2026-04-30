Feature: Borrower Transaction Item Fields Update

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
    * def txnId = 'c627526'
    * def titleInitial = 'DCB Item Title C627526'
    * def barcodeInitial = 'c627526-bc-0'
    * def barcode2 = 'c627526-bc-2'
    * def lendingLib2 = 'LEND-C627526-2'
    * def matTypeId2 = 'c6275260-0001-4000-8000-000000000001'
    * def matTypeName2 = 'mat-c627526-s2'
    * def barcode10 = 'c627526-bc-10'
    * def lendingLib10 = 'LEND-C627526-10'
    * def matTypeId10 = 'c6275260-0001-4000-8000-000000000002'
    * def matTypeName10 = 'mat-c627526-s10'

  @C627526
  Scenario: Verify BORROWER transaction item field updates and validation

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew

    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.title = titleInitial
    * createReq.item.barcode = barcodeInitial
    * createReq.item.materialType = materialTypeName
    * createReq.patron.id = patronId31
    * createReq.patron.barcode = patronBarcode31
    * createReq.pickup.servicePointId = servicePointId
    * createReq.pickup.libraryCode = 'test-lib-c627526'
    * createReq.role = 'BORROWER'

    * def orgPathTxn = '/transactions/' + txnId
    * def newPathTxn = proxyCall == true ? proxyPath + orgPathTxn : orgPathTxn

    Given path newPathTxn
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == barcodeInitial
    And match $.patron.id == patronId31

    * url baseUrl
    Given path 'material-types'
    And request { id: '#(matTypeId2)', name: '#(matTypeName2)' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(matTypeId10)', name: '#(matTypeName10)' }
    When method POST
    Then status 201

    * url baseUrlNew

    Given path '/transactions', txnId
    And param apikey = key
    And request
      """
      {
        "item": {
          "barcode": "#(barcode2)",
          "materialType": "#(matTypeName2)",
          "lendingLibraryCode": "#(lendingLib2)",
          "servicePointId": "c6275260-ffff-4000-8000-000000000010",
          "title": "Should Not Change Title",
          "id": "c6275260-ffff-4000-8000-000000000011",
          "libraryCode": "should-not-change-lib"
        }
      }
      """
    When method PUT
    Then status 204

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
    And match createdTxns[0].item.barcode == barcode2
    And match createdTxns[0].item.materialType == matTypeName2
    And match createdTxns[0].item.lendingLibraryCode == lendingLib2
    And match createdTxns[0].item.title == titleInitial

    Given path '/transactions', txnId
    And param apikey = key
    And request { item: { barcode: 'c627526-bc-err4', materialType: '#(materialTypeName)' } }
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'lendingLibraryCode'

    Given path '/transactions', txnId
    And param apikey = key
    And request { item: { barcode: 'c627526-bc-err5', lendingLibraryCode: 'LEND-ERR5' } }
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'materialType'

    Given path '/transactions', txnId
    And param apikey = key
    And request { item: { materialType: '#(materialTypeName)', lendingLibraryCode: 'LEND-ERR6' } }
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'barcode'

    Given path '/transactions', txnId
    And param apikey = key
    And request
      """
      {
        "item": {
          "barcode111": "c627526-bc-err7",
          "materialType": "#(materialTypeName)",
          "lendingLibraryCode": "LEND-ERR7"
        }
      }
      """
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'barcode'

    Given path '/transactions', txnId
    And param apikey = key
    And request
      """
      {
        "item": {
          "barcode": "c627526-bc-err8",
          "materialTypes": "#(materialTypeName)",
          "lendingLibraryCode": "LEND-ERR8"
        }
      }
      """
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'materialType'

    Given path '/transactions', txnId
    And param apikey = key
    And request
      """
      {
        "item": {
          "barcode": "c627526-bc-err9",
          "materialType": "#(materialTypeName)",
          "lendingCode": "LEND-ERR9"
        }
      }
      """
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'lendingLibraryCode'

    Given path '/transactions', txnId
    And param apikey = key
    And request { item: { barcode: '#(barcode10)', materialType: '#(matTypeName10)', lendingLibraryCode: '#(lendingLib10)' } }
    When method PUT
    Then status 204

    Given path '/transactions', txnId
    And param apikey = key
    And request { item: { barcode: '#(barcode10)', materialType: '#(matTypeName10)', lendingLibraryCode: '#(lendingLib10)' } }
    When method PUT
    Then status 409
    And match $.errors[0].code == 'DUPLICATE_ERROR'
