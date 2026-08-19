Feature: Query special fields
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'
    * def receivingPiecesEntityTypeId = 'a344dd36-cd35-4723-8905-3fc3f1baef26'
    * def callNumberTypeId = '512173a7-bd09-490e-b773-17d83f2b63fe'

  Scenario: Run a query on user preferred contact type
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"users.preferred_contact_type\":{\"$eq\":\"Email\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["users.preferred_contact_type"] == 'Email'

  Scenario: Should return _deleted field to indicate that a record has been deleted (MODFQMMGR-125)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$eq\":\"user_to_delete\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'users/00000000-1111-2222-9999-44444444444'
    When method DELETE
    Then status 204

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0] contains {"_deleted":  true}

  Scenario: Instance language column
    * def queryRequest = { entityTypeId: '#(instanceEntityTypeId)' , fqlQuery: '{"instance.languages":{"$eq":"eng"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["instance.languages"] == ['English','French']

  @C1045962
  Scenario: Verify that holdings call number type is queryable
    Given path 'entity-types', holdingsEntityTypeId
    When method GET
    Then status 200
    * def callNumberTypeColumn = karate.filter(response.columns, function(column) { return column.name == 'holdings.call_number_type' })[0]
    And match callNumberTypeColumn.queryable == true

    * def fqlQuery = '{\"holdings.call_number_type\":{\"$in\":[\"' + callNumberTypeId + '\"]}}'
    * def queryRequest = { entityTypeId: '#(holdingsEntityTypeId)', fqlQuery: '#(fqlQuery)', fields: ['holdings.id', 'holdings.call_number_type'] }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"holdings.call_number_type": "LC Modified"}

  @C987718
  Scenario: Verify that 'Receiving pieces - Holdings permanent location' is queryable
    Given path 'entity-types', receivingPiecesEntityTypeId
    When method GET
    Then status 200
    * def holdingsPermanentLocationNameColumn = karate.filter(response.columns, function(column) { return column.name == 'holdings_permanent_location.name' })[0]
    And match holdingsPermanentLocationNameColumn.queryable == true

    * def queryRequest = { entityTypeId: '#(receivingPiecesEntityTypeId)', fqlQuery: '{\"holdings_permanent_location.name\":{\"$in\":[\"Location 1\"]}}', fields: ['pieces.id', 'holdings_permanent_location.name'] }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"holdings_permanent_location.name": "Location 1"}

  @C773209
  Scenario: Verify that instance identifier type is queryable
    Given path 'entity-types', instanceEntityTypeId
    When method GET
    Then status 200
    * def identifierColumn = karate.filter(response.columns, function(column) { return column.name == 'instance.identifiers' })[0]
    * def identifierTypeColumn = karate.filter(identifierColumn.dataType.itemDataType.properties, function(property) { return property.name == 'identifier_type_name' })[0]
    And match identifierTypeColumn.queryable == true

    * def fqlQuery = "{\"$and\":[{\"instance.identifiers[*]->identifier_type_name\":{\"$in\":[\"3187432f-9434-40a8-8782-35a111a1491e\",\"7f907515-a1bf-4513-8a38-92e1a07c539d\"]}},{\"instance.title\":{\"$eq\":\"Corsair's new instance\"}}]}"
    * configure retry = { count: 24, interval: 5000 }
    Given path 'query'
    And params { entityTypeId: '#(instanceEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.title', 'instance.identifiers'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * assert parseInt(response.totalRecords) == 1
    And match response.content[0]['instance.title'] == "Corsair's new instance"
    And match response.content[0]['instance.identifiers'] contains 'ASIN'
    And match response.content[0]['instance.identifiers'] contains 'ASIN - test1'
    And match response.content[0]['instance.identifiers'] contains 'BNB'
    And match response.content[0]['instance.identifiers'] contains 'BNB - test1'
