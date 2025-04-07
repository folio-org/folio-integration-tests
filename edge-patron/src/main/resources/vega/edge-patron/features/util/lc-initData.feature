Feature: init data for edge-patron

  Background:
    * url baseUrl
    * callonce login testUser
    * def testTenant = 'ttttpatron'
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }

  @PostPatronGroupAndUser
  Scenario: create Patron Group & User
    * def patronId = call random_uuid
    * def patronName = 'Remote Non-circulating'
    * def createPatronGroupRequest = read('samples/user/create-patronGroup-request.json')

    Given path 'groups'
    And headers headers
    And request createPatronGroupRequest
    When method POST
    Then status 201

  @CreateHomeAddressType
  Scenario: Create 'home' addressType for user
    * print "Create 'home' addressType for user"
    * def homeAddressTypeId = call random_uuid
    * def createPatronGroupRequest = read('samples/address/address-type.json')

    Given path '/addresstypes'
    And headers headers
    And request createPatronGroupRequest
    When method POST
    Then status 201