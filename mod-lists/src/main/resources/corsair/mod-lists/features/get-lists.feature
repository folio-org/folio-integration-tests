Feature: Scenarios that are primarily focused around getting list details

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def itemListId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def loanListId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'

  @ignore
  Scenario: Get all lists for a tenant (ids not provided)
    Given path 'lists'
    When method GET
    Then status 200
    And match $.content == '#present'
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords >= 2

  @ignore
  Scenario: Get all lists for tenant (empty ids)
    * def parameters = {ids: [''] }
    Given path 'lists'
    And params parameters
    When method GET
    Then status 200
    And match $.content == '#present'
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords >= 2

  @ignore
  Scenario: Get all lists for tenant with updatedAsOf query parameter
    * def updatedTime = {updatedAsOf: "2022-09-27T20:47:51.886+00:00"}
    Given path 'lists'
    And params updatedTime
    When method GET
    Then status 200
    And match $.content == '#present'
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords >= 2

  Scenario: Get all lists for tenant with private query parameter
    * def listRequest = read('samples/private-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
    * def parameters = {private: true}
    Given path 'lists'
    And params parameters
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.content[0].isPrivate == true

  Scenario: Get all lists for tenant with active query parameter
    * def listRequest = read('samples/private-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
    * def parameters = {active: true}
    Given path 'lists'
    And params parameters
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.content[0].isActive == true

  @ignore
  Scenario: Get lists for multiple ids
    * def loanListName = 'Inactive patrons with open loans'
    * def itemListName = 'Missing items'
    * def query = { ids: ['#(itemListId)', '#(loanListId)'] }
    Given path 'lists'
    And params query
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.totalRecords == 2
    * assert (response.content[0].name == itemListName || response.content[0].name == loanListName)
    * assert (response.content[1].name == itemListName || response.content[1].name == loanListName)

  Scenario: Get lists for invalid ids array should return 200 with zero records
    * def invalidId = call uuid1
    * def invalidId2 = call uuid1
    * def query = { ids: ['#(invalidId)', '#(invalidId2)'] }
    Given path 'lists'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == 0
    And match $.totalPages == 0

  Scenario: Get lists for non-existent list id array should return no list summaries
    * def invalidId = call uuid1
    * def query = { ids: '#(invalidId)'}
    Given path 'lists'
    And params query
    When method GET
    Then status 200
    And match $.content == '#notpresent'

  @ignore
  Scenario: Get single list
    Given path 'lists', itemListId
    When method GET
    Then status 200
    And match $.name == 'Missing items'

  Scenario: Get list for id that is not present
    * def invalidId = call uuid1
    Given path 'lists', invalidId
    When method GET
    Then status 404
