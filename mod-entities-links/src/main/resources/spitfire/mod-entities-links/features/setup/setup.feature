Feature: Setup entities-links

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/samples/setup-records'

    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'
    * def instanceId = '337d160e-a36b-4a2b-b4c1-3589f230bd2c'
    * def instanceHrid = 'in00000000001'

  Scenario: Create snapshot
    Given path 'source-storage/snapshots'
    And request { 'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS' }
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('snapshotId', snapshotId)

  Scenario: Create instance record
    Given path 'instance-storage/instances'
    And request read(samplePath + 'setup-records/instance.json')
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('instanceId', instanceId)

  Scenario: Create authority record
    * def authorityId = uuid()
    Given path 'authority-storage/authorities'
    And request read(samplePath + 'setup-records/authority.json')
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('authorityId', authorityId)