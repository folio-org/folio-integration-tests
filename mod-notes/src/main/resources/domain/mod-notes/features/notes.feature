Feature: Notes

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * def notePayload = read('classpath:domain/mod-notes/features/samples/note.json')

    * def result = call read('classpath:domain/mod-notes/features/setup/setup-mod-notes.feature')
    * def defaultNoteTypeId = result.defaultNoteType.id

    * def note = call read('classpath:domain/mod-notes/features/setup/setup-test-note.feature')

    # ================= positive test cases =================

  Scenario Outline: Get Notes collection
    Given path 'notes'
    And param <paramName> = <value>
    And headers headersUser
    When method GET
    Then status 200

    Examples:
      | paramName | value               |
      | id        | note.testNote.id    |
      | title     | note.testNote.title |
      | limit     | 1                   |
      | limit     | 0                   |
      | offset    | 1                   |
      | offset    | 0                   |

  Scenario: Post create new note
    * match note.testNote.id == '#uuid'

  Scenario: Put note by id
    Given path 'notes', note.testNote.id
    And headers headersUser
    And request
    """
    {
      type: Low Priority,
      title: Updated title,
      content: Updated content,
      typeId: #(defaultNoteTypeId),
      domain: Updated domain,
      links: [
	  	{
	  	  id: 583-2356521,
	  	  type: package
	  	}
	  ]
    }
    """
    When method PUT
    Then status 204

    Given path 'notes', note.testNote.id
    And headers headersUser
    When method GET
    Then status 200
    And match $.title == 'Updated title'


    # ================= negative test cases =================

  Scenario Outline: Get Notes collection
    Given path 'notes'
    And param <paramName> = <value>
    And headers headersUser
    When method GET
    Then status 400

    Examples:
      | paramName | value       |
      | limit     | -1          |
      | limit     | ''          |
      | limit     | -2147483649 |
      | limit     | 2147483648  |
      | offset    | -1          |
      | offset    | ''          |
      | offset    | -2147483649 |
      | offset    | 2147483648  |
      | lang      | ''          |
      | lang      | 'A1'        |
      | query     | ''          |
      | query     | 'foo*'      |

  Scenario: Post create note - empty body
    Given path 'notes'
    And headers headersUser
    And request ''
    When method POST
    Then status 400

  Scenario: Post create note - empty JSON
    Given path 'notes'
    And headers headersUser
    And request
    """
    {}
    """
    When method POST
    Then status 422

  Scenario: Post note type - invalid body
    Given path 'note-types'
    And headers headersUser
    And request
    """
    {
      type: Low Priority,
      title: BU Campus Access Issues,
      content: There have been access issues at the BU campus since the weekend,
      typeId: invalid_id
    }
    """
    When method POST
    Then status 422




