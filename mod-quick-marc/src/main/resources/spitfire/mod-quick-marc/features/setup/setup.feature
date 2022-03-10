Feature: Setup quickMARC

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/setup/samples/'
    * def utilFeature = 'classpath:spitfire/mod-quick-marc/features/setup/import-record.feature'

  Scenario: Setup locations
    Given path 'location-units/institutions'
    And headers headersUser
    And request read(samplePath + 'locations/institution.json')
    When method POST

    Given path 'location-units/campuses'
    And headers headersUser
    And request read(samplePath + 'locations/campus.json')
    When method POST

    Given path 'location-units/libraries'
    And headers headersUser
    And request read(samplePath + 'locations/library.json')
    When method POST

    Given path 'locations'
    And headers headersUser
    And request read(samplePath + 'locations/location.json')
    When method POST

  Scenario: Setup record types
    Given path 'holdings-sources'
    And headers headersUser
    And request
    """
      {
       "id": "036ee84a-6afd-4c3c-9ad3-4a12ab875f59",
       "name": "FOLIO"
      }
    """
    When method POST

    Given path 'instance-types'
    And headers headersUser
    And request read(samplePath + 'record-types/instance-type.json')
    When method POST

    Given path 'holdings-types'
    And headers headersUser
    And request read(samplePath + 'record-types/holdings-type.json')
    When method POST

  Scenario: Import MARC-BIB record
    Given call read(utilFeature+'@ImportRecord') { fileName:'summerland', jobName:'deriveInstance' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

    * def testInstanceId = response.sourceRecords[0].externalIdsHolder.instanceId
    * setSystemProperty('instanceId', testInstanceId)

  Scenario: Import MARC-HOLDINGS record
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldings', jobName:'createHoldings' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

    * def testHoldingsId = response.sourceRecords[0].externalIdsHolder.holdingsId
    * setSystemProperty('holdingsId', testHoldingsId)
    * setSystemProperty('holdingsJobId', jobExecutionId)

  Scenario: Create MARC-HOLDINGS via quick-marc
    Given path 'records-editor/records'
    And headers headersUser
    And request read(samplePath + 'parsed-records/holdings.json')
    When method POST
    Then status 201
    Then match response.status == 'NEW'

    Given path 'records-editor/records/status'
    And param qmRecordId = response.qmRecordId
    And headers headersUser
    And retry until response.status == 'CREATED' || response.status == 'ERROR'
    When method GET
    Then status 200
    Then match response.status != 'ERROR'

    * setSystemProperty('QMHoldingsId', response.externalId)