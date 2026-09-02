Feature: Test quickMARC Edit BIB record

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

  @C417041
  Scenario: Edit quickMarcJson
    * def editBibId = uuid()
    * call read('setup/setup.feature@CreateMarcBib') {id: '#(editBibId)', hrid: '#("edit-bib-" + editBibId)'}

    Given path 'records-editor/records'
    And param externalId = editBibId
    And headers headersUser
    And retry until response.updateInfo.recordState == 'ACTUAL'
    When method GET
    Then status 200
    * def quickMarcJson = $
    * def recordId = quickMarcJson.parsedRecordId
    * def fields = quickMarcJson.fields
    * def initial005 = quickMarcJson.fields.find(f => f.tag == '005').content
    * def newField1 = { "tag": "500", "indicators": [ "\\", "\\" ], "content": "$a Test note", "isProtected":false }
    * def newField2 = { "tag": "248", "indicators": [ "a", "b" ], "content": "$a Local field $b repeatable1 $b repeatable2", "isProtected":false }
    * fields.push(newField1)
    * fields.push(newField2)
    * set quickMarcJson.fields = fields
    * set quickMarcJson._actionType = 'edit'

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = editBibId
    And headers headersUser
    And retry until response.updateInfo.recordState == 'ACTUAL'
    When method GET
    Then status 200
    * def result = $
    And match result.fields contains newField1
    And match result.fields contains newField2
    * def updated005 = result.fields.find(f => f.tag == '005').content
    * match updated005 != initial005
