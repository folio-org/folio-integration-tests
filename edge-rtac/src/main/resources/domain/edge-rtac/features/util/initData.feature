Feature: init data for edge-rtac

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }


  @PostModeOfIssuance
  Scenario: create mode of issuance
    * def modeOfIssuanceId = call random_uuid
    * def instanceModeOfIssuanceRequest = read('samples/instance/issuance-mode-request-entity.json')

    Given path 'modes-of-issuance'
    And headers headers
    And request instanceModeOfIssuanceRequest
    When method POST
    Then status 201

  @PostInstance
  Scenario: create instance
    * def instanceTypeId = call random_uuid
    * def contributorNameTypeId = call random_uuid
    * def instanceTypeEntityRequest = read('samples/instance/instance-type-entity-request.json')
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name + ' ' + random_string()
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code + ' ' + random_string()
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source + ' ' + random_string()

    Given path 'instance-types'
    And headers headers
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/instance/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.name = contributorNameTypeEntityRequest.name + ' ' + random_string()

    Given path 'contributor-name-types'
    And headers headers
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceId = call random_uuid
    * def instanceEntityRequest = read('samples/instance/instance-entity-request.json')

    Given path 'inventory', 'instances'
    And headers headers
    And request instanceEntityRequest
    When method POST
    Then status 201

  @PostServicePoint
  Scenario: create service point
    * def servicePointId = call random_uuid
    * def servicePointEntityRequest = read('samples/servicepoint/service-point-entity-request.json')
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()

    Given path 'service-points'
    And headers headers
    And request servicePointEntityRequest
    When method POST
    Then status 201

   @PostLocation
  Scenario: create location
    * def institutionId = call random_uuid
    * def campusId = call random_uuid
    * def libraryId = call random_uuid

    * def locationUnitInstitutionEntityRequest = read('samples/location/location-unit-institution-entity-request.json')
    * locationUnitInstitutionEntityRequest.name = locationUnitInstitutionEntityRequest.name + ' ' + random_string()

    Given path 'location-units', 'institutions'
    And headers headers
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('samples/location/location-unit-campus-entity-request.json')
    * locationUnitCampusEntityRequest.name = locationUnitCampusEntityRequest.name + ' ' + random_string()
    * locationUnitCampusEntityRequest.code = locationUnitCampusEntityRequest.code + ' ' + random_string()

    Given path 'location-units', 'campuses'
    And headers headers
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('samples/location/location-unit-library-entity-request.json')
    * locationUnitLibraryEntityRequest.name = locationUnitLibraryEntityRequest.name + ' ' + random_string()
    * locationUnitLibraryEntityRequest.code = locationUnitLibraryEntityRequest.code + ' ' + random_string()

    Given path 'location-units', 'libraries'
    And headers headers
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationId = call random_uuid
    * def locationEntityRequest = read('samples/location/location-entity-request.json')
    * locationEntityRequest.name = locationEntityRequest.name + ' ' + random_string()
    * locationEntityRequest.code = locationEntityRequest.code + ' ' + random_string()

    Given path 'locations'
    And headers headers
    And request locationEntityRequest
    When method POST
    Then status 201

  @PostHoldings
  Scenario: create holdings
    * def holdingId = call random_uuid
    * def holdingsEntityRequest = read('samples/holdings/holdings-entity-request.json')

    Given path 'holdings-storage', 'holdings'
    And headers headers
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostMaterialType
  Scenario: create material type
    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')

    Given path 'material-types'
    And headers headers
    And request materialTypeEntityRequest
    When method POST
    Then status 201

  @DeleteMaterialType
  Scenario: delete material type
  Given url baseUrl
    And  path 'material-types/' + materialTypeId
    And headers headers
    When method DELETE
    Then status 204

  @DeleteItems
  Scenario: delete items
  Given url baseUrl
    And  path 'inventory/items/' + expectedFirstItemId
    And headers headers
    When method DELETE
    Then status 204

  Given url baseUrl
    And  path 'inventory/items/' + expectedSecondItemId
    And headers headers
    When method DELETE
    Then status 204

  @PostItem
  Scenario: create item
    * def permanentLoanTypeId = call random_uuid

    * def permanentLoanTypeEntityRequest = read('samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And headers headers
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def itemId = call random_uuid
    * def itemEntityRequest = read('samples/item/item-entity-request.json')
    Given path 'inventory', 'items'
    And headers headers
    And request itemEntityRequest
    When method POST
    Then status 201
