Feature: Scenarios that are primarily focused around getting list contents

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def itemListId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'


  Scenario: Get contents of a list, ensure different results for different offsets
    * def listRequest = read('samples/user-list-request.json')
    * listRequest.fqlQuery = '{\"$and\": [{\"users.username\" : {\"$regex\": \"^integration_test_user\"}}]}'
    * def postCall = call postList
    * def listId = postCall.listId

    * call refreshList { listId : '#(listId)'}

    * def query = { offset: 0, size: 2 }
    Given path 'lists', listId, 'contents'
    And params query
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.content.length() == 2
    And match $.content[0] == '#present'
    And match $.content[1] == '#present'
    And match $.totalRecords == '#present'
    * def firstItem = $.content[0]
    * def lastItem = $.content[1]

    * def query = { offset: 1, size: 2 }
    Given path 'lists', listId, 'contents'
    And params query
    When method GET
    Then status 200
    And match $.content[0] == lastItem
    And match $.content[1] == '#notpresent'

  Scenario: Get contents of a list with size 0 should return '400 Bad Request'
    * call refreshList {listId: '#(itemListId)'}
    * def query = { offset: 0, size: 0 }
    Given path 'lists', itemListId, 'contents'
    And params query
    When method GET
    Then status 400

  Scenario: Get contents of a list with negative offset should return '400 Bad Request'
    * call refreshList {listId: '#(itemListId)'}
    * def query = { offset: -1, size: 0 }
    Given path 'lists', itemListId, 'contents'
    And params query
    When method GET
    Then status 400

  Scenario: Get contents of a list that is not present should return '404 Not Found'
    * def invalidId = call uuid1
    * def query = { offset: 0, size: 100 }
    Given path 'lists', invalidId, 'contents'
    And params query
    When method GET
    Then status 404
