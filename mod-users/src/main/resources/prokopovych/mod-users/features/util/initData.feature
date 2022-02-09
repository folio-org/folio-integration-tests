Feature: init data for mod-users

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def patronId = call uuid1
    * def patronName = call random_string


  @PostPatronGroupAndUser
  Scenario: create PatronGroup & User
    * def createPatronGroupRequest = read('samples/PatronGroup/create-patronGroup-request.json')

    Given path 'groups'
    And request createPatronGroupRequest
    When method POST
    Then status 201

    * def patronGroupId = response.id
    * def createUserRequest = read('samples/User/create-user-request.json')

    Given path 'users'
    And request createUserRequest
    When method POST
    Then status 201
