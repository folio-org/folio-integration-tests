Feature: Notes

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    * def result = call read(featuresPath + 'setup/get-default-note-type.feature')
    * def defaultNoteTypeId = result.defaultNoteType.id

    * def note = call read(featuresPath + 'setup/setup-test-note.feature')

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
      | offset    | 1                   |
      | offset    | 0                   |

  Scenario: Post create new note
    * match note.testNote.id == '#uuid'

  Scenario: Put note by id
    Given path 'notes', note.testNote.id
    And remove headersUser.Accept
    And headers headersUser
    And request read(featuresPath + "samples/note-put.json")
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
    Then status 422
    And match $.errors[0].code == 'VALIDATION_ERROR'

    Examples:
      | paramName | value       |
      | limit     | 0           |
      | limit     | -1          |
      | limit     | -2147483649 |
      | limit     | 2147483648  |
      | offset    | -1          |
      | offset    | -2147483649 |
      | offset    | 2147483648  |
      | query     | 'foo*'      |

  Scenario: Post create note - empty body
    Given path 'notes'
    And headers headersUser
    And request ''
    When method POST
    Then status 422
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].message contains 'Required request body is missing:'

  Scenario: Post create note - empty JSON
    Given path 'notes'
    And headers headersUser
    And request
    """
    {}
    """
    When method POST
    Then status 422
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].message contains 'Validation failed for argument [0]'





