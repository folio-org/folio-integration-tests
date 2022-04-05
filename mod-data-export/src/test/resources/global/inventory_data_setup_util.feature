Feature: calls for inventory storage related data setup

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def prepareHolding = function(holding, instanceId) {return holding.replaceAll("replace_instanceId", instanceId);}
    * def prepareItem = function(item, holdingId) {return item.replaceAll("replace_holdingId", holdingId);}

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