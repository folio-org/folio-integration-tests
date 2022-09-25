Feature: Setup entities-links

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples/setup-records/'
    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'

  Scenario: Create instance type
    Given path 'instance-types'
    And request read(samplePath + 'instance-type.json')
    When method POST

  Scenario: Create snapshot
    Given path 'source-storage/snapshots'
    And request {'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS'}
    When method POST
    Then status 201

    * setSystemProperty('snapshotId', snapshotId)

  Scenario: Create instance record
    Given path 'instance-storage/instances'
    And request read(samplePath + 'instance.json')
    When method POST
    Then status 201
    Then def instanceId = response.id

    * setSystemProperty('instanceId', instanceId)

  Scenario: Create second instance record
    Given path 'instance-storage/instances'
    And request read(samplePath + 'instance.json')
    When method POST
    Then status 201
    Then def instanceId = response.id

    * setSystemProperty('secondInstanceId', instanceId)

  Scenario: Create authority record
    Given path 'authority-storage/authorities'
    And request read(samplePath + 'authority.json')
    When method POST
    Then status 201
    Then def authorityId = response.id

    * setSystemProperty('authorityId', authorityId)

  Scenario: Create second authority record
    Given path 'authority-storage/authorities'
    And request read(samplePath + 'authority.json')
    When method POST
    Then status 201
    Then def authorityId = response.id

    * setSystemProperty('secondAuthorityId', authorityId)