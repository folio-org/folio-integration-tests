Feature: Note links

  Background:
    * url baseUrl
    * callonce login testUser

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def result = call read('classpath:spitfire/mod-notes/features/setup/get-default-note-type.feature')
    * def defaultNoteTypeId = result.defaultNoteType.id

  Scenario Outline: get notes by specific links

    Given path 'notes'
    And headers headersUser
    And request
    """
    {
      type: Low Priority,
      title: Test note title,
      content: Test content,
      typeId: #(defaultNoteTypeId),
      domain: <domain>,
      links: [
	  	{
	  	  id: <linkId>,
	  	  type: <typeLink>
	  	}
	  ]
    }
    """
    When method POST
    Then status 201


    Given path '/note-links/domain/<domain>/type/<typeLink>/id/<linkId>'
    And headers headersUser
    When method GET
    Then status 200


    Examples:
      | domain    | typeLink | linkId                               |
      | eholdings | resource | 583-2356521-23456                    |
      | users     | user     | 8acab042-ce12-4d8f-bbe5-b1abe41d5d01 |


  Scenario Outline: should delete note when no link assigned

  #   create test note

    Given path 'notes'
    And headers headersUser
    And request
    """
    {
      type: Low Priority,
      title: Test note title,
      content: Test content,
      typeId: #(defaultNoteTypeId),
      domain: <domain>,
      links: [
	  	{
	  	  id: <linkId>,
	  	  type: <typeLink>
	  	}
	  ]
    }
    """
    When method POST
    Then status 201
    * print response
    * def noteId = $.id


    #  update note link

    Given path '/note-links/type/<typeLink>/id/<linkId>'
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
