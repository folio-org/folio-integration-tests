Feature: calls for inventory storage related data setup

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def prepareHolding = function(holding, instanceId) {return holding.replaceAll("replace_instanceId", instanceId);}
    * def prepareItem = function(item, holdingId) {return item.replaceAll("replace_holdingId", holdingId);}

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
    * def institution = read('classpath:samples/location/institution.json')
    Given path 'location-units/institutions'
    And request institution
    When method POST

  @PostInstance
  Scenario: create instance
    Given path 'instance-storage/instances'
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = 'inst' + random(100000) + randomString(7)
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

  @PostAuthority
  Scenario: create authority
    Given path 'authority-storage/authorities'
    And request read('classpath:samples/authority.json')
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
    And call pause 100