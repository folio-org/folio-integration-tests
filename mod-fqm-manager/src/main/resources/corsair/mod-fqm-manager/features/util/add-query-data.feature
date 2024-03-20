Feature: Add FQM query data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Add sample data needed for FQM queries
    # Add address type
    * def addressRequest = {addressType:  'Home address', id:  '12345678-a4ef-47ca-b29c-0a5ad7bbf321'}
    Given path '/addresstypes'
    And request addressRequest
    When method POST
    Then status 201

    # Add users
    * def userRequest = read('classpath:corsair/mod-fqm-manager/features/samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId = $.id

    * userRequest.username = 'integration_test_user_456'
    * userRequest.id = '00000000-1111-2222-9999-44444444442'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * userRequest.username = 'integration_test_other_user'
    * userRequest.id = '00000000-1111-2222-9999-44444444443'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * userRequest.username = 'user_to_delete'
    * userRequest.id = '00000000-1111-2222-9999-44444444444'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * def userRequest = read('classpath:corsair/mod-fqm-manager/features/samples/user-request-with-address.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * def userRequest = read('classpath:corsair/mod-fqm-manager/features/samples/user-request-missing-address-fields.json')
    Given path '/users'
    And request userRequest
    When method POST
    Then status 201

    # Add instance type
    * def instanceTypeId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804f'
    * def instanceTypeRequest = {id: '#(instanceTypeId)', 'name': 'still image', "code": 'sti', "source": 'rdacarrier'}
    Given path '/instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    # Add instance
    * def instanceId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804e'
    * def instanceRequest = {id: '#(instanceId)', title:  'Some title', source: 'Local', instanceTypeId: '#(instanceTypeId)'}
    Given path '/instance-storage/instances'
    And request instanceRequest
    When method POST
    Then status 201

    # Add institution
    * def institutionId = call uuid1
    * def institutionRequest = {id: '#(institutionId)', name: 'Main Institution', code: 'MI'}
    Given path '/location-units/institutions'
    And request institutionRequest
    When method POST
    Then status 201

    # Add campus
    * def campusId = call uuid1
    * def campusRequest = {id: '#(campusId)', institutionId: '#(institutionId)', name: 'Main Campus', code: 'MC'}
    Given path '/location-units/campuses'
    And request campusRequest
    When method POST
    Then status 201

    # Add library
    * def libraryId = call uuid1
    * def libraryRequest = {id: '#(libraryId)', campusId: '#(campusId)', name: 'Main Campus', code: 'MC'}
    Given path '/location-units/libraries'
    And request libraryRequest
    When method POST
    Then status 201

    # Add location
    * def servicePointId = call uuid1
    * def permanentLocationId = call uuid1
    * def locationRequest = {id:  '#(permanentLocationId)', name: 'Location 1', code: 'loc1', primaryServicePoint: '#(servicePointId)', libraryId:  '#(libraryId)', campusId:  '#(campusId)', institutionId: '#(institutionId)', servicePointIds:  ['#(servicePointId)']}
    Given path '/locations'
    And request locationRequest
    When method POST
    Then status 201

    # Add holdings
    * def holdingsId = call uuid1
    * def holdingsRequest = {id: '#(holdingsId)', instanceId: '#(instanceId)', permanentLocationId:  '#(permanentLocationId)'}
    Given path '/holdings-storage/holdings'
    And request holdingsRequest
    When method POST
    Then status 201

    # Add loan type
    * def loanTypeId = call uuid1
    * def loanTypeRequest = {id: '#(loanTypeId)', name: 'Can circulate', source: 'System'}
    Given path '/loan-types'
    And request loanTypeRequest
    When method POST
    Then status 201

    # Add material type
    * def materialTypeId = '2ee721ab-70e5-49a6-8b09-1af0217ea3fc'
    * def materialTypeRequest = {id: '#(materialTypeId)', name: 'book'}
    Given path '/material-types'
    And request materialTypeRequest
    When method POST
    Then status 201

    # Add item
    * def itemId = call uuid1
    * def itemRequest = {id: '#(itemId)', holdingsRecordId: '#(holdingsId)', status:  {name: 'Checked out'}, permanentLoanTypeId: '#(loanTypeId)', materialTypeId: '#(materialTypeId)'}
    Given path '/item-storage/items'
    And request itemRequest
    When method POST
    Then status 201

    # Add loans
    * def loanId = call uuid1
    * def loanRequest = {id: '#(loanId)', itemId:  '#(itemId)', action: 'checkedout', loanDate:  '2017-03-01T23:11:00-01:00', userId: '#(userId)'}
    Given path '/loan-storage/loans'
    And request loanRequest
    When method POST
    Then status 201

    # Add purchase order
    * def orderId = call uuid1
    * def orderRequest = {id: '#(orderId)', metadata: {createdDate: '2018-08-19T00:00:00.000+0000'}}
    Given path '/orders-storage/purchase-orders'
    And request orderRequest
    When method POST
    Then status 201

     #Add Purchase Order Line
    * def purchaseOrderLineId = call uuid1
    * def fundDistribution = [{ "code": "serials", "value": 100.0 , "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]
    * def purchaseOrderLineRequest = {id: '#(purchaseOrderLineId)', orderFormat:'P/E Mix' ,source:'User', purchaseOrderId:'#(orderId)', titleOrPackage: 'Kayak Fishing in the Northern Gulf Coast', paymentStatus: 'Fully Paid', fundDistribution : '#(fundDistribution)'}
    Given path '/orders-storage/po-lines'
    And request purchaseOrderLineRequest
    When method POST

     #Add Organizations
    * def  organizationsId  = call uuid1
    * def organizationsRequest = {id: '#(organizationsId)', name: "test organization", status: "Active", code: "test"}
    Given path '/organizations-storage/organizations'
    And request organizationsRequest
    When method POST
