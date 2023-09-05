Feature: init data for mod-users

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def util1 = call read('classpath:common/util/uuid1.feature')
    * def util2 = call read('classpath:common/util/random_string.feature')
    * def patronId = util1.uuid1()
    * def patronName = util2.random_string()


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
