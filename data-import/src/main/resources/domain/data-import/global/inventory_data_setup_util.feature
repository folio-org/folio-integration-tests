Feature: calls for inventory storage related data setup

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  @PostInstanceType
  Scenario: create instance type
    Given path 'instance-types'
    And request instanceType
    When method POST
    Then status 201

  @PostHoldingsType
  Scenario: create holdings type
    Given path 'holdings-types'
    And request holdingsType
    When method POST
    Then status 201

  @PostIdentifierType
  Scenario: create identifier type
    Given path 'identifier-types'
    And request identifierType
    When method POST
    Then status 201

  ### location related requests

  @PostLocation
  Scenario: create location
    Given path 'locations'
    And request location
    When method POST
    Then status 201

  @PostCampus
  Scenario: create campus
    Given path 'location-units/campuses'
    And request campus
    When method POST
    Then status 201

  @PostLibrary
  Scenario: create library
    Given path 'location-units/libraries'
    And request library
    When method POST
    Then status 201

  @PostInstitution
  Scenario: create institution
    * def institution = read('classpath:domain/data-import/samples/location/institution.json')
    Given path 'location-units/institutions'
    And request institution
    When method POST
    Then status 201

    ### other common data related requests

  @PostCallNumberType
  Scenario: create call number type
    Given path 'call-number-types'
    And request callNumberType
    When method POST
    Then status 201

  @PostItemLoanType
  Scenario: create loan type type
    Given path 'loan-types'
    And request itemLoanType
    When method POST
    Then status 201


  @PostItemMaterialType
  Scenario: create item material type
    Given path 'material-types'
    And request materialType
    When method POST
    Then status 201

  @PostStatisticalCodeType
  Scenario: create item statistical code type
    Given path 'statistical-code-types'
    And request statisticalCodeType
    When method POST
    Then status 201

  @PostStatisticalCode
  Scenario: create item statistical code
    Given path 'statistical-codes'
    And request statisticalCode
    When method POST
    Then status 201

  @PostUrlRelationship
  Scenario: create holdings url relationship
    Given path 'electronic-access-relationships'
    And request urlRelationship
    When method POST
    Then status 201

  @PostInstanceStatusType
  Scenario: create item url relationship
    Given path 'instance-statuses'
    And request instanceStatusType
    When method POST
    Then status 201

  @PostItemNoteType
  Scenario: create item note type
    Given path 'item-note-types'
    And request itemNoteType
    When method POST
    Then status 201