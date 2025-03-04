Feature: MARC Derived Records

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Validate MARC derived record
    * def getMarcCall = call getDerivedMarc { resourceId:  '#(instanceId)' }
    * match getMarcCall.response.parsedRecord.content.fields contains { 001: "#(hrid)" }
    * match getMarcCall.response.parsedRecord.content.fields contains { 005: "#notnull" }
