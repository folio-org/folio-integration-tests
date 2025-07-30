Feature: inventory

  Background:
    * url baseUrl
    * def util1 = call read('classpath:common/util/uuid1.feature')
    * def samplesPath = 'classpath:folijet/mod-inventory/samples/'
    * def snapshotPath = samplesPath + 'snapshot.json'
    * def recordPath = samplesPath + 'record.json'

    * def defaultPermanentLocationId = '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'

  @PostHoldingsSource
  Scenario: create holdings sources
    Given path 'holdings-sources'
    And request holdingsSource
    When method POST

  @UpdateInstance
  Scenario: Update an instance
    Given path 'inventory/instances/' + instanceId
    And request instance
    When method PUT
    Then status 204

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
    And def barcode = karate.get('barcode', util1.uuid1())
    And request read(samplesPath + 'items.json')
    When method POST
    Then status 201

    And def id = response.id
    And def effectiveLocationId = response.effectiveLocation.id

  @CreateSnapshot
  Scenario: Create Snapshot
    * def snapshotId = uuid()
    * def snapshot = read(snapshotPath)

    #   Create snapshot
    Given path 'source-storage','snapshots'
    And request snapshot
    When method POST
    Then status 201
    And def id = response.jobExecutionId

  @CreateRecord
  Scenario: Create Record
    * def recordId = uuid()
    * def record = read(recordPath)

    # Create record
    Given path 'source-storage','records'
    And request record
    When method POST
    Then status 201
    And def id = response.id