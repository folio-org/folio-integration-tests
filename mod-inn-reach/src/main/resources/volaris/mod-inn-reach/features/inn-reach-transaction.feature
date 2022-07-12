@ignore
@parallel=false
Feature: Inn reach transaction

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-to-code': 'fli01' , 'x-from-code': 'd2ir', 'x-d2ir-authorization':'auth','Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'x-to-code': 'fli01','x-from-code': 'd2ir', 'x-d2ir-authorization':'auth','Accept': 'application/json'  }

    * configure headers = headersUser
    * configure retry = { interval: 5000, count: 5 }
    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def mappingPath1 = centralServer1.id + '/item-type-mappings'
    * def patronmappingPath1 = centralServer1.id + '/patron-type-mappings'
    * callonce read(globalPath + 'common-schemas.feature')
    * def emptyMappingsSchema = {itemTypeMappings: '#[0]', totalRecords: 0}
    * def mappingItemSchema = read(samplesPath + 'item-type-mapping/item-type-mapping-schema.json')
    * def patronId = '2bc26e0c-db89-4a21-88e9-3177d03f222f'
    * def patronName = call random_string
    * def status = true
    * def lastName = call random_string
    * def firstName = call random_string
    * def username = call random_string
    * def email = 'abc@pqr.com'
    * def barcode = '912235'
    * def itemBarcode = '7010'
    * def incorrectItemBarcode = '7099'
    * def trackingID = '1067'
    * def centralCode = 'd2ir'
    * def tempPatronGroupId = ''
    * def servicePointId = '9bfc5298-72fa-41ba-95a7-fc1cc6c3db8c'
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
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
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


  Scenario: Start ItemHold
    * print 'Start ItemHold'
    Given path '/inn-reach/d2ir/circ/itemhold/', trackingID , '/' , centralCode
    And request read(samplesPath + 'item-hold/transaction-hold-request.json')
    When method POST
    Then status 200

 # Positive case
  Scenario: Start Checkout item
    * print 'Start checkout'
    Given path '/inn-reach/transactions/', itemBarcode ,'/check-out-item/', servicePointId
    And retry until responseStatus == 200
    When method POST
    Then status 200
    And match response.transaction == '#notnull'
    And match response.transaction.state == 'ITEM_SHIPPED'

     # Negative case
  Scenario: Start Checkout item
    * print 'Start checkout'
    Given path '/inn-reach/transactions/', incorrectItemBarcode ,'/check-out-item/', servicePointId
    When method POST
    Then status 404

