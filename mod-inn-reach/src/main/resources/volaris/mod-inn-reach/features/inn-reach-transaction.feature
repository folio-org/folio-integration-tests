@ignore
@parallel=false
Feature: Inn reach transaction

  Background:
    * url baseUrl
#    * callonce login testAdmin
#    * def okapitokenAdmin = okapitoken
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == false ? testUser : testUserEdge
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-to-code': 'fli01' , 'x-from-code': 'd2ir', 'x-d2ir-authorization':'auth','Accept': 'application/json'  }
    * def headersUserModInnReach = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-to-code': 'fli01' , 'x-from-code': 'd2ir', 'x-d2ir-authorization':'auth','Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 5000, count: 5 }
    * print 'Prepare central servers'
    * def serverResponse = proxyCall == false ? karate.callSingle(featuresPath + 'central-server.feature@create') : {}
    * print 'Response after central server create'
    * print serverResponse.response
    * def centralServer1 = proxyCall == true ? centralServer : serverResponse.response.centralServers[0]
    * def mappingPath1 = centralServer1.id + '/item-type-mappings'
    * def patronmappingPath1 = centralServer1.id + '/patron-type-mappings'
    * def libraryId = 'c868d07c-d26f-4f32-9666-f100b069253d'
    * def locationMappingPath1 = 'inn-reach/central-servers/' + centralServer1.id + '/libraries/' + libraryId + '/locations/location-mappings'
    * callonce read(globalPath + 'common-schemas.feature')
    * def emptyMappingsSchema = {itemTypeMappings: '#[0]', totalRecords: 0}
    * def mappingItemSchema = read(samplesPath + 'item-type-mapping/item-type-mapping-schema.json')

    * print 'Prepare INN Reach locations'
    * callonce read(featuresPath + 'inn-reach-location.feature@create') { testUserEdge: #(user) }
    * def innReachLocation1 = response.locations[0].id
    * def locCode = response.locations[0].code

    * def patronId = '2bc26e0c-db89-4a21-88e9-3177d03f222f'
    * def patronName = call random_string
    * def status = true
    * def lastName = call random_string
    * def firstName = call random_string
    * def username = call random_string
    * def email = 'abc@pqr.com'
    * def barcode = '912235'
    * def itemBarcode = '7010'
    * def incorrectItemBarcode = '1016'
    * def transferItemBarcode = '9572e604-afd5-42d6-9ef5-b0b0f284b114'
    * def incorrectItemBarcode = '7099'
    * def incorrectTransId = '7571e602-afd5-42d3-9ef5-b0b0f284b214'
    * def incorrectTrackingID = '77777'
    * def trackingID = '1068'
    * def itemTrackingID = '1067'
    * def trackingId2 = '1069'
    * def centralCode = 'd2ir'
    * def tempPatronGroupId = ''
    * def servicePointId = '9bfc5298-72fa-41ba-95a7-fc1cc6c3db8c'
    * def pathCentralServer1 = 'inn-reach/central-servers/' + centralServer1.id + '/inn-reach-recall-user'
    * def mappingsSchema =
    """
    {
      itemTypeMappings: '#[] mappingItemSchema',
      totalRecords: '#number? _ == $.itemTypeMappings.length'
    }
    """

  Scenario: create PatronGroup & User
    * print 'Create PatronGroup & User'
    * def createPatronGroupRequest = read(samplesPath + 'patron/create-patron.json')
    Given path 'groups'
    And request createPatronGroupRequest
    When method POST
    Then status 201

    * def patronGroupId = response.id
    * def createUserRequest = read(samplesPath + 'user/create-user.json')

    Given path 'users'
    And request createUserRequest
    When method POST
    Then status 201

    * print 'Create initial patron type mappings'
    * def mappings = read(samplesPath + 'patron-type-mapping/patron-type-mappings.json')
    Given path '/inn-reach/central-servers/' +patronmappingPath1
    And request mappings
    When method PUT
    Then status 204

  Scenario: Update central patron type mappings
    * print 'Prepare central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    And request read(samplesPath + 'central-patron-type-mappings/create-central-patron-type-mappings-request-1.json')
    When method PUT
    Then status 204

    * print 'Check updated central patron type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/central-patron-type-mappings'
    When method GET
    Then status 200


  Scenario: Create and get item type mappings
    * print 'Create initial item type mappings'
    * def mappings = read(samplesPath + 'item-type-mapping/item-type-mappings-for-transaction.json')
    Given path '/inn-reach/central-servers/' + mappingPath1
    And request mappings
    When method PUT
    Then status 204

  Scenario: Create material type mappings

    * print 'Create material type mapping 1'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-3.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "1a54b431-2e4f-452d-9cae-9cee66c9a892"
    And match response.centralItemType == 200
    And match response.id == '#notnull'

    #Create ServicePointid
  Scenario: create service point
    * print 'Create ServicePointid'
    * def servicePointEntityRequest = read(samplesPath+ 'service-point/service-point-entity-request.json')
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201


    #Request Preference
  Scenario: Create Request Preference
    * print 'Create Request Preference'
    Given path '/request-preference-storage/request-preference'
    And request read(samplesPath + "request-preference/patron-request-preference.json")
    When method POST
    Then status 201

        #Request Preference
  Scenario: Get Request Preference
    * print 'GET Request Preference'
    Given path '/request-preference-storage/request-preference'
    And param query = 'userId==2bc26e0c-db89-4a21-88e9-3177d03f222f'
    When method GET
    Then status 200

  Scenario: Create and get location mappings
    * print 'Create Location mappings'
    * def input = read(samplesPath + 'location-mapping/location-mappings.json')
    Given path locationMappingPath1
    And request input
    When method PUT
    Then status 204

    * print 'Get Location mappings'
    Given path locationMappingPath1
    When method GET
    Then status 200

  Scenario: Create agency mappings by server id
    * print 'Create agency mapping'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/agency-mappings'
    And request read(samplesPath + "agency-mapping/create-agency-mapping-request.json")
    When method PUT
    Then status 204


  Scenario: Get Agency Mapping
    * print 'Get agency mapping'
    * print headersUser
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/agency-mappings'
    When method GET
    Then status 200



  Scenario: Start ItemHold
    * print 'Start ItemHold'
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    * def itemUrlPrefix = proxyCall == true ? 'http://localhost:8081/' : 'http://localhost:9130/'
    * def itemUrlSub = proxyCall == true ? 'innreach/v2' : 'inn-reach/d2ir'
    Given url itemUrlPrefix + itemUrlSub + '/circ/itemhold/'+ itemTrackingID + '/' + centralCode
    And request read(samplesPath + 'item-hold/transaction-hold-request.json')
    When method POST
    Then status 200
    * configure headers = headersUser

     # Transfer Item

  Scenario: Get Item Transaction
    * print 'Get Item Transaction'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' , testUserEdge: #(user) }
    * def transactionId = response.transactions[0].id

    * print 'Start TransferItem'
    Given path '/inn-reach/transactions/', transactionId , '/' , 'itemhold/transfer-item/',transferItemBarcode
    And retry until responseStatus == 204
    When method POST
    Then status 204

  Scenario: Update Transaction For Checkout
    * print 'Get Transaction For update checkout '
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' , testUserEdge: #(user) }
    * def transactionId = response.transactions[0].id
    * def updateTrans = response.transactions[0]
    * updateTrans.state = 'ITEM_HOLD'

    * print 'Update Transaction Item for Checkout'
    Given path '/inn-reach/transactions/' + transactionId
    And request updateTrans
    When method PUT
    Then status 204

  Scenario: Start Checkout item
    * print 'Start checkout'
    Given path '/inn-reach/transactions/', itemBarcode ,'/check-out-item/', servicePointId
    And retry until responseStatus == 200
    When method POST
    Then status 200
    And match response.transaction == '#notnull'
    And match response.transaction.state == 'ITEM_SHIPPED'


  Scenario: Start PatronHold
    * print 'Start PatronHold'
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    * def patronUrlPrefix = proxyCall == true ? 'http://localhost:8081/' : 'http://localhost:9130/'
    * def patronUrlSub = proxyCall == true ? 'innreach/v2' : 'inn-reach/d2ir'
    Given url patronUrlPrefix + patronUrlSub + '/circ/patronhold/' + trackingID + '/' + centralCode
    And request read(samplesPath + 'patron-hold/patron-hold-request.json')
    When method POST
    Then status 200
    * configure headers = headersUser


  Scenario: Get Patron Transaction1
    * print 'Get Patron Transaction'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    And response.transactions[0].state == 'PATRON_HOLD'
    #Positive case


  @ItemShipped
  Scenario: Start Item shipped
    * print 'Start item shipped'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user)}
    * def transactionId = $.transactions[0].id
    * def baseUrlNew = proxyCall == true ? proxyPath : baseUrl
    * def apiPath = '/circ/itemshipped/' + trackingID + '/' + centralCode
    * def subUrl = proxyCall == true ? apiPath : '/inn-reach/d2ir' + apiPath
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    Given url baseUrlNew + subUrl
    And request read(samplesPath + 'item/item_shipped.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser

  Scenario: Receive shipped item at borrowing site
    * print 'Get Patron hold transaction id'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = response.transactions[0].id
    * def transactionUpdate = get response.transactions[0]
    * set transactionUpdate.state = 'ITEM_SHIPPED'

    * print 'Update Patron hold transaction by id'
    Given path '/inn-reach/transactions/' + transactionId
    And request transactionUpdate
    When method PUT
    Then status 204

    * print 'Receive shipped item at borrowing site'
    Given path '/inn-reach/transactions/' + transactionId + '/receive-item/' + servicePointId
    And retry until responseStatus == 200
    When method POST
    Then status 200

  Scenario: Receive shipped item at borrowing site negative scenarios

    * print 'Not found transaction when receive shipped item at borrowing site'
    Given path '/inn-reach/transactions/' + uuid() + '/receive-item/' + servicePointId
    When method POST
    Then status 404

    * print 'Receive shipped item at borrowing site when invalid transaction state'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = response.transactions[0].id
    Given path '/inn-reach/transactions/' + uuid() + '/receive-item/' + servicePointId
    When method POST
    Then status 404


  Scenario: Update patron hold transaction after item checkout
    * print 'Update patron hold transaction after item checkout'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = $.transactions[0].id
    Given path '/inn-reach/transactions/', transactionId, '/patronhold/check-out-item/', servicePointId
    And retry until responseStatus == 200
    When method POST
    Then status 200

    # FAT-1564 - Return Item positive scenario start.
    * print 'Return item positive scenario'
    Given path '/inn-reach/transactions/' + transactionId + '/patronhold/return-item/' + servicePointId
    And retry until responseStatus == 204
    When method POST
    Then status 204

  Scenario: Save InnReach Recall User
    * print 'Save InnReach Recall User'
    * def recallUserId = '98fe1416-e389-40cd-8fb4-cb1cfa2e3c55'
    Given path pathCentralServer1
    And request read(samplesPath + 'recall-user/recall-user.json')
    When method POST
    Then status 200
    And match response.userId == recallUserId

  # Recall Item start

  @RecallItem
  Scenario: Start recall Item
    * if (proxyCall == false) karate.abort()
    * print 'Start recall item'
    * def proxyUrl = proxyPath + '/circ/recall/' + trackingID + '/' + centralCode
    * configure headers = proxyHeader
    Given url proxyUrl
    And request read(samplesPath + 'patron-hold/recall-request.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser

  # Recall Item end

  Scenario: Update patron hold transaction after patron hold cancellation
    * print 'Update patron hold transaction after patron hold cancellation'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = $.transactions[0].id
    Given path '/inn-reach/transactions/', transactionId, '/patronhold/cancel'
    And request read(samplesPath + 'patron-hold/cancel-patron-hold-request.json')
    When method POST
    Then status 200
   # FAT-1564 - Return Item positive scenario end.

    #####

  Scenario: Update Transaction
    * print 'Update Transactions For Patron'
    * def updateTrans = read(samplesPath + 'patron-hold/update-patron-hold-request.json')
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' }
    * def transactionId = $.transactions[0].id
    * updateTrans.id = transactionId
    Given path '/inn-reach/transactions/' + transactionId
    And request updateTrans
    When method PUT
    Then status 204

    * print 'Start Renew'
    Given path '/inn-reach/d2ir/circ/ownerrenew/', trackingID , '/' , centralCode
    And request read(samplesPath + 'owner-renew/owner-renew.json')
    When method PUT
    Then status 200

    * print 'Get Transaction After Renew'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user)}

  # Borrower renew start

  Scenario: Start borrower renew
    * if (proxyCall == false) karate.abort()
    * print 'Start borrower renew'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }
    * def proxyUrl = proxyPath + '/circ/borrowerrenew/' + itemTrackingID + '/' + centralCode
    * configure headers = proxyHeader
    Given url proxyUrl
    And request read(samplesPath + 'borrower-renew/borrower-renew.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser

    * print 'Update Transaction after Borrower Renew'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }
    * def transactionId = $.transactions[0].id
    * def updateTrans = $.transactions[0]
    * updateTrans.state = 'ITEM_SHIPPED'
    * url baseUrl
    Given path '/inn-reach/transactions/' + transactionId
    And request updateTrans
    When method PUT
    Then status 204

  # Borrower renew end


  # Transfer PatronHoldItem start

  @TransferPatronHoldItem
  Scenario: Start PatronHoldItem transfer
    * print 'Start PatronHoldItem transfer'
    * def baseUrlNew = proxyCall == true ? proxyPath : baseUrl
    * def apiPath = '/circ/transferrequest/' + trackingID + '/' + centralCode
    * def subUrl = proxyCall == true ? apiPath : '/inn-reach/d2ir' + apiPath
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    Given url baseUrlNew + subUrl
    And request read(samplesPath + 'patron-hold/transfer-patron-hold-request.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser




  # Transfer PatronHoldItem end

#    FAT-1564 - Return Item negative scenario start.

  Scenario: Return item negative scenarios

    * print 'Not found transaction when return item'
    Given path '/inn-reach/transactions/' + uuid() + '/patronhold/return-item/' + servicePointId
    When method POST
    Then status 404

    * print 'Return item at borrowing site when invalid transaction state'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = response.transactions[0].id
    Given path '/inn-reach/transactions/' + transactionId + '/patronhold/return-item/' + servicePointId
    When method POST
    Then status 400

# FAT-1564 - Return Item negative scenario end.



  Scenario: Get Item Transaction
    * print 'Get Item Transaction'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }
    And response.transactions[0].state == 'ITEM_SHIPPED'
    * def transactionId = response.transactions[0].id

    * print 'Start Final CheckIn'
    Given path '/inn-reach/transactions/', transactionId ,'/itemhold/finalcheckin/', servicePointId
    And retry until responseStatus == 204
    When method POST
    Then status 204

    * print 'Start Recall Item'
    Given path '/inn-reach/transactions/', transactionId ,'/itemhold/recall'
    And retry until responseStatus == 204
    When method POST
    Then status 204

    * print 'Get Item Transaction'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }

#    FAT-1564 - Return Uncirculated to owning site negative scenario Start.
  Scenario: Return Uncirculated to owning site negative scenario
    * print 'Return Uncirculated to owning site negative scenario'
    Given path '/inn-reach/d2ir/circ/returnuncirculated/' + incorrectTrackingID + '/' + centralCode
    And request read(samplesPath + 'item-hold/uncirculated-request.json')
#    And retry until responseStatus == 200
    When method PUT
    Then status 400
#    FAT-1564 - Return Uncirculated to owning site negative scenario End.

#    FAT-1564 - Return Uncirculated to owning site positive scenario Start.

  Scenario: Return Uncirculated to owning site positive
    * print 'Get Item hold transaction id'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }
    * def transactionId = response.transactions[0].id
    * def transactionUpdate = get response.transactions[0]
    * set transactionUpdate.state = 'ITEM_RECEIVED'

    * print 'Update Item hold transaction by id'
    Given path '/inn-reach/transactions/' + transactionId
    And request transactionUpdate
    When method PUT
    Then status 204

#    FAT-1577 - Changes Start.
    * print 'Return Uncirculated to owning site positive'
    * def baseUrlNew = proxyCall == true ? proxyPath : baseUrl
    * def apiPath = '/circ/returnuncirculated/' + itemTrackingID + '/' + centralCode
    * def subUrl = proxyCall == true ? apiPath : '/inn-reach/d2ir' + apiPath
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    Given url baseUrlNew + subUrl
    And request read(samplesPath + 'item-hold/uncirculated-request.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser
#    FAT-1577 - Changes End.
#    FAT-1564 - Return Uncirculated to owning site positive scenario End.

  # Item in transit start

  Scenario: Start Item in transit
    * print 'Get Item hold transaction id'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }
    * def transactionId = response.transactions[0].id
    * def transactionUpdate = get response.transactions[0]
    * set transactionUpdate.state = 'ITEM_RECEIVED'

    * print 'Update Item hold transaction by id'
    Given path '/inn-reach/transactions/' + transactionId
    And request transactionUpdate
    When method PUT
    Then status 204

    * print 'Start Item in transit'
    * def baseUrlNew = proxyCall == true ? proxyPath : baseUrl
    * def apiPath = '/circ/intransit/' + itemTrackingID + '/' + centralCode
    * def subUrl = proxyCall == true ? apiPath : '/inn-reach/d2ir' + apiPath
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    Given url baseUrlNew + subUrl
    And request read(samplesPath + 'item-hold/in-transit-request.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser
  # Item in transit end

  Scenario: Update Transaction
    * print 'Update Transactions For Cancel'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' }
    * def transactionId = $.transactions[0].id
    * def updateTrans = $.transactions[0]
    * updateTrans.state = 'ITEM_HOLD'
    * updateTrans.hold.folioLoanId = null

    * print 'Update Transaction Item for CancelItemHold'
    Given path '/inn-reach/transactions/' + transactionId
    And request updateTrans
    When method PUT
    Then status 204

#  FAT-1574 : edge-inn-reach: Implement API Karate tests: Owning Site API - Update transaction when patron cancelled the request before shipping
#  Changes implemented to pass through edge-inn-reach proxy if flag is true else it pass without edge-inn-reach proxy proxy
  Scenario: Start CancelItemHold
    * print 'Start CancelItemHold'
    * def baseUrlNew = proxyCall == true ? proxyPath : baseUrl
    * def apiPath = '/circ/cancelitemhold/' + itemTrackingID + '/' + centralCode
    * def subUrl = proxyCall == true ? apiPath : '/inn-reach/d2ir' + apiPath
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    Given url baseUrlNew + subUrl
    And request read(samplesPath + 'item-hold/cancel-request.json')
    And retry until responseStatus == 200
    When method PUT
    Then status 200
    * configure headers = headersUser
#    Changes done for FAT-1574

  Scenario: Get Transactions
    * print 'Get Transactions after cancel'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'ITEM' , testUserEdge: #(user) }
    And response.transactions[0].state == 'BORROWING_SITE_CANCEL'

  Scenario: Update Transaction
    * print 'Update Transactions For finalCheckin'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = $.transactions[0].id
    * def updateTrans = $.transactions[0]
    * updateTrans.state = 'OWNER_RENEW'
    Given path '/inn-reach/transactions/' + transactionId
    And request updateTrans
    When method PUT
    Then status 204

    * print 'Start patron finalCheckIn'
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    * def itemUrlPrefix = proxyCall == true ? 'http://localhost:8081/' : 'http://localhost:9130/'
    * def itemUrlSub = proxyCall == true ? 'innreach/v2' : 'inn-reach/d2ir'
    Given url itemUrlPrefix + itemUrlSub + '/circ/finalcheckin/'+ trackingID + '/' + centralCode
    And request read(samplesPath + 'patron-hold/base-circ-request.json')
    When method PUT
    Then status 200
    * configure headers = headersUser

  Scenario: Start patron Checkin Negative cases
    * print 'Start patron Negative finalCheckIn'
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    * def itemUrlPrefix = proxyCall == true ? 'http://localhost:8081/' : 'http://localhost:9130/'
    * def itemUrlSub = proxyCall == true ? 'innreach/v2' : 'inn-reach/d2ir'
    Given url itemUrlPrefix + itemUrlSub + '/circ/finalcheckin/'+ incorrectTrackingID + '/' + centralCode
    And request read(samplesPath + 'patron-hold/base-circ-request.json')
    When method PUT
    Then status 400
    * configure headers = headersUser

  Scenario: Start PatronHold 2
    * print 'Start PatronHold 2 for unshipped item'
    Given path '/inn-reach/d2ir/circ/patronhold/' + trackingId2 , '/' , centralCode
    And request read(samplesPath + 'patron-hold/patron-hold-request-2.json')
    When method POST
    Then status 200

  Scenario: Start Receive Unshipped Item Positive
    * print 'Start Receive Unshipped Item - Positive - Get Item Transaction'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = $.transactions[1].id
    * print 'Start Receive Unshipped Item - Positive'
    Given path '/inn-reach/transactions/', transactionId , '/' , 'receive-unshipped-item/', servicePointId, '/', 7011
    And request read(samplesPath + 'unshipped-item/unshipped-item.json')
    And retry until responseStatus == 200
    When method POST
    Then status 200

  Scenario: Start Receive Unshipped Item Negative
    * print 'Start Receive Unshipped Item - Negative - Get Item Transaction'
    * call read(globalPath + 'transaction-helper.feature@GetTransaction') { transactionType : 'PATRON' , testUserEdge: #(user) }
    * def transactionId = $.transactions[1].id
    * print 'Start Receive Unshipped Item - Negative'
    Given path '/inn-reach/transactions/', transactionId , '/' , 'receive-unshipped-item/', servicePointId, '/', itemBarcode
    And request read(samplesPath + 'unshipped-item/invalid-unshipped-item.json')
    When method POST
    Then status 400



     # Negative case
  Scenario: Start Checkout item
    * print 'Start negetive checkout'
    Given path '/inn-reach/transactions/', incorrectItemBarcode ,'/check-out-item/', servicePointId
    When method POST
    Then status 404

  #    Negative Recall Item
  Scenario: Start Negative Recall Item
    * print 'Start Negative Recall Item'
    Given path '/inn-reach/transactions/', incorrectTransId ,'/itemhold/recall'
    When method POST
    Then status 404

  #    Negative Final CheckIn
  Scenario: Start Negative Final CheckIn
      * print 'Start Negative Final CheckIn'
      Given path '/inn-reach/transactions/', incorrectTransId ,'/itemhold/finalcheckin/', servicePointId
      When method POST
      Then status 404

  #    Negative renew scenario
  Scenario: Start Negative Renew
    * print 'Start Negative Renew'
    Given path '/inn-reach/d2ir/circ/ownerrenew/', incorrectTrackingID , '/' , centralCode
    And request read(samplesPath + 'owner-renew/owner-renew.json')
    When method PUT
    Then status 400

  #    Negative transfer item hold
  Scenario: Start Negative Transfer Item
    * print 'Start Negative TransferItem'
    Given path '/inn-reach/transactions/', incorrectTransId , '/' , 'itemhold/transfer-item/',transferItemBarcode
    When method POST
    Then status 404

  #   Negative cancel item hold
  Scenario: Start Negative Cancel Item Hold
    * print 'Start Negative Cancel Item Hold'
    Given path '/inn-reach/transactions/' + incorrectTransId
    And request read(samplesPath + 'item-hold/incorrect-cancel-request.json')
    When method PUT
    Then status 500

#    Negative patron hold via edge-inn-reach

  Scenario: Start Negative PatronHold for edge-inn-reach
    * print 'Start Negative PatronHold for edge-inn-reach'
    * def incorrectToken = 'Bearer ' + 'NTg1OGY5ZDgtMTU1OC00N'
    * def incorrectHeader = { 'Content-Type': 'application/json', 'Authorization' : '#(incorrectToken)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }
    * def tempHeader = proxyCall == true ? incorrectHeader : headersUserModInnReach
    * configure headers = tempHeader
    * def patronUrlPrefix = proxyCall == true ? 'http://localhost:8081/' : 'http://localhost:9130/'
    * def patronUrlSub = proxyCall == true ? 'innreach/v2' : 'inn-reach/d2ir'
    Given url patronUrlPrefix + patronUrlSub + '/circ/patronhold/' + trackingID + '/' + centralCode
    And request read(samplesPath + 'patron-hold/patron-hold-request.json')
    When method POST
    Then assert responseStatus == 200 || responseStatus == 401

  Scenario: Start Item shipped negative proxy call
    * print 'Start item  negative proxy call'
    * if (proxyCall == false) karate.abort()
    * def subUrl = '/circ/itemshipped/' + trackingID + '/' + centralCode
    * proxyHeader.Authorization = 'Bearer 12345678'
    * configure headers = proxyHeader
    Given url proxyPath + subUrl
    And request read(samplesPath + 'item/item_shipped.json')
    And retry until responseStatus == 401
    When method PUT
    Then status 401

  Scenario: Start PatronHold transfer negative proxy call
    * print 'Start PatronHold transfer  negative proxy call'
    * if (proxyCall == false) karate.abort()
    * def subUrl = '/circ/transferrequest/' + trackingID + '/' + centralCode
    * proxyHeader.Authorization = 'Bearer 12345678'
    * configure headers = proxyHeader
    Given url proxyPath + subUrl
    And request read(samplesPath + 'item/item_shipped.json')
    And retry until responseStatus == 401
    When method PUT
    Then status 401

  Scenario: Start borrower renew negative call
    * if (proxyCall == false) karate.abort()
    * print 'Start borrower renew negative call'
    * def proxyUrl = proxyPath + '/circ/borrowerrenew/' + trackingID + '/' + centralCode
    * proxyHeader.Authorization = 'Bearer 12345678'
    * configure headers = proxyHeader
    Given url proxyUrl
    And request read(samplesPath + 'borrower-renew/borrower-renew.json')
    And retry until responseStatus == 401
    When method PUT
    Then status 401

#  FAT-1574 : edge-inn-reach: Implement API Karate tests: Owning Site API - Update transaction when patron cancelled the request before shipping
#  Changes implemented negative scenario cancelItemHold (Cancel an item request) through edge-inn-reach proxy
  Scenario: Start CancelItemHold Negative Proxy Call
    * print 'Start CancelItemHold Negative Proxy Call'
    * def incorrectToken = 'Bearer ' + 'NTg1OGY5ZDgtMTU1OC00N'
    * def incorrectHeader = { 'Content-Type': 'application/json', 'Authorization' : '#(incorrectToken)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }
    * def tempHeader = proxyCall == true ? incorrectHeader : headersUserModInnReach
    * def baseUrlNew = proxyCall == true ? proxyPath : baseUrl
    * configure headers = tempHeader
    * def apiPath = '/circ/cancelitemhold/' + itemTrackingID + '/' + centralCode
    * def subUrl = proxyCall == true ? apiPath : '/inn-reach/d2ir' + apiPath
    * def tempHeader = proxyCall == true ? proxyHeader : headersUserModInnReach
    * configure headers = tempHeader
    Given url baseUrlNew + subUrl
    And request read(samplesPath + 'item-hold/cancel-request.json')
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 401
#    Changes done for FAT-1574

  Scenario: Start recall Item negative call
    * if (proxyCall == false) karate.abort()
    * print 'Start recall item negative call'
    * def proxyUrl = proxyPath + '/circ/recall/' + trackingID + '/' + centralCode
    * proxyHeader.Authorization = 'Bearer 12345678'
    * configure headers = proxyHeader
    Given url proxyUrl
    And request read(samplesPath + 'patron-hold/recall-request.json')
    And retry until responseStatus == 401
    When method PUT
    Then status 401

  Scenario: Start Item in transit negative call
    * if (proxyCall == false) karate.abort()
    * print 'Start Item in transit negative call'
    * def proxyUrl = proxyPath + '/circ/intransit/' + itemTrackingID + '/' + centralCode
    * proxyHeader.Authorization = 'Bearer 12345678'
    * configure headers = proxyHeader
    Given url proxyUrl
    And request read(samplesPath + 'item-hold/in-transit-request.json')
    And retry until responseStatus == 401
    When method PUT
    Then status 401

#    FAT-1577 - Changes Start.
  Scenario: Update the transaction when the return uncirculated message is received negative call
    * if (proxyCall == false) karate.abort()
    * print 'Update the transaction when the return uncirculated message is received negative call'
    * def proxyUrl = proxyPath + '/circ/returnuncirculated/' + itemTrackingID + '/' + centralCode
    * proxyHeader.Authorization = 'Bearer 12345678'
    * configure headers = proxyHeader
    Given url proxyUrl
    And request read(samplesPath + 'item-hold/uncirculated-request.json')
    And retry until responseStatus == 401
    When method PUT
    Then status 401
#    FAT-1577 - End.

  Scenario: Delete central servers
    * print 'Delete central servers'
    * def deletePath = proxyCall == true ? edgeFeaturesPath : featuresPath
    * call read(deletePath + 'central-server.feature@delete')