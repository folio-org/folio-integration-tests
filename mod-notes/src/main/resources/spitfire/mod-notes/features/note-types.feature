Feature: Note types

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def noteTypePayload = read(featuresPath + 'samples/note-type.json')
    * def noteTypePayloadPut = read(featuresPath + 'samples/note-type-put.json')

    * def result = call read(featuresPath + 'setup/get-default-note-type.feature')
    * def defaultNoteTypeId = result.defaultNoteType.id

    # ================= positive test cases =================

  Scenario: Get Default note type
    Given path 'note-types'
    And headers headersUser
    When method GET
    Then status 200
    * def defaultNoteTypeName = "General note"
    And match $.noteTypes[*].name == '#(^defaultNoteTypeName)'

  Scenario: Get by query
    Given path 'note-types'
    And param query = 'name==General note'
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Post new note type
    Given path 'note-types'
    And headers headersUser
    And request noteTypePayload
    When method POST
    Then status 201
    And match $.id == '#uuid'
    And match $.metadata.createdByUserId == '#uuid'
    And match $.metadata.updatedByUserId == '#uuid'
    And match $.metadata.createdDate == '#present'
    And match $.metadata.updatedDate == '#present'

  Scenario: Get by id
    Given path 'note-types', defaultNoteTypeId
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Put by id
    # create note type
    Given path 'note-types'
    And headers headersUser
    And request noteTypePayload
    * set noteTypePayload.name = 'note type for put'
    When method POST
    And status 201
    * def noteTypeForPut = response.id

    Given path 'note-types', noteTypeForPut
    And headers headersUser
    And request noteTypePayloadPut
    When method PUT
    Then status 204

    #check note type name updated
    Given path 'note-types', noteTypeForPut
    And headers headersUser
    When method GET
    Then status 200
    And match $.name == noteTypePayloadPut.name

  Scenario: Delete by id
    # create note type
    Given path 'note-types'
    And headers headersUser
    And request noteTypePayload
     * set noteTypePayload.name = 'note type for delete'
    When method POST
    And status 201
    * def noteTypeForDelete = response.id

    Given path 'note-types', noteTypeForDelete
    And headers headersUser
    When method DELETE
    Then status 204

    # check note type was deleted
    Given path 'note-types', noteTypeForDelete
    And headers headersUser
    When method GET
    Then status 404
    And match response.errors[0].message contains 'Note type with ID'
    And match response.errors[0].message contains 'was not found'

  Scenario: check limit config for note-types

#    get existing note types number
    Given path 'note-types'
    And headers headersUser
    When method GET
    Then status 200
    * def existingNoteTypeAmount = response.totalRecords

#    set note types limit
    Given path 'configurations/entries'
    And headers headersUser
    And request
    """
     {
        module: NOTES,
        configName: note-type-limit,
        code: note.types.number.limit,
        value: #(existingNoteTypeAmount)
      }
    """
    When method POST
    Then status 201
    * def configId = response.id

#    check note-types limit works
    Given path 'note-types'
    And headers headersUser
    And request
    """
    {
       name: above the limit
    }
    """
    When method POST
    Then status 422
    And match response.errors[0].message == 'Maximum number of note types allowed is ' + existingNoteTypeAmount

#    delete note-type limit
    Given path 'configurations/entries', configId
    And headers headersUser
    When method DELETE
    Then status 204

#  check config deleted
    Given path '/configurations/entries'
    And param query = '(module==NOTES and code==note.types.number.limit)'
    And headers headersUser
    When method GET
    Then status 200

#  check note type created after limit deleted
    Given path 'note-types'
    And headers headersUser
    And request
    """
    {
       name: after config deleted
    }
    """
    When method POST
    Then status 201


    # ================= negative test cases =================

  Scenario Outline: Get note types collection - invalid limit
    Given path 'note-types'
    And param <paramName> = <value>
    And headers headersUser
    When method GET
    Then status 422

    Examples:
      | paramName | value       |
      | limit     | -1          |
      | limit     | -2147483649 |
      | limit     | 2147483648  |
      | offset    | -1          |
      | offset    | -2147483649 |
      | offset    | 2147483648  |

  Scenario: Get note types collection - empty query
    Given path 'note-types'
    And param query = ''
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Post already existing note type
    Given path 'note-types'
    And headers headersUser
    And request noteTypePayload
    When method POST
    Then status 422
    And match response.errors[0].message contains 'Key (name)=(Test note type) already exists'

  Scenario: Post note type - empty JSON
    Given path 'note-types'
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

  Scenario: Post note type - empty body
    Given path 'note-types'
    And headers headersUser
    And request ''
    When method POST
    Then status 422

  Scenario: Post note type - invalid body
    Given path 'note-types'
    And headers headersUser
    And request '{"name" : "Bad Json}'
    When method POST
    Then status 422

  Scenario: Post note type - wrong content-type
    Given path 'note-types'
    And headers headersUser
    And header Content-Type = 'application/xml'
    And request noteTypePayload
    When method POST
    Then status 415
    And match response.error contains 'Unsupported Media Type'

  Scenario: Put by id - invalid id format
    Given path 'note-types', 12345
    And headers headersUser
    And request noteTypePayloadPut
    When method PUT
    Then status 422
    And match response.errors[0].message contains "Failed to convert value of type 'java.lang.String' to required type 'java.util.UUID'"

  Scenario: Put by id - not existing id
    * def randomId = call uuid
    Given path 'note-types', randomId
    And headers headersUser
    And request noteTypePayloadPut
    When method PUT
    Then status 404
    And match response.errors[0].message contains 'Note type with ID'
    And match response.errors[0].message contains 'was not found'

  Scenario: Delete by id - invalid id type
    Given path 'note-types', 12345
    And headers headersUser
    When method DELETE
    Then status 422
    And match response.errors[0].message contains "Failed to convert value of type 'java.lang.String' to required type 'java.util.UUID'"