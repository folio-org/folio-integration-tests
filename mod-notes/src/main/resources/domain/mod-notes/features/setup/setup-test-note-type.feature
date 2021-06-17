Feature: Setup mod-notes

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * def noteTypePayload = read('classpath:domain/mod-notes/features/samples/valid/note-type.json')

  Scenario: Post new note type
    Given path '/note-types'
    And headers headersUser
    * def testNoteTypeName = noteTypePayload.name + '1'
    * set noteTypePayload.name = testNoteTypeName
    And request noteTypePayload
    When method POST
    Then status 201
    * def testNoteType = $