Feature: calls for inventory storage related data setup

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  @PostInstanceType
  Scenario: create instance type if not exists
    Given path 'instance-types'
    And request instanceType
    When method POST

  @PostHoldingsType
  Scenario: create holdings type if not exists
    Given path 'holdings-types'
    And request holdingsType
    When method POST

  @PostIdentifierType
  Scenario: create identifier type if not exists
    Given path 'identifier-types'
    And request identifierType
    When method POST

  ### location related requests

  @PostLocation
  Scenario: create location if not exists
    Given path 'locations'
    And request location
    When method POST

  @PostCampus
  Scenario: create campus if not exists
    Given path 'location-units/campuses'
    And request campus
    When method POST

  @PostLibrary
  Scenario: create library if not exists
    Given path 'location-units/libraries'
    And request library
    When method POST

  @PostInstitution
  Scenario: create institution if not exists
    * def institution = read('classpath:folijet/data-import/samples/location/institution.json')
    Given path 'location-units/institutions'
    And request institution
    When method POST

    ### other common data related requests

  @PostCallNumberType
  Scenario: create call number type if not exists
    Given path 'call-number-types'
    And request callNumberType
    When method POST

  @PostItemLoanType
  Scenario: create loan type type if not exists
    Given path 'loan-types'
    And request itemLoanType
    When method POST


  @PostItemMaterialType
  Scenario: create item material type if not exists
    Given path 'material-types'
    And request materialType
    When method POST

  @PostStatisticalCodeType
  Scenario: create item statistical code type if not exists
    Given path 'statistical-code-types'
    And request statisticalCodeType
    When method POST

  @PostStatisticalCode
  Scenario: create item statistical code if not exists
    Given path 'statistical-codes'
    And request statisticalCode
    When method POST

  @PostUrlRelationship
  Scenario: create holdings url relationship if not exists
    Given path 'electronic-access-relationships'
    And request urlRelationship
    When method POST

  @PostInstanceStatusType
  Scenario: create item url relationship if not exists
    Given path 'instance-statuses'
    And request instanceStatusType
    When method POST

  @PostItemNoteType
  Scenario: create item note type if not exists
    Given path 'item-note-types'
    And request itemNoteType
    When method POST

  @PostIllPolicy
  Scenario: create ill policy type if not exists
    Given path 'ill-policies'
    And request illPolicy
    When method POST