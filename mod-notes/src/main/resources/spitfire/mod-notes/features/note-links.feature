Feature: Note links

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def postNoteWithLinksPath = featuresPath + 'setup/setup-test-note.feature@PostNoteWithLinks';

  Scenario Outline: get notes by specific links
    And call read(postNoteWithLinksPath) {domain: <domain>, linkId: <linkId>, typeLink: <typeLink>}

    Given path '/note-links/domain/<domain>/type/<typeLink>/id/<linkId>'
    And headers headersUser
    When method GET
    Then status 200


    Examples:
      | domain    | typeLink | linkId                               |
      | eholdings | resource | 583-2356521-23456                    |
      | users     | user     | 8acab042-ce12-4d8f-bbe5-b1abe41d5d01 |


  Scenario Outline: should delete note when no link assigned

    #  create test note
    And call read(postNoteWithLinksPath) {domain: <domain>, linkId: <linkId>, typeLink: <typeLink>}
    And def noteId = $.id

    #  update note link
    Given path '/note-links/type/<typeLink>/id/<linkId>'
    And remove headersUser.Accept
    And headers headersUser
    And request
    """
    {
      notes : [
        {
          id : #(noteId),
          status : UNASSIGNED
        }
      ]
    }
    """
    When method PUT
    Then status 204

    Given path 'notes', noteId
    And headers headersUser
    When method GET
    Then status 404

    Examples:
      | domain    | typeLink | linkId            |
      | eholdings | resource | 583-2356521-23456 |