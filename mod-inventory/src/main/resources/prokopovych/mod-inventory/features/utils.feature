Feature: inventory

  Background:
    * url baseUrl
    * def vndHeaders = { 'x-okapi-token': '#(okapitoken)' }
    * def samplesPath = 'classpath:prokopovych/mod-inventory/samples/'

    * def defaultPermanentLocationId = '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'

  @CreateInstance
  Scenario: Create Instance
    Given path 'inventory/instances'
    And request read(samplesPath + 'instance.json')
    When method POST
    Then status 201

    And def location = responseHeaders['Location'][0]
    And def id = location.substring(location.lastIndexOf('/') + 1)

  @CreateHoldings
  Scenario: Create Holdings
    Given path 'holdings-storage/holdings'
    ### Get value or set default
    And def permanentLocationId = karate.get('permanentLocationId', defaultPermanentLocationId)
    And request read(samplesPath + 'holdings.json')
    When method POST
    Then status 201

    And def id = response.id
    And def hrid = response.hrid
    And def effectiveLocationId = response.effectiveLocationId

  @CreateItems
  Scenario: Create Items
    Given path 'inventory/items'
    ### Get value or set default
    And def permanentLocationId = karate.get('permanentLocationId', defaultPermanentLocationId)
    And def barcode = karate.get('barcode', uuid())
    And request read(samplesPath + 'items.json')
    When method POST
    Then status 201

    And def id = response.id
    And def effectiveLocationId = response.effectiveLocation.id
