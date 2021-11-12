Feature: init data for edge-patron

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @PostItem
  Scenario: create item
    * def instanceTypeId = call uuid1
    * def instanceTypeEntityRequest = read('samples/item/instance-type-entity-request.json')
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name + ' ' + random_string()
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code + ' ' + random_string()
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source + ' ' + random_string()

    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

#   instance
    * def instanceId = call uuid1
    * def instanceEntityRequest = read('samples/item/instance-entity-request.json')

    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201
#   ServicePoint
    * def servicePointId = call uuid1
    * def servicePointEntityRequest = read('samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201
#   Location
    * def institutionId = call uuid1
    * def campusId = call uuid1
    * def libraryId = call uuid1
    * def locationId = call uuid1

    * def locationUnitInstitutionEntityRequest = read('samples/location/location-unit-institution-entity-request.json')
    * locationUnitInstitutionEntityRequest.name = locationUnitInstitutionEntityRequest.name + ' ' + random_string()
    Given path 'location-units', 'institutions'
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('samples/location/location-unit-campus-entity-request.json')
    * locationUnitCampusEntityRequest.name = locationUnitCampusEntityRequest.name + ' ' + random_string()
    * locationUnitCampusEntityRequest.code = locationUnitCampusEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'campuses'
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('samples/location/location-unit-library-entity-request.json')
    * locationUnitLibraryEntityRequest.name = locationUnitLibraryEntityRequest.name + ' ' + random_string()
    * locationUnitLibraryEntityRequest.code = locationUnitLibraryEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'libraries'
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationEntityRequest = read('samples/location/location-entity-request.json')
    * locationEntityRequest.name = locationEntityRequest.name + ' ' + random_string()
    * locationEntityRequest.code = locationEntityRequest.code + ' ' + random_string()
    Given path 'locations'
    And request locationEntityRequest
    When method POST
    Then status 201
#   Holdings
    * def holdingId = call uuid1
    * def holdingsEntityRequest = read('samples/item/holdings-entity-request.json')
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201
#   item
    * def permanentLoanTypeId = call uuid1
    * def permanentLoanTypeEntityRequest = read('samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()

    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.name = materialTypeEntityRequest.name + ' ' + random_string()
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item/item-entity-request.json')
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

  @PostPatronGroupAndUser
  Scenario: create PatronGroup & User
    * def patronId = call uuid1
    * def createPatronGroupRequest = read('samples/user/create-patronGroup-request.json')
    * createPatronGroupRequest.group = createPatronGroupRequest.group + ' ' + random_string()

    Given path 'groups'
    And request createPatronGroupRequest
    When method POST
    Then status 201

    * def createUserRequest = read('samples/User/create-user-request.json')

    Given path 'users'
    And request createUserRequest
    When method POST
    Then status 201

  @PostOwnerAndFine
  Scenario: create owner and fee/fine
    * def ownerId = call uuid1
    * def amount = call random_numbers
    * def createOwnerRequest = read('samples/fine/create-owner-entity.json')

    Given path 'owners'
    And request createOwnerRequest
    When method POST
    Then status 201

    * def feeFineId = call uuid1
    * def fineId = call uuid1
    * def createFineRequest = read('samples/fine/create-fee-entity-request.json')
    Given path 'accounts'
    And request createFineRequest
    When method POST
    Then status 201


