Feature: Get Default note type
  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

  Scenario: Get Default note type
    Given path '/note-types'
    And headers headersUser
    When method GET
    Then status 200
    * def defaultNoteType = get[0] $.noteTypes[?(@.name=='General note')]
    And match defaultNoteType.id == '#uuid'
    And match defaultNoteType.metadata.createdByUsername == '#notpresent'
    And match defaultNoteType.metadata.createdByUserId == '#notpresent'
    And match defaultNoteType.metadata.updatedByUserId == '#notpresent'
    And match defaultNoteType.metadata.createdDate == '#present'
