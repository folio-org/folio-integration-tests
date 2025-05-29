Feature: Data Import Test Suite

  Background:
    # This runs only once for the entire test run
    * def setupData = karate.callSingle('this:create-marc-records.feature')
    * def instanceRecordId = setupData.instanceRecordId
    * def holdingsRecordId = setupData.holdingsRecordId
    * def authorityId = setupData.authorityId
    * def authorityRecordId = setupData.authorityRecordId
    * def invalidAuthorityId = setupData.invalidAuthorityId
    * def invalidAuthorityRecordId = setupData.invalidAuthorityRecordId


  Scenario: Marc Records Tests
    * call read('this:marc-records/all.feature')

  Scenario: Edifact Tests
    * call read('this:edifact/import-edi-invoice.feature')

  Scenario: Logging Tests
    * call read('this:logging/all.feature')
