Feature: Setup mod-notes

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * def result = call read('classpath:spitfire/mod-notes/features/setup/get-default-note-type.feature')
    * def defaultNoteTypeId = result.defaultNoteType.id

  Scenario: Post new note
    Given path '/notes'
    And headers headersUser
    And request
    """
    {
      type: Low Priority,
      title : BU Campus Access Issues,
      content: There have been access issues at the BU campus since the weekend,
      typeId: #(defaultNoteTypeId),
      domain: eholdings,
      links: [
        {
          id: 583-2356521,
          type: package
        }
      ]
    }
    """
    When method POST
    Then status 201
    * def testNote = $