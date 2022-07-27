@ignore
@parallel=false
Feature: Central server

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce variables
    * print 'call mock server'
    * def mockServer = karate.start(mocksPath + 'general/auth-mock.feature')
    * def port = mockServer.port

    * def notExistedCentralServerId1 = globalCentralServerId1
    * def centralServerUrl = 'http://10.0.2.2:' + port

    * def invalidCentralServerId3 = callonce uuid3

  @create
  Scenario: Create and check central servers
    * configure headers = headersUser
    * print 'Create central server 1'
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId1 = $.id

    * configure headers = headersUser
    * print 'Get central server by id 1'
    Given path '/inn-reach/central-servers', centralServerId1
    When method GET
    Then status 200

    * def centralServerResponse = $
    And match centralServerResponse.id == centralServerId1
    And match centralServerResponse.description == "description 1"
    And match centralServerResponse.localServerCode == "test1"
    And match centralServerResponse.centralServerAddress == centralServerUrl
    And match centralServerResponse.localAgencies[0].code == "q1w2e"
    And match centralServerResponse.localAgencies[0].folioLibraryIds[0] == "7c244444-ae7c-11eb-8529-0242ac130004"

    * print 'Get central servers'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.centralServers[0].id == centralServerId1

  @delete
  Scenario: Delete
    * print 'Delete central servers'
    Given path '/inn-reach/central-servers'
    When method GET
    Then status 200
    * def centralServer1 = response.centralServers[0]

    Given path '/inn-reach/central-servers', centralServer1.id
    When method DELETE
    Then status 204
