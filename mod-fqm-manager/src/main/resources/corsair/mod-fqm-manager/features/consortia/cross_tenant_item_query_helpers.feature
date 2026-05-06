Feature: Cross-tenant item query helpers

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 20, interval: 15000 }

  @ignore @InstallEntityTypes
  Scenario: Install entity types in a tenant
    * call login user
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)', 'Accept': 'application/json' }

    Given path 'entity-types', 'install'
    When method POST
    Then status 204

    Given path 'entity-types', itemEntityTypeId
    And retry until responseStatus == 200
    When method GET
    Then status 200

  @ignore @CreateReferenceData
  Scenario: Create inventory reference data for item query tests
    * call login user
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)', 'Accept': 'application/json' }
    * def referenceSuffix = randomMillis()
    * def institutionId = uuid()
    * def campusId = uuid()
    * def libraryId = uuid()
    * def servicePointId = uuid()
    * def locationId = uuid()
    * def holdingsSourceId = uuid()
    * def instanceTypeId = uuid()
    * def loanTypeId = uuid()
    * def materialTypeId = uuid()

    * def institutionRequest = ({ id: institutionId, name: codePrefix + ' institution', code: codePrefix + 'i' + referenceSuffix })
    Given path 'location-units', 'institutions'
    And request institutionRequest
    When method POST
    Then status 201

    * def campusRequest = ({ id: campusId, institutionId: institutionId, name: codePrefix + ' campus', code: codePrefix + 'c' + referenceSuffix })
    Given path 'location-units', 'campuses'
    And request campusRequest
    When method POST
    Then status 201

    * def libraryRequest = ({ id: libraryId, campusId: campusId, name: codePrefix + ' library', code: codePrefix + 'l' + referenceSuffix })
    Given path 'location-units', 'libraries'
    And request libraryRequest
    When method POST
    Then status 201

    * def locationRequest = ({ id: locationId, name: codePrefix + ' location', code: codePrefix + 'loc' + referenceSuffix, primaryServicePoint: servicePointId, libraryId: libraryId, campusId: campusId, institutionId: institutionId, servicePointIds: [servicePointId] })
    Given path 'locations'
    And request locationRequest
    When method POST
    Then status 201

    * def holdingsSourceRequest = ({ id: holdingsSourceId, name: codePrefix + ' holdings source', source: 'local' })
    Given path 'holdings-sources'
    And request holdingsSourceRequest
    When method POST
    Then status 201

    * def instanceTypeRequest = ({ id: instanceTypeId, name: codePrefix + ' instance type', code: codePrefix + 'it' + referenceSuffix, source: 'rdacarrier' })
    Given path 'instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    * def loanTypeRequest = ({ id: loanTypeId, name: codePrefix + ' loan type', source: 'System' })
    Given path 'loan-types'
    And request loanTypeRequest
    When method POST
    Then status 201

    * def materialTypeRequest = ({ id: materialTypeId, name: codePrefix + ' material type' })
    Given path 'material-types'
    And request materialTypeRequest
    When method POST
    Then status 201

  @ignore @CreateInstanceHoldingItem
  Scenario: Create an instance, holding, and item in a tenant
    * call login user
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)', 'Accept': 'application/json' }

    * def instanceRequest = ({ id: instanceId, title: instanceTitle, source: instanceSource, instanceTypeId: refData.instanceTypeId })
    Given path 'instance-storage', 'instances'
    And request instanceRequest
    When method POST
    Then status 201

    * def holdingRequest = ({ id: holdingId, instanceId: instanceId, permanentLocationId: refData.locationId, sourceId: refData.holdingsSourceId })
    Given path 'holdings-storage', 'holdings'
    And request holdingRequest
    When method POST
    Then status 201

    * def itemRequest = ({ id: itemId, holdingsRecordId: holdingId, barcode: barcode, status: { name: 'Available' }, permanentLoanTypeId: refData.loanTypeId, materialTypeId: refData.materialTypeId })
    Given path 'item-storage', 'items'
    And request itemRequest
    When method POST
    Then status 201
    * def itemCreatedDate = response.metadata.createdDate.substring(0, 10)
