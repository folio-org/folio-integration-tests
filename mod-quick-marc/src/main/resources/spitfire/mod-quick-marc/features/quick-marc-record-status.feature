Feature: Test quickMARC for record status
  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def recordPayload = read('classpath:spitfire/mod-quick-marc/features/setup/samples/parsed-records/bib-record.json')

#   ================= positive test cases =================
  Scenario: Create record
    Given path 'records-editor/records'
    And headers headersUser
    And request recordPayload
    When method POST
    Then status 201
    And assert response.status == 'NEW' || response.status == 'IN_PROGRESS'
    And match $.qmRecordId == '#uuid'
    And match $.jobExecutionId == '#uuid'

  Scenario: Retrieve record status after record creation
    Given path 'records-editor/records'
    And headers headersUser
    And request recordPayload
    When method POST
    Then status 201

    * def recordId = response.qmRecordId

    Given path 'records-editor/records/status'
    And headers headersUser
    And param qmRecordId = recordId
    When method GET
    Then status 200
    And match $.status == 'IN_PROGRESS'

#   ================= negative test cases =================
  Scenario: Parameter qmRecordId is required for getting record status
    Given path 'records-editor/records/status'
    And headers headersUser
    When method GET
    Then status 400
    And match response.message == "Parameter 'qmRecordId' is required"

  Scenario: Record was not found with invalid id
    Given path 'records-editor/records/status'
    * def invalidId = '1af1c1e1-a11c-1f1c-bd11-f111111f1111'
    And param qmRecordId = invalidId
    And headers headersUser
    When method GET
    Then status 404
    And match response.message == "Record with id [" + invalidId + "] was not found"
