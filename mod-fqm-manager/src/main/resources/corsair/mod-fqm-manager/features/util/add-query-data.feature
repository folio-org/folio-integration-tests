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

    # Add instance type
    * def instanceTypeId = call uuid1
    * def instanceTypeRequest = {id: '#(instanceTypeId)', 'name': 'still image', "code": 'sti', "source": 'rdacarrier'}
    Given path '/instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    # Add instance
    * def instanceId = call uuid1
    * def instanceRequest = {id: '#(instanceId)', title:  'Some title', source: 'Local', instanceTypeId:  '#(instanceTypeId)'}
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
    * def materialTypeId = call uuid1
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

