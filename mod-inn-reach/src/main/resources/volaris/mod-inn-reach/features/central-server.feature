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
    And match centralServerResponse.localAgencies[*].code contains ["q1w2e", "w2e3r"]
    And match centralServerResponse.localAgencies[?(@.code=="q1w2e")].folioLibraryIds[*] contains ["7c244444-ae7c-11eb-8529-0242ac130004", "7f58859e-ae7c-11eb-8529-0242ac130004"]

    * print 'Create central server 2'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server2.json")
    When method POST
    Then status 201
    * def centralServerId2 = $.id

    * print 'Get central server by id 2'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers', centralServerId2
    When method GET
    Then status 200

    * def centralServerResponse = $
    And match centralServerResponse.id == centralServerId2
    And match centralServerResponse.description == "description 2"
    And match centralServerResponse.localServerCode == "test2"
    And match centralServerResponse.centralServerAddress == centralServerUrl
    And match centralServerResponse.localAgencies[*].code contains ["b1w2e", "b2e4r"]
    And match centralServerResponse.localAgencies[?(@.code=="b1w2e")].folioLibraryIds[*] contains ["e580a78d-5281-445e-9d54-b8ede32c8026", "3d75fbb6-f7da-42f1-82a5-f287bbccd2ae"]

    * print 'Get central servers'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.centralServers[*].id contains ['#(centralServerId1)', '#(centralServerId2)']

  Scenario: Check not existed central server
    * configure headers = headersUser
    * print 'Check not existed central server'
    Given path '/inn-reach/central-servers', notExistedCentralServerId1
    * configure headers = headersUser
    When method GET
    Then status 404

  @delete
  Scenario: Delete
    * print 'Delete central servers'
    Given path '/inn-reach/central-servers'
    When method GET
    Then status 200
    * def centralServer1 = get[0] response.centralServers[?(@.name == 'Central server 1')]
    * def centralServer2 = get[0] response.centralServers[?(@.name == 'Central server 2')]

    Given path '/inn-reach/central-servers', centralServer1.id
    When method DELETE
    Then status 204

    Given path '/inn-reach/central-servers', centralServer2.id
    When method DELETE
    Then status 204

  @update
  Scenario: Create and update central server by id
    * configure headers = headersUser
    * print 'Create central server 3'
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId3 = $.id

    * print 'Get central server by id 3'
    Given path '/inn-reach/central-servers', centralServerId3
    When method GET
    Then status 200

    * def centralServerResponse = $
    * set centralServerResponse.loanTypeId = "0706fdbd-cad7-4929-ae5f-fb2c096d68ce"
    * set centralServerResponse.localAgencies[0].code = "x1w5e"

    * print 'Update central server by id 3'
    Given path '/inn-reach/central-servers', centralServerId3
    And request centralServerResponse
    When method PUT
    Then status 204

    * configure headers = headersUser
    * print 'Get central server by id 3'
    Given path '/inn-reach/central-servers', centralServerId3
    When method GET
    Then status 200

    * def centralServerResponse = $
    And match centralServerResponse.id == centralServerId3
    And match centralServerResponse.loanTypeId == "0706fdbd-cad7-4929-ae5f-fb2c096d68ce"
    And match centralServerResponse.localAgencies[*].code contains ["x1w5e"]

    * print 'Delete central server by id 3'
    Given path '/inn-reach/central-servers', centralServerId3
    When method DELETE
    Then status 204

  @update
  Scenario: Create and update central server by invalid id
    * configure headers = headersUser
    * print 'Create central server 3 for negative scenario'
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId3 = $.id

    * print 'Get central server by id 3 for negative scenario'
    Given path '/inn-reach/central-servers', centralServerId3
    When method GET
    Then status 200

    * def centralServerResponse = $
    * set centralServerResponse.loanTypeId = "2d7a90d5-a9dc-42d3-ab25-2d4c9fa35714"
    * set centralServerResponse.localAgencies[0].code = "w1w5e"

    * print 'Update central server by invalid id 3'
    Given path '/inn-reach/central-servers', invalidCentralServerId3
    And request centralServerResponse
    When method PUT
    Then status 404

    * print 'Delete central server by id 3 for negative scenario'
    Given path '/inn-reach/central-servers', centralServerId3
    When method DELETE
    Then status 204

  Scenario: Create and delete central server by id
    * configure headers = headersUser
    * print 'Create central server 4'
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server2.json")
    When method POST
    Then status 201
    * def centralServerId4 = $.id

    * print 'Delete central server by id 4'
    Given path '/inn-reach/central-servers', centralServerId4
    When method DELETE
    Then status 204

    * configure headers = headersUser
    * print 'Check deleted central server by id'
    Given path '/inn-reach/central-servers', centralServerId4
    When method GET
    Then status 404