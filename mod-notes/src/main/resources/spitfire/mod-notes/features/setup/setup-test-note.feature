Feature: Setup mod-notes

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * def result = call read(featuresPath + 'setup/get-default-note-type.feature')
    * def defaultNoteTypeId = result.defaultNoteType.id

  Scenario: Post new note
    Given path '/notes'
    And headers headersUser
    And request read(featuresPath + "samples/note-put.json")
    When method POST
    Then status 201
    * def testNote = $