Feature: Test Data-Import authority records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:folijet/data-import/samples/'
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'

    * def testAuthorityId = karate.properties['authorityId']
    * def testAuthorityRecordId = karate.properties['authorityRecordId']
    * def testInvalidAuthorityId = karate.properties['invalidAuthorityId']
    * def testInvalidAuthorityRecordId = karate.properties['invalidAuthorityRecordId']

  # ================= positive test cases =================

  Scenario: Contains a valid 1XX
    Given path '/source-storage/source-records', testAuthorityRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].100 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    And def personalNameTitle = response.personalNameTitle
    And match personalNameTitle != null
    And match personalNameTitle == "Johnson, W. Brad"

  Scenario: Record should contains a 001 value
    Given path '/source-storage/source-records', testAuthorityRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].001 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def identifiers = response.identifiers
    And match identifiers != null
    And match identifiers[0].value == "n  00001263 "

  Scenario: Test includes more than one Authority record
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    And retry until response.totalRecords > 1
    When method get
    Then status 200

  # ================= negative test cases =================

  Scenario: Contains an invalid 1XX
    Given path '/source-storage/source-records', testInvalidAuthorityRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].100 == []

    Given path 'authority-storage/authorities', testInvalidAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def personalNameTitle = response.personalNameTitle
    And match personalNameTitle == null


  Scenario: Contains No 001 value
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityInvalid', jobName:'createAuthority' }
    Then match status == 'ERROR'
