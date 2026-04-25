Feature: inventory

  Background:
    * url baseUrl
    * def samplesPath = 'classpath:samples/'
    * def snapshotPath = samplesPath + 'snapshot.json'
    * def recordPath = samplesPath + 'record.json'

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
    And request read(samplesPath + 'simple_instance.json')
    When method POST
    Then status 201

    And def location = responseHeaders['Location'][0]
    And def id = location.substring(location.lastIndexOf('/') + 1)
    And def hrid = response.hrid

  @CreateHoldings
  Scenario: Create Holdings
    Given path 'holdings-storage/holdings'
    ### Get value or set default
    And def permanentLocationId = "d5629ec6-7259-4644-bb94-41bd30b2d1c6"
    And request read(samplesPath + 'simple_holdings.json')
    When method POST
    Then status 201

    And def id = response.id
    And def hrid = response.hrid
    And def effectiveLocationId = response.effectiveLocationId

  @CreateItems
  Scenario: Create Items
    Given path 'inventory/items'
    ### Get value or set default
    And def permanentLocationId = "d5629ec6-7259-4644-bb94-41bd30b2d1c6"
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

    Given path 'source-storage','snapshots'
    And request snapshot
    When method POST
    Then status 201
    And def id = response.jobExecutionId

  @CreateRecord
  Scenario: Create Record
    * def recordId = uuid()
    * def matchedId = uuid()
    * def record = read(recordPath)

    Given path 'source-storage','records'
    And request record
    When method POST
    Then status 201
    And def id = response.id
