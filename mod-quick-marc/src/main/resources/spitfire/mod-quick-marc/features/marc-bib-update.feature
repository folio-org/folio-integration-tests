Feature: Test quickMARC bib update
  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

    * def snapshotId = karate.properties['snapshotId']
    * def instanceId = uuid()
    * def instanceHrid = 'in' + ("00000000000" + Math.floor(Math.random() * 10000000000)).slice(-11);

  Scenario: Edit quickMarcJson
    * call read('setup/setup.feature@CreateMarcBib') {id: #(instanceId), hrid: #(instanceHrid)}

    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
    * def recordId = quickMarcJson.parsedRecordId
    * def fields = quickMarcJson.fields
    * def newField = { "tag": "500", "indicators": [ "\\", "\\" ], "content": "$a Test note", "isProtected":false }
    * fields.push(newField);
    * set quickMarcJson.fields = fields
    * set quickMarcJson.relatedRecordVersion = 1
    * set quickMarcJson._actionType = 'edit'
    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    And retry until response.updateInfo.recordState == 'ACTUAL'
    When method GET
    Then status 200
    * def result = $
    And match result.fields contains newField
