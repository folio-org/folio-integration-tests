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
  Scenario: create instance type
    Given path 'instance-types'
    And request instanceType
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
    * def campus = read('classpath:samples/location/campus.json')
    Given path 'location-units/campuses'
    And request campus
    When method POST
    Then status 201

  @PostLibrary
  Scenario: create library
    * def library = read('classpath:samples/location/library.json')
    Given path 'location-units/libraries'
    And request library
    When method POST
    Then status 201

  @PostInstitution
  Scenario: create institution
    * def institution = read('classpath:samples/location/institution.json')
    Given path 'location-units/institutions'
    And request institution
    When method POST
    Then status 201

    ### other common data related requests

  @PostCallNumberType
  Scenario: create call number type
    * def callNumberType = read('classpath:samples/call_number/call_number_type.json')
    Given path 'call-number-types'
    And request callNumberType
    When method POST
    Then status 201

  @PostIllPolicy
  Scenario: create ill policy type
    * def illPolicy = read('classpath:samples/ill_policy/Ill_policy.json')
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
    * def materialType = read('classpath:samples/material_type/item_material_type.json')
    Given path 'material-types'
    And request materialType
    When method POST
    Then status 201

  @PostHoldingNoteType
  Scenario: create holding note type
    * def noteType = read('classpath:samples/note/holdings_note_type.json')
    Given path 'holdings-note-types'
    And request noteType
    When method POST
    Then status 201

  @PostItemNoteType
  Scenario: create item note type
    * def noteType = read('classpath:samples/note/item_note_type.json')
    Given path 'item-note-types'
    And request noteType
    When method POST
    Then status 201

  @PostItemStatisticalCodeType
  Scenario: create item statistical code type
    * def itemStatisticalCodeType = read('classpath:samples/statistical_code/item_statistical_code_type.json')
    Given path 'statistical-code-types'
    And request itemStatisticalCodeType
    When method POST
    Then status 201

  @PostItemStatisticalCode
  Scenario: create item statistical code
    * def itemStatisticalCode = read('classpath:samples/statistical_code/item_statistical_code.json')
    Given path 'statistical-codes'
    And request itemStatisticalCode
    When method POST
    Then status 201