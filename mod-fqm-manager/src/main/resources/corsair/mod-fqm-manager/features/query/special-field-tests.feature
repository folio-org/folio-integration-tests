Feature: Query special fields
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'

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
    * def queryRequest = { entityTypeId: '#(instanceEntityTypeId)' , fqlQuery: '{"instance.languages":{"$contains_all":["eng"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["instance.languages"] == ['eng','fre']
