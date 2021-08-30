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
    * def callNumberType = read('classpath:domain/data-import/samples/call_number/call_number_type.json')
    Given path 'call-number-types'
    And request callNumberType
    When method POST
    Then status 201

  @PostIllPolicy
  Scenario: create ill policy type
    * def illPolicy = read('classpath:domain/data-import/samples/ill_policy/Ill_policy.json')
    Given path 'ill-policies'
    And request illPolicy
    When method POST
    Then status 201

  @PostLoanType
  Scenario: create loan type type
    Given path 'loan-types'
    And request loanType
    When method POST
    Then status 201


  @PostMaterialType
  Scenario: create material type
    * def materialType = read('classpath:domain/data-import/samples/material_type/item_material_type.json')
    Given path 'material-types'
    And request materialType
    When method POST
    Then status 201

  @PostHoldingNoteType
  Scenario: create holding note type
    * def noteType = read('classpath:domain/data-import/samples/note/holdings_note_type.json')
    Given path 'holdings-note-types'
    And request noteType
    When method POST
    Then status 201

  @PostItemNoteType
  Scenario: create item note type
    * def noteType = read('classpath:domain/data-import/samples/note/item_note_type.json')
    Given path 'item-note-types'
    And request noteType
    When method POST
    Then status 201

  @PostItemStatisticalCodeType
  Scenario: create item statistical code type
    * def itemStatisticalCodeType = read('classpath:domain/data-import/samples/statistical_code/item_statistical_code_type.json')
    Given path 'statistical-code-types'
    And request itemStatisticalCodeType
    When method POST
    Then status 201

  @PostItemStatisticalCode
  Scenario: create item statistical code
    * def itemStatisticalCode = read('classpath:domain/data-import/samples/statistical_code/item_statistical_code.json')
    Given path 'statistical-codes'
    And request itemStatisticalCode
    When method POST
    Then status 201