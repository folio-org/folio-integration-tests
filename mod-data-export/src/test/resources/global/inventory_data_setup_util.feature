Feature: calls for inventory storage related data setup

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def prepareHolding = function(holding, instanceId) {return holding.replaceAll("replace_instanceId", instanceId);}
    * def prepareItem = function(item, holdingId) {return item.replaceAll("replace_holdingId", holdingId);}

  @PostInstance
  Scenario: create instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = 'inst' + random(100000)
    And request instance
    When method POST
    Then status 201

  @PostHolding
  Scenario: create holding
    * string holdingTemplate = read('classpath:samples/holding.json')
    * json holding = prepareHolding(holdingTemplate, instanceId);
    * set holding.id = holdingId;
    Given path 'holdings-storage/holdings'
    And request holding
    When method POST
    Then status 201

  @PostItem
  Scenario: create item
    * string itemTemplate = read('classpath:samples/item.json')
    * json item = prepareItem(itemTemplate, holdingId);
    * set item.barcode = barcode;
    Given path 'item-storage/items'
    And request item
    When method POST
    Then status 201
    And call pause 150

  @PostInstanceType
  Scenario: create instance type if not exists
    Given path 'instance-types'
    And request instanceType
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
    * def campus = read('classpath:samples/location/campus.json')
    Given path 'location-units/campuses'
    And request campus
    When method POST

  @PostLibrary
  Scenario: create library if not exists
    * def library = read('classpath:samples/location/library.json')
    Given path 'location-units/libraries'
    And request library
    When method POST

  @PostInstitution
  Scenario: create institution if not exists
    * def institution = read('classpath:samples/location/institution.json')
    Given path 'location-units/institutions'
    And request institution
    When method POST

    ### other common data related requests

  @PostCallNumberType
  Scenario: create call number type if not exists
    * def callNumberType = read('classpath:samples/call_number/call_number_type.json')
    Given path 'call-number-types'
    And request callNumberType
    When method POST

  @PostIllPolicy
  Scenario: create ill policy type if not exists
    * def illPolicy = read('classpath:samples/ill_policy/Ill_policy.json')
    Given path 'ill-policies'
    And request illPolicy
    When method POST

  @PostLoanType
  Scenario: create loan type type if not exists
    Given path 'loan-types'
    And request loanType
    When method POST


  @PostMaterialType
  Scenario: create material type if not exists
    * def materialType = read('classpath:samples/material_type/item_material_type.json')
    Given path 'material-types'
    And request materialType
    When method POST

  @PostHoldingNoteType
  Scenario: create holding note type if not exists
    * def noteType = read('classpath:samples/note/holdings_note_type.json')
    Given path 'holdings-note-types'
    And request noteType
    When method POST

  @PostItemNoteType
  Scenario: create item note type if not exists
    * def noteType = read('classpath:samples/note/item_note_type.json')
    Given path 'item-note-types'
    And request noteType
    When method POST

  @PostItemStatisticalCodeType
  Scenario: create item statistical code type if not exists
    * def itemStatisticalCodeType = read('classpath:samples/statistical_code/item_statistical_code_type.json')
    Given path 'statistical-code-types'
    And request itemStatisticalCodeType
    When method POST

  @PostItemStatisticalCode
  Scenario: create item statistical code if not exists
    * def itemStatisticalCode = read('classpath:samples/statistical_code/item_statistical_code.json')
    Given path 'statistical-codes'
    And request itemStatisticalCode
    When method POST